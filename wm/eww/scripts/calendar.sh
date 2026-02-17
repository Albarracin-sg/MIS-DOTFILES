#!/bin/bash
MONITOR="${1:-0}"

if [[ $(eww get calrev_${MONITOR}) == "true" ]]; then
    eww update calrev_${MONITOR}=false
    eww close calendar_${MONITOR}
else
    eww update calrev_${MONITOR}=true
    eww open calendar_${MONITOR}
fi
