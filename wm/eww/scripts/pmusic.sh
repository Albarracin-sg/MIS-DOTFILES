#!/bin/bash

# Función para obtener la posición actual del reproductor
get_position() {
    # Obtener el nombre del reproductor que está reproduciendo
    # Buscar reproductores activos, priorizando Spotify, luego Chromium, luego Firefox
    all_players=$(playerctl -l 2>/dev/null)

    # Buscar en orden de preferencia
    spotify_player=$(echo "$all_players" | grep "^spotify$")
    chromium_player=$(echo "$all_players" | grep "^chromium")
    firefox_player=$(echo "$all_players" | grep "^firefox")

    # Asignar en orden de preferencia
    if [ -n "$spotify_player" ] && [ "$(playerctl -p "$spotify_player" status 2>/dev/null)" = "Playing" ]; then
        playing_player="$spotify_player"
    elif [ -n "$chromium_player" ] && [ "$(playerctl -p "$chromium_player" status 2>/dev/null)" = "Playing" ]; then
        playing_player="$chromium_player"
    elif [ -n "$firefox_player" ] && [ "$(playerctl -p "$firefox_player" status 2>/dev/null)" = "Playing" ]; then
        playing_player="$firefox_player"
    elif [ -n "$spotify_player" ] && [ "$(playerctl -p "$spotify_player" status 2>/dev/null)" = "Paused" ]; then
        playing_player="$spotify_player"
    elif [ -n "$chromium_player" ] && [ "$(playerctl -p "$chromium_player" status 2>/dev/null)" = "Paused" ]; then
        playing_player="$chromium_player"
    elif [ -n "$firefox_player" ] && [ "$(playerctl -p "$firefox_player" status 2>/dev/null)" = "Paused" ]; then
        playing_player="$firefox_player"
    else
        # Si ninguno está reproduciendo, usar el primero disponible
        playing_player=$(echo "$all_players" | head -n 1)
    fi

    if [ -n "$playing_player" ]; then
        # Verificar el estado específico de ese reproductor
        status=$(playerctl -p "$playing_player" status 2>/dev/null)

        if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
            # Obtener posición y longitud en microsegundos del reproductor activo
            position=$(playerctl -p "$playing_player" position 2>/dev/null || echo "0")
            length=$(playerctl -p "$playing_player" metadata mpris:length 2>/dev/null || echo "0")

            # Convertir microsegundos a segundos para posición
            if [[ "$position" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                pos_sec=$(printf "%.0f" "$position")
            else
                pos_sec=0
            fi

            # Convertir microsegundos a segundos para longitud
            if [ -n "$length" ] && [ "$length" != "0" ] && [[ "$length" =~ ^[0-9]+$ ]]; then
                len_sec=$((length / 1000000))
            else
                len_sec=0
            fi

            # Limitar pos_sec para que no exceda la longitud
            if [ "$pos_sec" -gt "$len_sec" ] && [ "$len_sec" -gt 0 ]; then
                pos_sec=$len_sec
            fi
        else
            # Si el reproductor no está reproduciendo, resetear valores
            pos_sec=0
            len_sec=0
        fi
    else
        # Si no hay reproductores disponibles
        pos_sec=0
        len_sec=0
    fi

    # Formatear tiempo para posición
    mins_pos=$((pos_sec / 60))
    secs_pos=$((pos_sec % 60))
    pos_str=$(printf "%d:%02d" "$mins_pos" "$secs_pos")

    # Enviar datos como JSON
    jq -n -c \
        --arg position "$pos_sec" \
        --arg positionStr "$pos_str" \
        --arg length "$len_sec" \
        '{position: $position, positionStr: $positionStr, length: $length}'
}

# Llamar a la función una vez para obtener la primera actualización
get_position

# Luego bucle infinito con actualizaciones cada 0.5 segundos
while true; do
    sleep 0.5
    get_position
done
