#!/bin/bash

# Función para generar la salida de workspaces (solo con los 10 primeros workspaces)
generate_workspaces_output() {
    local output=""
    local max_workspace=10

    workspace_data=$(hyprctl workspaces -j)
    current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

    output="(box :class \"ws\" :halign \"end\" :orientation \"h\" :spacing 5 :space-evenly \"false\""

    # Mostrar workspaces del 1 al 10 en orden
    for i in $(seq 1 $max_workspace); do
        # Verificar si el workspace existe en los datos actuales
        exists=$(echo "$workspace_data" | jq -r "map(select(.id == $i)) | length")

        if [ "$exists" -gt 0 ]; then
            # Este workspace existe, obtener información
            windows=$(echo "$workspace_data" | jq -r ".[] | select(.id == $i) | .windows")
        else
            # Este workspace no existe, tratar como vacío
            windows=0
        fi

        if [[ "$current_workspace" == "$i" ]]; then
            class="visiting"
            icon="$i"
        elif [[ "$windows" -gt 0 ]]; then
            class="occupied"
            icon="$i"
        else
            class="free"
            icon="$i"
        fi

        output+=" (eventbox :onclick \"hyprctl dispatch workspace $i\" :cursor \"pointer\" :class \"$class\" (label :text \"$icon\"))"
    done

    output+=")"

    # Actualizar la variable de Eww
    /usr/bin/eww update workspaces-output="$output"
}

# Generar estado inicial
generate_workspaces_output

# Intentar escuchar eventos de Hyprland si socat está disponible
if command -v socat >/dev/null 2>&1; then
    HYPRLAND_SIGNATURE_ACTUAL=$(ls -td /run/user/1000/hypr/*/ | head -n1 | xargs basename)
    SOCKET="/run/user/1000/hypr/${HYPRLAND_SIGNATURE_ACTUAL}/.socket2.sock"

    stdbuf -oL socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
        case $line in
            "workspace>>"*|"createworkspace>>"*|"destroyworkspace>>"*|"focusedmon>>"*)
                generate_workspaces_output
                ;;
        esac
    done
else
    # Fallback: actualizar cada 1 segundo si no hay socat
    while true; do
        sleep 1
        generate_workspaces_output
    done
fi
