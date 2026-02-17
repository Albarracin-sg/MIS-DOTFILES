#!/bin/bash

get_volume() {
    mute=$(pamixer --get-mute 2>/dev/null)
    if [ "$mute" = "true" ]; then
        echo "0"
    else
        pamixer --get-volume 2>/dev/null || echo "50"
    fi
}

get_volume
pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
    get_volume
done
