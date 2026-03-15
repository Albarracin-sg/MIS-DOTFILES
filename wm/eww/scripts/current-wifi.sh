#!/usr/bin/env bash
set -euo pipefail

cache_file="/tmp/eww_public_ip.cache"
cache_ttl=300

get_public_ip() {
    local now cached_at cached_ip

    now=$(date +%s)

    if [[ -f "$cache_file" ]]; then
        cached_at=$(cut -d' ' -f1 "$cache_file" 2>/dev/null || true)
        cached_ip=$(cut -d' ' -f2- "$cache_file" 2>/dev/null || true)

        if [[ -n "$cached_at" && -n "$cached_ip" && $((now - cached_at)) -lt $cache_ttl ]]; then
            printf '%s\n' "$cached_ip"
            return 0
        fi
    fi

    cached_ip=$(curl -4 --silent --show-error --max-time 2 https://api.ipify.org 2>/dev/null || true)

    if [[ -n "$cached_ip" ]]; then
        printf '%s %s\n' "$now" "$cached_ip" > "$cache_file"
        printf '%s\n' "$cached_ip"
        return 0
    fi

    if [[ -f "$cache_file" ]]; then
        cut -d' ' -f2- "$cache_file" 2>/dev/null || true
    fi
}

emit_status() {
    local icon="$1"
    local label="$2"
    local strength="$3"
    local local_ip="$4"
    local public_ip="$5"
    local network_type="$6"
    local ping_ms="$7"
    local masked_local_ip="$8"

    jq -nc \
      --arg icon "$icon" \
      --arg ssid "$label" \
      --arg local_ip "$local_ip" \
      --arg public_ip "$public_ip" \
      --arg type "$network_type" \
      --arg ping_ms "$ping_ms" \
      --arg masked_local_ip "$masked_local_ip" \
      --argjson strength "$strength" \
      '{icon: $icon, ssid: $ssid, strength: $strength, local_ip: $local_ip, public_ip: $public_ip, type: $type, ping_ms: $ping_ms, masked_local_ip: $masked_local_ip}'
}

get_ping_ms() {
    local raw
    local source="ping"

    raw=$(LC_ALL=C ping -c 1 -W 1 1.1.1.1 2>/dev/null | grep -oP 'time=\K[0-9.]+' | head -n 1 || true)

    if [[ -z "$raw" ]]; then
        source="curl"
        raw=$(curl -4 -o /dev/null -s -w '%{time_total}' --max-time 2 https://api.ipify.org 2>/dev/null || true)
    fi

    if [[ -z "$raw" ]]; then
        printf '%s\n' '0ms'
        return 0
    fi

    if [[ "$source" == "ping" ]]; then
        awk -v value="$raw" 'BEGIN { printf "%dms\n", value < 1 ? 1 : value }'
        return 0
    fi

    awk -v value="$raw" 'BEGIN { printf "%dms\n", (value * 1000) < 1 ? 1 : (value * 1000) }'
}

mask_local_ip() {
    local ip="$1"

    if [[ -z "$ip" || "$ip" == "-" ]]; then
        printf '%s\n' '-'
        return 0
    fi

    IFS='.' read -r o1 o2 _ _ <<< "$ip"
    printf '%s\n' "${o1:-*}.${o2:-*}.xx.xx"
}

default_device=$(ip route get 1.1.1.1 2>/dev/null | grep -oP '(?<=dev )\S+' | head -n 1 || true)

if [[ -n "$default_device" ]]; then
    device_info=$(LC_ALL=C nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status | grep "^${default_device}:" || true)
else
    device_info=$(LC_ALL=C nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status | grep -E ':(ethernet|wifi):connected:' | head -n 1 || true)
fi

if [[ -z "$device_info" ]]; then
    emit_status "󰤮" "Disconnected" 0 "-" "-" "offline" "--" "-"
    exit 0
fi

device=$(printf '%s' "$device_info" | cut -d: -f1)
device_type=$(printf '%s' "$device_info" | cut -d: -f2)
connection_name=$(printf '%s' "$device_info" | cut -d: -f4-)
local_ip=$(ip -4 -o addr show dev "$device" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1 || true)
public_ip=$(get_public_ip)
ping_ms=$(get_ping_ms)

if [[ -z "$local_ip" ]]; then
    local_ip="-"
fi

if [[ -z "$public_ip" ]]; then
    public_ip="-"
fi

masked_local_ip=$(mask_local_ip "$local_ip")

if [[ "$device_type" == "wifi" ]]; then
    wifi_info=$(LC_ALL=C nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | head -n 1 || true)
    ssid=$(printf '%s' "$wifi_info" | cut -d: -f2)
    signal=$(printf '%s' "$wifi_info" | cut -d: -f3)
    icon=""

    if [[ -z "$ssid" ]]; then
        ssid="$connection_name"
    fi

    emit_status "$icon" "${ssid^^}" "${signal:-0}" "$local_ip" "$public_ip" "wifi" "$ping_ms" "$masked_local_ip"
    exit 0
fi

if [[ "$device_type" == "ethernet" ]]; then
    label=${connection_name:-$device}
    emit_status "󰈀" "${label^^}" 100 "$local_ip" "$public_ip" "ethernet" "$ping_ms" "$masked_local_ip"
    exit 0
fi

emit_status "󰤮" "Disconnected" 0 "$local_ip" "$public_ip" "$device_type" "$ping_ms" "$masked_local_ip"
