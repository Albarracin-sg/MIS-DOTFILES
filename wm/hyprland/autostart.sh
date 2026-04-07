#!/usr/bin/env bash
set -euo pipefail

# Espera a que Hyprland termine de levantar outputs
sleep 1

is_static_wallpaper() {
  case "$1" in
    *.png|*.jpg|*.jpeg|*.webp|*.bmp)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

pick_wallpaper() {
  local wallpapers_dir="$HOME/Imagenes/Wallpapers"
  local current_theme_file="$HOME/.config/hypr/themes/current.conf"
  local candidates=()
  local wallpaper_count
  local random_index

  if [ -f "$current_theme_file" ]; then
    # shellcheck disable=SC1090
    source "$current_theme_file"
    if [ -n "${THEME_WALLPAPER:-}" ] && [ -f "$THEME_WALLPAPER" ] && is_static_wallpaper "$THEME_WALLPAPER"; then
      printf '%s\n' "$THEME_WALLPAPER"
      return 0
    fi
  fi

  if [ -d "$wallpapers_dir" ]; then
    shopt -s nullglob
    candidates+=(
      "$wallpapers_dir"/*.png
      "$wallpapers_dir"/*.jpg
      "$wallpapers_dir"/*.jpeg
      "$wallpapers_dir"/*.webp
      "$wallpapers_dir"/*.bmp
    )
    shopt -u nullglob
  fi

  wallpaper_count=${#candidates[@]}
  if [ "$wallpaper_count" -eq 0 ]; then
    return 1
  fi

  random_index=$((RANDOM % wallpaper_count))
  printf '%s\n' "${candidates[$random_index]}"
  return 0

}

apply_wallpaper_with_swww() {
  local wallpaper="$1"

  pkill -f mpvpaper 2>/dev/null || true
  pkill hyprpaper 2>/dev/null || true
  pkill swww-daemon 2>/dev/null || true

  swww-daemon >/dev/null 2>&1 &
  sleep 1

  while IFS= read -r monitor; do
    [ -n "$monitor" ] || continue
    swww img -o "$monitor" "$wallpaper" --transition-type none >/dev/null 2>&1 || true
  done < <(hyprctl monitors -j | jq -r '.[].name')
}

apply_wallpaper_with_hyprpaper() {
  local wallpaper="$1"
  local runtime_config="$HOME/.config/hypr/.runtime-hyprpaper.conf"
  local safe_wallpaper_link="$HOME/.cache/hyprpaper-current-wallpaper"

  mkdir -p "$HOME/.cache"
  ln -sfn "$wallpaper" "$safe_wallpaper_link"

  {
    printf 'wallpaper {\n'
    printf '  monitor = \n'
    printf '  path = %s\n' "$safe_wallpaper_link"
    printf '  fit_mode = cover\n'
    printf '}\n'
    printf 'splash = false\n'
    printf 'ipc = true\n'
  } > "$runtime_config"

  pkill -f mpvpaper 2>/dev/null || true
  pkill swww-daemon 2>/dev/null || true
  pkill hyprpaper 2>/dev/null || true

  hyprpaper -c "$runtime_config" >/dev/null 2>&1 & disown
}

if wallpaper=$(pick_wallpaper); then
  if command -v swww >/dev/null 2>&1; then
    apply_wallpaper_with_swww "$wallpaper"
  elif command -v hyprpaper >/dev/null 2>&1; then
    apply_wallpaper_with_hyprpaper "$wallpaper"
  else
    echo "WARN: no hay backend de wallpaper instalado (swww/hyprpaper)." >&2
  fi
fi

if [ -f "$HOME/.config/hypr/themes/current.conf" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.config/hypr/themes/current.conf"
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl keyword general:col.active_border "${THEME_HYPR_ACTIVE_BORDER:-0xffcba6f7}" >/dev/null 2>&1 || true
    hyprctl keyword general:col.inactive_border "${THEME_HYPR_INACTIVE_BORDER:-0xff313244}" >/dev/null 2>&1 || true
  fi
fi

# --- EWW ---
if command -v eww >/dev/null 2>&1; then
  "$HOME/.config/eww/reload.sh" >/dev/null 2>&1 || true
else
  echo "WARN: eww no esta instalado; se omite la barra." >&2
fi
