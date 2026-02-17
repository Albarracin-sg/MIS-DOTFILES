#!/bin/bash

get_icon() {
    vol=$(pamixer --get-volume 2>/dev/null || echo "50")
    mute=$(pamixer --get-mute 2>/dev/null)

    if [ "$mute" = "true" ]; then
        echo "󰖁"
    elif [ "$vol" -lt 33 ]; then
        echo "󰕿"
    elif [ "$vol" -lt 66 ]; then
        echo "󰖀"
    else
        echo "󰕾"
    fi
}

get_icon
pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
    get_icon
done
