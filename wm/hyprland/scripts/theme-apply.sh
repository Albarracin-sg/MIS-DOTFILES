#!/usr/bin/env bash

set -euo pipefail

# Runtime files generated from the selected theme.
# The source of truth lives in `themes/<slug>/...` inside the dotfiles repo.
themes_dir="$HOME/.config/hypr/themes"
kitty_current="$HOME/.config/kitty/current-theme.conf"
rofi_current="$HOME/.config/rofi/themes/current.rasi"
eww_config_dir="$HOME/.config/eww/current"
eww_current_yuck="$eww_config_dir/eww.yuck"
eww_current_scss="$eww_config_dir/eww.scss"
eww_current_css="$eww_config_dir/eww.css"
starship_runtime_dir="$HOME/.config/starship"
starship_current="$starship_runtime_dir/current.toml"
current_conf="$themes_dir/current.conf"
current_theme="$themes_dir/current.theme"
script_dir="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
themes_repo_dir="$repo_root/themes"

usage() {
  printf 'Uso: %s <slug-del-tema>\n' "$0"
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

slug="$1"
theme_dir="$themes_repo_dir/$slug"
theme_file="$theme_dir/wm/hyprland/theme.conf"

if [[ ! -f "$theme_file" ]]; then
  printf 'Tema no encontrado: %s\n' "$slug" >&2
  exit 1
fi

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

resolve_static_wallpaper() {
  local requested_wallpaper="$1"
  local wallpapers_dir="$HOME/Imagenes/Wallpapers"
  local preferred_fallback="$wallpapers_dir/tokyo.jpg"
  local candidates=()

  if [[ -n "$requested_wallpaper" ]] && [[ -f "$requested_wallpaper" ]] && is_static_wallpaper "$requested_wallpaper"; then
    printf '%s\n' "$requested_wallpaper"
    return 0
  fi

  if [[ -f "$preferred_fallback" ]] && is_static_wallpaper "$preferred_fallback"; then
    printf '%s\n' "$preferred_fallback"
    return 0
  fi

  if [[ -d "$wallpapers_dir" ]]; then
    shopt -s nullglob
    candidates=(
      "$wallpapers_dir"/*.png
      "$wallpapers_dir"/*.jpg
      "$wallpapers_dir"/*.jpeg
      "$wallpapers_dir"/*.webp
      "$wallpapers_dir"/*.bmp
    )
    shopt -u nullglob

    if [[ ${#candidates[@]} -gt 0 ]]; then
      printf '%s\n' "${candidates[0]}"
      return 0
    fi
  fi

  return 1
}

apply_wallpaper_with_swww() {
  local wallpaper="$1"

  pkill -f mpvpaper >/dev/null 2>&1 || true
  pkill hyprpaper >/dev/null 2>&1 || true
  pkill swww-daemon >/dev/null 2>&1 || true

  swww-daemon >/dev/null 2>&1 &
  sleep 0.8

  while IFS= read -r monitor; do
    [[ -n "$monitor" ]] || continue
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

  pkill -f mpvpaper >/dev/null 2>&1 || true
  pkill swww-daemon >/dev/null 2>&1 || true
  pkill hyprpaper >/dev/null 2>&1 || true
  sleep 0.2

  hyprpaper -c "$runtime_config" >/dev/null 2>&1 & disown
}

# shellcheck disable=SC1090
source "$theme_file"

if resolved_wallpaper=$(resolve_static_wallpaper "${THEME_WALLPAPER:-}"); then
  THEME_WALLPAPER="$resolved_wallpaper"
fi

# Persist the active theme metadata for Hyprland/Eww helper scripts.
mkdir -p "$themes_dir"
cp "$theme_file" "$current_conf"

python - "$current_conf" "$THEME_WALLPAPER" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
wallpaper = sys.argv[2]
text = path.read_text()
replacement = f'THEME_WALLPAPER="{wallpaper}"'

if re.search(r'^THEME_WALLPAPER=.*$', text, flags=re.MULTILINE):
    text = re.sub(r'^THEME_WALLPAPER=.*$', replacement, text, flags=re.MULTILINE)
else:
    if text and not text.endswith('\n'):
        text += '\n'
    text += replacement + '\n'

path.write_text(text)
PY

# Apply app-specific runtime files.
cp "$THEME_KITTY_FILE" "$kitty_current"
cp "$THEME_ROFI_FILE" "$rofi_current"

mkdir -p "$eww_config_dir"
# Reuse the shared Eww scripts directory but swap the visual config per theme.
ln -sfn "$HOME/.config/eww/scripts" "$eww_config_dir/scripts"

# Remove any stale compiled CSS so Eww always uses the theme SCSS we just copied.
rm -f "$eww_current_css"

if [[ -n "${THEME_EWW_YUCK_FILE:-}" ]] && [[ -f "$THEME_EWW_YUCK_FILE" ]]; then
  cp "$THEME_EWW_YUCK_FILE" "$eww_current_yuck"
fi

if [[ -n "${THEME_EWW_FILE:-}" ]] && [[ -f "$THEME_EWW_FILE" ]]; then
  cp "$THEME_EWW_FILE" "$eww_current_scss"
fi

mkdir -p "$starship_runtime_dir"
if [[ -n "${THEME_STARSHIP_FILE:-}" ]] && [[ -f "$THEME_STARSHIP_FILE" ]]; then
  cp "$THEME_STARSHIP_FILE" "$starship_current"
fi

# Export variables consumed by hyprpaper/hyprlock wrappers.
cat > "$current_theme" <<EOF
\$theme_active_border = ${THEME_HYPR_ACTIVE_BORDER}
\$theme_inactive_border = ${THEME_HYPR_INACTIVE_BORDER}
\$theme_wallpaper = "${THEME_WALLPAPER}"
\$theme_hyprlock_wallpaper = "${THEME_HYPRLOCK_WALLPAPER}"
\$theme_hyprlock_font_color = ${THEME_HYPRLOCK_FONT_COLOR}
\$theme_hyprlock_check_color = ${THEME_HYPRLOCK_CHECK_COLOR}
\$theme_hyprlock_fail_color = ${THEME_HYPRLOCK_FAIL_COLOR}
\$theme_hyprlock_text_primary = ${THEME_HYPRLOCK_TEXT_PRIMARY}
\$theme_hyprlock_accent = ${THEME_HYPRLOCK_ACCENT}
\$theme_hyprlock_title = ${THEME_HYPRLOCK_TITLE}
\$theme_hyprlock_subtitle = ${THEME_HYPRLOCK_SUBTITLE}
EOF

if command -v kitty >/dev/null 2>&1; then
  kitty @ set-colors -a "$kitty_current" >/dev/null 2>&1 || true
fi

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl keyword general:col.active_border "$THEME_HYPR_ACTIVE_BORDER" >/dev/null 2>&1 || true
  hyprctl keyword general:col.inactive_border "$THEME_HYPR_INACTIVE_BORDER" >/dev/null 2>&1 || true
fi

# Wallpaper priority:
# 1. swww for static images
# 2. hyprpaper as fallback for static images
if command -v swww >/dev/null 2>&1; then
  apply_wallpaper_with_swww "$THEME_WALLPAPER"
elif command -v hyprpaper >/dev/null 2>&1; then
  apply_wallpaper_with_hyprpaper "$THEME_WALLPAPER"
fi

if command -v eww >/dev/null 2>&1; then
  "$HOME/.config/eww/reload.sh" >/dev/null 2>&1 || true
fi

notify-send "Tema aplicado" "${THEME_NAME}" >/dev/null 2>&1 || true
