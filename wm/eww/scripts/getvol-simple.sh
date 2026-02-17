#!/bin/bash
pamixer --get-volume 2>/dev/null || echo "50"
pactl subscribe | grep --line-buffered "sink" | while read -r _; do
  pamixer --get-volume 2>/dev/null || echo "50"
done
