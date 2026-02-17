#!/bin/bash

# Obtener el valor de posición objetivo 
target_position=$1

if [ -z "$target_position" ]; then
    echo "Error: No se proporcionó una posición objetivo" >&2
    exit 1
fi

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

# Si encontramos un reproductor, intentar cambiar la posición
if [ -n "$playing_player" ]; then
    playerctl -p "$playing_player" position "$target_position" 2>/dev/null
else
    # Si no hay reproductores disponibles, mostrar error
    echo "Error: No se encontraron reproductores activos" >&2
    exit 1
fi