#!/usr/bin/env bash

eww_cmd="$HOME/.config/eww/scripts/ewwctl.sh"
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

current_state=$("${eww_cmd}" get "$ctlrev_var")

if [ "$current_state" = "true" ]; then
  "${eww_cmd}" update "$ctlrev_var=false"
  "${eww_cmd}" close "$target_window" 2>/dev/null || true
else
  "${eww_cmd}" close "$target_window" 2>/dev/null || true
  "${eww_cmd}" update "$ctlrev_var=true"
  "${eww_cmd}" open "$target_window"
fi
