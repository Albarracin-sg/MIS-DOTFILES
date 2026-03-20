#!/usr/bin/env bash
set -euo pipefail

SCREENSHOT_DIR="$HOME/Imagenes/Screenshots"
RECORD_DIR="$HOME/Videos/Recordings"
STATE_DIR="$HOME/.cache/hypr-screenrec"
PID_FILE="$STATE_DIR/wf-recorder.pid"
OUT_FILE="$STATE_DIR/current-output.txt"
LOG_FILE="$STATE_DIR/wf-recorder.log"
AUDIO_ARGS=()
ROFI_THEME="$HOME/.config/rofi/themes/current.rasi"

if [[ ! -f "$ROFI_THEME" ]]; then
  ROFI_THEME="$HOME/.config/rofi/themes/tokyonight.rasi"
fi

mkdir -p "$SCREENSHOT_DIR" "$RECORD_DIR" "$STATE_DIR"

notify() {
  dunstify "$1" -t 1800
}

get_focused_output() {
  if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -n1
  fi
}

choose_audio_mode() {
  local mode
  local def_sink=""
  local def_source=""

  mode=$(printf '%s\n' \
    "Sin audio" \
    "Audio del PC" \
    "Microfono" \
    | rofi -dmenu -i -p "Audio grabacion" -theme "$ROFI_THEME")

  [[ -z "$mode" ]] && return 1

  AUDIO_ARGS=()

  case "$mode" in
    "Sin audio")
      AUDIO_ARGS=()
      ;;
    "Audio del PC")
      AUDIO_ARGS=(--audio)
      if command -v pactl >/dev/null 2>&1; then
        def_sink="$(pactl get-default-sink 2>/dev/null || true)"
        if [[ -n "$def_sink" ]]; then
          if pactl list short sources | awk '{print $2}' | grep -qx "${def_sink}.monitor"; then
            AUDIO_ARGS=("--audio=${def_sink}.monitor")
          fi
        fi
      fi
      ;;
    "Microfono")
      AUDIO_ARGS=(--audio)
      if command -v pactl >/dev/null 2>&1; then
        def_source="$(pactl get-default-source 2>/dev/null || true)"
        if [[ -n "$def_source" ]]; then
          if pactl list short sources | awk '{print $2}' | grep -qx "$def_source"; then
            AUDIO_ARGS=("--audio=$def_source")
          fi
        fi
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

copy_recording_to_clipboard() {
  local file="$1"

  if ! command -v wl-copy >/dev/null 2>&1; then
    return 0
  fi

  [[ -f "$file" ]] || return 0

  # Copiar como archivo (URI), compatible con pegar en apps
  if wl-copy --type text/uri-list <<<"file://$file"; then
    return 0
  fi

  # Fallback: copiar ruta como texto plano
  printf '%s' "$file" | wl-copy --type text/plain
}

is_recording() {
  [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

start_recording() {
  local target="$1"
  shift || true

  if is_recording; then
    notify "Ya hay una grabacion en curso"
    return 0
  fi

  local cmd=(wf-recorder -f "$target")
  if [[ "$#" -gt 0 ]]; then
    cmd+=("$@")
  fi

  "${cmd[@]}" >"$LOG_FILE" 2>&1 &
  local pid=$!
  disown "$pid" || true

  sleep 0.3
  if ! kill -0 "$pid" 2>/dev/null; then
    local err=""
    if [[ -f "$LOG_FILE" ]]; then
      err="$(tail -n 1 "$LOG_FILE" 2>/dev/null || true)"
    fi
    notify "No se pudo iniciar grabacion: ${err:-revisa wf-recorder}"
    return 1
  fi

  printf '%s\n' "$pid" > "$PID_FILE"
  printf '%s\n' "$target" > "$OUT_FILE"
  notify "Grabando..."
}

stop_recording() {
  if is_recording; then
    local pid
    local file=""
    pid="$(cat "$PID_FILE")"
    kill -INT "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
    if [[ -f "$OUT_FILE" ]]; then
      file="$(cat "$OUT_FILE")"
      # Espera breve para asegurar flush del archivo
      sleep 0.4
      copy_recording_to_clipboard "$file"
      notify "Grabacion guardada. Listo para pegar como archivo (Ctrl+V)"
      rm -f "$OUT_FILE"
    else
      notify "Grabacion detenida"
    fi
  else
    pkill -INT wf-recorder 2>/dev/null || true
    notify "No habia grabacion activa"
  fi
}

for cmd in rofi grim wf-recorder; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    notify "Falta dependencia: $cmd"
    exit 1
  fi
done

menu=$(printf '%s
' \
  "Captura completa" \
  "Captura region" \
  "Grabar pantalla" \
  "Grabar region" \
  "Detener grabacion" \
  | rofi -dmenu -i -p "Pantalla" -theme "$ROFI_THEME")

if [[ -z "$menu" ]]; then
  exit 0
fi

case "$menu" in
  "Captura completa")
    file="$SCREENSHOT_DIR/Screenshot-$(date +%F_%T).png"
    if command -v wl-copy >/dev/null 2>&1; then
      grim - | tee >(wl-copy) | { cat > "$file" && dunstify -i "$file" "Pantalla completa" -t 1500; }
    else
      grim "$file" && dunstify -i "$file" "Pantalla completa" -t 1500
    fi
    ;;
  "Captura region")
    if ! command -v slurp >/dev/null 2>&1; then
      notify "Falta dependencia: slurp"
      exit 1
    fi
    region="$(slurp)"
    [[ -z "$region" ]] && exit 0
    file="$SCREENSHOT_DIR/Screenshot-$(date +%F_%T).png"
    if command -v wl-copy >/dev/null 2>&1; then
      grim -g "$region" - | tee >(wl-copy) | { cat > "$file" && dunstify -i "$file" "Region capturada" -t 1500; }
    else
      grim -g "$region" "$file" && dunstify -i "$file" "Region capturada" -t 1500
    fi
    ;;
  "Grabar pantalla")
    choose_audio_mode || exit 0
    file="$RECORD_DIR/record-$(date +%F_%T).mp4"
    output="$(get_focused_output || true)"
    if [[ -n "$output" ]]; then
      start_recording "$file" "${AUDIO_ARGS[@]}" -o "$output"
    else
      start_recording "$file" "${AUDIO_ARGS[@]}"
    fi
    ;;
  "Grabar region")
    choose_audio_mode || exit 0
    if ! command -v slurp >/dev/null 2>&1; then
      notify "Falta dependencia: slurp"
      exit 1
    fi
    region="$(slurp)"
    [[ -z "$region" ]] && exit 0
    file="$RECORD_DIR/record-$(date +%F_%T).mp4"
    start_recording "$file" "${AUDIO_ARGS[@]}" -g "$region"
    ;;
  "Detener grabacion")
    stop_recording
    ;;
esac
