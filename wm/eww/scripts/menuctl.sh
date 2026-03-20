#!/bin/bash

eww_cmd="$HOME/.config/eww/scripts/ewwctl.sh"

monitor_id=$1
menu_rev_var="menurev_${monitor_id}"
menu_window="menuctl_${monitor_id}"

current_value=$("${eww_cmd}" get "$menu_rev_var")

if [ "$current_value" = "true" ]; then
  "${eww_cmd}" update "${menu_rev_var}"=false
  (sleep 0.2 && "${eww_cmd}" close "${menu_window}") &
else
  "${eww_cmd}" open "${menu_window}"
  "${eww_cmd}" update "${menu_rev_var}"=true
fi