#!/bin/bash

monitor_id=$1
menu_rev_var="menurev_${monitor_id}"
menu_window="menuctl_${monitor_id}"

current_value=$(/usr/bin/eww get "$menu_rev_var")

if [ "$current_value" = "true" ]; then
  /usr/bin/eww update "${menu_rev_var}"=false
  (sleep 0.2 && /usr/bin/eww close "${menu_window}") &
else
  /usr/bin/eww open "${menu_window}"
  /usr/bin/eww update "${menu_rev_var}"=true
fi