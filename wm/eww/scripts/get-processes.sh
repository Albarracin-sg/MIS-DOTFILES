#!/bin/bash

# Script para obtener los 8 procesos que más consumen CPU o RAM
# Guarda como: ~/.config/eww/scripts/get-processes.sh
# Dale permisos: chmod +x ~/.config/eww/scripts/get-processes.sh

# Formato JSON para eww
echo "["

ps aux --sort=-%cpu | awk 'NR>1 {
    cmd = $11
    # Limpiar la ruta del comando, solo mostrar el nombre
    sub(/^.*\//, "", cmd)
    # Limitar longitud
    if (length(cmd) > 20) cmd = substr(cmd, 1, 17) "..."
    
    printf "{\"name\":\"%s\",\"cpu\":\"%.1f\",\"ram\":\"%.1f\",\"pid\":\"%s\"}", cmd, $3, $4, $2
    
    if (NR <= 8) printf ","
    if (NR > 8) exit
}'

echo "]"
