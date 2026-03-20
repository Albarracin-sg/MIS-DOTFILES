#!/bin/bash

eww_cmd="$HOME/.config/eww/scripts/ewwctl.sh"

"${eww_cmd}" update wifihov=true
(sleep 0.45 && "${eww_cmd}" update wifirev="$("${eww_cmd}" get wifihov)") &
