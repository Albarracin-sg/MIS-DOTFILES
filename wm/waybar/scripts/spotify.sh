#!/bin/bash

# Script para mostrar información de Spotify en Waybar

if ! pgrep -x spotify >/dev/null; then
  echo '{"text": "", "class": "not-running"}'
  exit 0
fi

# Obtener información usando playerctl
STATUS=$(playerctl --player=spotify status 2>/dev/null)
ARTIST=$(playerctl --player=spotify metadata artist 2>/dev/null)
TITLE=$(playerctl --player=spotify metadata title 2>/dev/null)

if [ -z "$STATUS" ] || [ -z "$ARTIST" ] || [ -z "$TITLE" ]; then
  echo '{"text": "", "class": "not-playing"}'
  exit 0
fi

# Determinar el icono según el estado
case $STATUS in
"Playing")
  ICON=""
  CLASS="playing"
  ;;
"Paused")
  ICON=""
  CLASS="paused"
  ;;
*)
  ICON=""
  CLASS="stopped"
  ;;
esac

# Limitar longitud del texto
MAX_LENGTH=40
FULL_TEXT="$ARTIST - $TITLE"
if [ ${#FULL_TEXT} -gt $MAX_LENGTH ]; then
  FULL_TEXT="${FULL_TEXT:0:$MAX_LENGTH}..."
fi

# Salida JSON para Waybar
echo "{\"text\": \"$ICON $FULL_TEXT\", \"class\": \"$CLASS\", \"tooltip\": \"$ARTIST - $TITLE\"}"
