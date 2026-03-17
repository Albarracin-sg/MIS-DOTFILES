#!/usr/bin/env bash
set -euo pipefail

# Espera a que Hyprland termine de levantar outputs
sleep 1

pick_wallpaper() {
  local candidates=(
    "$HOME/Imagenes/Wallpapers/1769684794.mp4"
    "$HOME/Imagenes/Wallpapers/05. Paranoid Sweet.png"
  )
  local candidate

  for candidate in "${candidates[@]}"; do
    if is_video_wallpaper "$candidate" && ! command -v mpvpaper >/dev/null 2>&1; then
      continue
    fi

    if [ -f "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

is_video_wallpaper() {
  case "$1" in
    *.mp4|*.mkv|*.webm|*.mov)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

if wallpaper=$(pick_wallpaper); then
  if is_video_wallpaper "$wallpaper" && command -v mpvpaper >/dev/null 2>&1; then
    pkill swww-daemon 2>/dev/null || true
    pkill mpvpaper 2>/dev/null || true
    mpvpaper -f -p -o "no-audio loop keepaspect=yes panscan=1.0" "*" "$wallpaper" >/dev/null 2>&1 || true
  else
    pkill mpvpaper 2>/dev/null || true
    pkill swww-daemon 2>/dev/null || true
    swww-daemon >/dev/null 2>&1 &
    sleep 1
    while IFS= read -r monitor; do
      [ -n "$monitor" ] || continue
      swww img -o "$monitor" "$wallpaper" --transition-type none >/dev/null 2>&1 || true
    done < <(hyprctl monitors -j | jq -r '.[].name')
  fi
fi

# --- EWW ---
if command -v eww >/dev/null 2>&1; then
  pkill -x eww 2>/dev/null || true
  eww kill 2>/dev/null || true
  sleep 1
  eww daemon >/dev/null 2>&1 &
  sleep 1
  "$HOME/.config/eww/scripts/start_bars.sh" >/dev/null 2>&1 || true
else
  echo "WARN: eww no esta instalado; se omite la barra." >&2
fi
