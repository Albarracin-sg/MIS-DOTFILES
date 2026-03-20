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

# shellcheck disable=SC1090
source "$theme_file"

# Persist the active theme metadata for Hyprland/Eww helper scripts.
mkdir -p "$themes_dir"
cp "$theme_file" "$current_conf"

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

# Wallpaper priority:
# 1. mpvpaper for video themes
# 2. swww for image themes
# 3. hyprpaper as final fallback
if is_video_wallpaper "$THEME_WALLPAPER" && command -v mpvpaper >/dev/null 2>&1; then
  pkill -f mpvpaper >/dev/null 2>&1 || true
  pkill hyprpaper >/dev/null 2>&1 || true
  pkill swww-daemon >/dev/null 2>&1 || true
  sleep 0.2
  while IFS= read -r monitor; do
    [[ -n "$monitor" ]] || continue
    mpvpaper -f -p -o "no-audio loop keepaspect=yes panscan=1.0" "$monitor" "$THEME_WALLPAPER" >/dev/null 2>&1 & disown
  done < <(hyprctl monitors -j | jq -r '.[].name')
elif command -v swww >/dev/null 2>&1; then
  pkill -f mpvpaper >/dev/null 2>&1 || true
  pkill hyprpaper >/dev/null 2>&1 || true
  pkill swww-daemon >/dev/null 2>&1 || true
  swww-daemon >/dev/null 2>&1 &
  sleep 0.8
  while IFS= read -r monitor; do
    [[ -n "$monitor" ]] || continue
    swww img -o "$monitor" "$THEME_WALLPAPER" --transition-type none >/dev/null 2>&1 || true
  done < <(hyprctl monitors -j | jq -r '.[].name')
elif command -v hyprpaper >/dev/null 2>&1; then
  pkill -f mpvpaper >/dev/null 2>&1 || true
  pkill swww-daemon >/dev/null 2>&1 || true
  pkill hyprpaper >/dev/null 2>&1 || true
  sleep 0.2
  hyprpaper >/dev/null 2>&1 & disown
fi

if command -v eww >/dev/null 2>&1; then
  "$HOME/.config/eww/reload.sh" >/dev/null 2>&1 || true
fi

notify-send "Tema aplicado" "${THEME_NAME}" >/dev/null 2>&1 || true
