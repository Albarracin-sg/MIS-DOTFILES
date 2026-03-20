#!/bin/bash

eww_cmd="$HOME/.config/eww/scripts/ewwctl.sh"

"${eww_cmd}" update keyhov=true
(sleep 0.45 && "${eww_cmd}" update keyrev="$("${eww_cmd}" get keyhov)") &
