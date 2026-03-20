#!/bin/bash
# TO CONNECT TO WIFI USING DMENU | ROFI WHICH IS CONNECTED BEFORE
# bssid=$(nmcli device wifi list | sed -n '1!P'| cut -b 9- | dmenu -p "Wifi" -l 10 | awk '{print $1}')

set -euo pipefail

rofi_theme="$HOME/.config/rofi/themes/current.rasi"
if [[ ! -f "$rofi_theme" ]]; then
    rofi_theme="$HOME/.config/rofi/themes/tokyonight.rasi"
fi

# [ -z "$bssid" ] && exit 1
# nmcli device wifi connect $bssid
# notify-send "📶 WiFi Connected"

bssid=$(nmcli device wifi list | sed -n '1!P'| cut -b 9- | rofi -dmenu -theme "$rofi_theme" -p " " -lines 10 | awk '{print $1}')
[ -z "$bssid" ] && exit 1
nmcli device wifi connect $bssid
notify-send "📶 WiFi Connected"
