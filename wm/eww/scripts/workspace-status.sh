#!/bin/bash

# Script para obtener el estado de los workspaces en formato JSON para Eww

workspace_data=$(hyprctl workspaces -j 2>/dev/null)
current_workspace=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null)

# Construir el array JSON completo como una sola línea
items=()
echo "$workspace_data" | jq -c '.[]' | while read -r ws; do
    ws_id=$(echo "$ws" | jq -r '.id')
    windows=$(echo "$ws" | jq -r '.windows')

    # Determinar la clase CSS
    if [[ "$current_workspace" == "$ws_id" ]]; then
        class="visiting"
    elif [[ "$windows" -gt 0 ]]; then
        class="occupied"
    else
        class="free"
    fi

    # Generar el objeto JSON
    echo "{\"id\": $ws_id, \"class\": \"$class\"}"
done > /tmp/workspace_items.json

# Combinar todos los elementos en un array JSON
output="["
first=true
while IFS= read -r line; do
    if [ "$first" = true ]; then
        first=false
    else
        output+=","
    fi
    output+="$line"
done < /tmp/workspace_items.json
output+="]"

echo "$output"

# Limpiar archivo temporal
rm -f /tmp/workspace_items.json