#!/usr/bin/env bash
set -euo pipefail

SCREENSHOT_DIR="$HOME/Imagenes/Screenshots"
RECORD_DIR="$HOME/Videos/Recordings"
STATE_DIR="$HOME/.cache/hypr-screenrec"
PID_FILE="$STATE_DIR/wf-recorder.pid"
OUT_FILE="$STATE_DIR/current-output.txt"
LOG_FILE="$STATE_DIR/wf-recorder.log"
AUDIO_MODE_FILE="$STATE_DIR/audio-mode.txt"
COMBINED_SINK="hyprrecord-combined"
ROFI_THEME="$HOME/.config/rofi/themes/current.rasi"

[[ ! -f "$ROFI_THEME" ]] && ROFI_THEME="$HOME/.config/rofi/themes/tokyonight.rasi"

mkdir -p "$SCREENSHOT_DIR" "$RECORD_DIR" "$STATE_DIR"

notify() { dunstify "$1" -t 1800; }

toggle_system_mute() {
  local sink
  sink=$(pactl get-default-sink 2>/dev/null)
  [[ -z "$sink" ]] && return 1
  pactl set-sink-mute "$sink" toggle 2>/dev/null
  local muted
  muted=$(pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}')
  if [[ "$muted" == "yes" ]]; then
    notify "🔇 Sistema muteado"
  else
    notify "🔊 Sistema desmuteado"
  fi
}

setup_combined_audio() {
  pactl list modules 2>/dev/null | grep -q "null-sink.*$COMBINED_SINK" && return
  pactl load-module module-null-sink \
    sink_name="$COMBINED_SINK" \
    sink_properties="device.description=RecordCombined" \
    2>/dev/null || true
  pactl load-module module-loopback \
    source="alsa_input.pci-0000_0b_00.6.analog-stereo" \
    sink="$COMBINED_SINK" \
    2>/dev/null || true
  pactl load-module module-loopback \
    source="$(pactl get-default-sink).monitor" \
    sink="$COMBINED_SINK" \
    2>/dev/null || true
}

is_recording() {
  [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

start_recording() {
  local target="$1"
  local audio_mode="$2"
  local screen="$3"

  if is_recording; then
    notify "Ya hay una grabacion en curso"
    return 0
  fi

  local audio_arg=""
  case "$audio_mode" in
    "PC + Microfono")
      setup_combined_audio
      sleep 0.2
      audio_arg="--audio=${COMBINED_SINK}.monitor"
      ;;
    "Audio del PC")
      audio_arg="--audio=$(pactl get-default-sink 2>/dev/null).monitor"
      ;;
    "Microfono")
      audio_arg="--audio=$(pactl get-default-source 2>/dev/null)"
      ;;
  esac

  local cmd=(wf-recorder -f "$target")
  [[ -n "$screen" ]] && cmd+=(-o "$screen")
  [[ -n "$audio_arg" ]] && cmd+=("$audio_arg")

  "${cmd[@]}" >"$LOG_FILE" 2>&1 &
  local pid=$!
  disown "$pid" || true

  sleep 0.5
  if ! kill -0 "$pid" 2>/dev/null; then
    local err=""
    [[ -f "$LOG_FILE" ]] && err="$(tail -3 "$LOG_FILE")"
    notify "Error: ${err:-(revisa wf-recorder)}"
    return 1
  fi

  printf '%s\n' "$pid" > "$PID_FILE"
  printf '%s\n' "$target" > "$OUT_FILE"
  printf '%s\n' "$audio_mode" > "$AUDIO_MODE_FILE"

  notify "Grabando con $audio_mode" -r 9991
  show_timer_loop "$pid" &
}

show_timer_loop() {
  local pid=$1
  local start=$(date +%s)
  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(($(date +%s) - start))
    local mins=$(( elapsed / 60 ))
    local secs=$(( elapsed % 60 ))
    dunstify "⬤ REC $mins:$(printf '%02d' $secs)" -t 1000 -r 9991
    sleep 1
  done
}

stop_recording() {
  if is_recording; then
    local pid=$(cat "$PID_FILE")
    local file=""
    kill -INT "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    [[ -f "$OUT_FILE" ]] && file=$(cat "$OUT_FILE")
    sleep 0.4
    [[ -n "$file" ]] && wl-copy --type text/uri-list <<<"file://$file" 2>/dev/null
    notify "Grabacion guardada. Ctrl+V para pegar" -r 9991
    rm -f "$OUT_FILE" "$AUDIO_MODE_FILE"
  else
    pkill -INT wf-recorder 2>/dev/null || true
    notify "No habia grabacion activa"
  fi
}

choose_screen() {
  local outputs
  outputs=$(wf-recorder -L 2>/dev/null)
  [[ -z "$outputs" ]] && return 1

  local count
  count=$(echo "$outputs" | grep -c "^[[:space:]]*[0-9]\+\.")

  if [[ "$count" -eq 1 ]]; then
    local name
    name=$(echo "$outputs" | grep "^[[:space:]]*[0-9]\+\." | sed -E 's/.*Name: ([^ ]+).*/\1/')
    [[ -n "$name" ]] && echo "$name" && return 0
    return 1
  fi

  local options
  options=$(echo "$outputs" | grep "^[[:space:]]*[0-9]\+\." | while read -r line; do
    local idx name desc
    idx=$(echo "$line" | grep -oE "^[[:space:]]*[0-9]+" | tr -d ' ')
    name=$(echo "$line" | sed -E 's/.*Name: ([^ ]+).*/\1/')
    desc=$(echo "$line" | sed -E 's/.*Description: ([^(]+).*/\1/')
    echo "${idx}. ${name} - ${desc}" | sed 's/[[:space:]]*$//'
  done)

  local selected
  selected=$(echo "$options" | rofi -dmenu -i -p "Monitor" -theme "$ROFI_THEME")
  [[ -z "$selected" ]] && return 1

  local idx
  idx=$(echo "$selected" | grep -oE "^[[:space:]]*[0-9]+" | tr -d ' ')
  local name
  name=$(echo "$outputs" | grep "^[[:space:]]*${idx}\." | sed -E 's/.*Name: ([^ ]+).*/\1/')
  echo "$name"
}

for cmd in rofi grim wf-recorder; do
  command -v "$cmd" >/dev/null || { notify "Falta: $cmd"; exit 1; }
done

if is_recording; then
  audio_mode=""
  [[ -f "$AUDIO_MODE_FILE" ]] && audio_mode=$(cat "$AUDIO_MODE_FILE")

  menu=$(printf '%s\n' \
    "Detener grabacion" \
    "Estado: $audio_mode" \
    | rofi -dmenu -i -p "⬤ GRABANDO" -theme "$ROFI_THEME")

  [[ "$menu" == "Detener grabacion" ]] && stop_recording
  exit 0
fi

audio_menu=$(printf '%s\n' \
  "Audio del PC" \
  "Microfono" \
  "PC + Microfono" \
  "🔇 Mute sistema" \
  | rofi -dmenu -i -p "Audio" -theme "$ROFI_THEME")

[[ -z "$audio_menu" ]] && exit 0

[[ "$audio_menu" == "🔇 Mute sistema" ]] && toggle_system_mute && exit 0

main_menu=$(printf '%s\n' \
  "Captura completa" \
  "Captura region" \
  "Grabar pantalla" \
  "Grabar region" \
  | rofi -dmenu -i -p "Pantalla" -theme "$ROFI_THEME")

[[ -z "$main_menu" ]] && exit 0

case "$main_menu" in
  "Captura completa")
    file="$SCREENSHOT_DIR/Screenshot-$(date +%F_%T).png"
    grim - | tee >(wl-copy) | { cat > "$file" && dunstify -i "$file" "Captura completa" -t 1500; }
    ;;
  "Captura region")
    region=$(slurp)
    [[ -z "$region" ]] && exit 0
    file="$SCREENSHOT_DIR/Screenshot-$(date +%F_%T).png"
    grim -g "$region" - | tee >(wl-copy) | { cat > "$file" && dunstify -i "$file" "Region capturada" -t 1500; }
    ;;
  "Grabar pantalla")
    screen=$(choose_screen) || exit 0
    [[ -z "$screen" ]] && exit 0
    file="$RECORD_DIR/record-$(date +%F_%T).mp4"
    start_recording "$file" "$audio_menu" "$screen"
    ;;
  "Grabar region")
    region=$(slurp)
    [[ -z "$region" ]] && exit 0
    screen=$(choose_screen) || exit 0
    file="$RECORD_DIR/record-$(date +%F_%T).mp4"
    start_recording "$file" "$audio_menu" "$screen" -g "$region"
    ;;
esac
