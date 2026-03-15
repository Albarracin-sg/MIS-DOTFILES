#!/usr/bin/env bash
set -euo pipefail

monitor_id=${1:-}

if [ -z "${monitor_id:-}" ]; then
  monitor_id=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .id' | head -n 1)
fi

if [ -z "${monitor_id:-}" ]; then
  monitor_id=0
fi

ctlrev_var="ctlrev_${monitor_id}"
target_window="usrctl_${monitor_id}"

current_state=$(/usr/bin/eww get "$ctlrev_var")

if [ "$current_state" = "true" ]; then
  /usr/bin/eww update "$ctlrev_var=false"
  /usr/bin/eww close "$target_window" 2>/dev/null || true
else
  /usr/bin/eww close "$target_window" 2>/dev/null || true
  /usr/bin/eww update "$ctlrev_var=true"
  /usr/bin/eww open "$target_window"
fi
