#!/usr/bin/env bash
set -euo pipefail

SCREENSHOT_DIR="$HOME/Imagenes/Screenshots"
RECORD_DIR="$HOME/Videos/Recordings"

mkdir -p "$SCREENSHOT_DIR" "$RECORD_DIR"

menu=$(printf '%s
' \
  "Captura completa" \
  "Captura region" \
  "Grabar pantalla" \
  "Grabar region" \
  "Detener grabacion" \
  | rofi -dmenu -i -p "Pantalla")

if [[ -z "$menu" ]]; then
  exit 0
fi

case "$menu" in
  "Captura completa")
    file="$SCREENSHOT_DIR/Screenshot-$(date +%F_%T).png"
    grim - | tee >(wl-copy) | { cat > "$file" && dunstify -i "$file" "Pantalla completa" -t 1500; }
    ;;
  "Captura region")
    file="$SCREENSHOT_DIR/Screenshot-$(date +%F_%T).png"
    grim -g "$(slurp)" - | tee >(wl-copy) | { cat > "$file" && dunstify -i "$file" "Region capturada" -t 1500; }
    ;;
  "Grabar pantalla")
    file="$RECORD_DIR/record-$(date +%F_%T).mp4"
    dunstify "Grabando pantalla" -t 1500
    wf-recorder -f "$file"
    ;;
  "Grabar region")
    file="$RECORD_DIR/record-$(date +%F_%T).mp4"
    dunstify "Grabando region" -t 1500
    wf-recorder -g "$(slurp)" -f "$file"
    ;;
  "Detener grabacion")
    pkill -INT wf-recorder && dunstify "Grabacion detenida" -t 1500
    ;;
esac
