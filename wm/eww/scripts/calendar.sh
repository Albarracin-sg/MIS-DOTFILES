#!/bin/bash

eww_cmd="$HOME/.config/eww/scripts/ewwctl.sh"
MONITOR="${1:-0}"

if [[ $("${eww_cmd}" get calrev_${MONITOR}) == "true" ]]; then
    "${eww_cmd}" update calrev_${MONITOR}=false
    "${eww_cmd}" close calendar_${MONITOR}
else
    "${eww_cmd}" update calrev_${MONITOR}=true
    "${eww_cmd}" open calendar_${MONITOR}
fi
