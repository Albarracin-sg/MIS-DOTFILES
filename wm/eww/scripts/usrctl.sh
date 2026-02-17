#!/bin/bash

# Recibe el monitor_id como argumento
MONITOR_ID=${1:-0}

# Variable específica del monitor
CTLREV_VAR="ctlrev_${MONITOR_ID}"
WINDOW_NAME="usrctl_${MONITOR_ID}"

# Obtiene el estado actual de la variable
current_state=$(/usr/bin/eww get ${CTLREV_VAR})

if [[ "$current_state" == "true" ]]; then
    /usr/bin/eww update ${CTLREV_VAR}=false
    /usr/bin/eww close ${WINDOW_NAME}
else
    /usr/bin/eww update ${CTLREV_VAR}=true
    /usr/bin/eww open ${WINDOW_NAME}
fi
