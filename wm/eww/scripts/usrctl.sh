#!/bin/bash

eww_cmd="$HOME/.config/eww/scripts/ewwctl.sh"

# Recibe el monitor_id como argumento
MONITOR_ID=${1:-0}

# Variable específica del monitor
CTLREV_VAR="ctlrev_${MONITOR_ID}"
WINDOW_NAME="usrctl_${MONITOR_ID}"

# Obtiene el estado actual de la variable
current_state=$("${eww_cmd}" get ${CTLREV_VAR})

if [[ "$current_state" == "true" ]]; then
    "${eww_cmd}" update ${CTLREV_VAR}=false
    "${eww_cmd}" close ${WINDOW_NAME}
else
    "${eww_cmd}" update ${CTLREV_VAR}=true
    "${eww_cmd}" open ${WINDOW_NAME}
fi
