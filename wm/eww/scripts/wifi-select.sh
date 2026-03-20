#!/bin/bash

eww_cmd="$HOME/.config/eww/scripts/ewwctl.sh"

AUTO=$1
INUSE=$2
SSID=$3

"${eww_cmd}" update wificonfigrev=false
"${eww_cmd}" update wificonfigrev=true

if [ "$AUTO" == "false" ]; then
    "${eww_cmd}" update wificlass="1"
elif [ "$INUSE" == "false" ]; then
    "${eww_cmd}" update wificlass="2"
else
    "${eww_cmd}" update wificlass="3"
fi

"${eww_cmd}" update wifissidrev="$SSID"
