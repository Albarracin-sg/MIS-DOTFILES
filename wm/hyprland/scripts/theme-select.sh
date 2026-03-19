#!/usr/bin/env bash

set -euo pipefail

themes_runtime_dir="$HOME/.config/hypr/themes"
script_dir="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
themes_repo_dir="$repo_root/themes"
apply_script="$HOME/.config/hypr/scripts/theme-apply.sh"
rofi_theme="$HOME/.config/rofi/themes/current.rasi"

if [[ ! -f "$rofi_theme" ]]; then
  rofi_theme="$HOME/.config/rofi/themes/tokyonight.rasi"
fi

current_slug=""
if [[ -f "$themes_runtime_dir/current.conf" ]]; then
  # shellcheck disable=SC1090
  source "$themes_runtime_dir/current.conf"
  current_slug="${THEME_SLUG:-}"
fi

selection="$({
  while IFS= read -r theme_file; do
    unset THEME_SLUG THEME_NAME THEME_DESCRIPTION
    # shellcheck disable=SC1090
    source "$theme_file"
    marker="  "
    if [[ "${THEME_SLUG:-}" == "$current_slug" ]]; then
      marker="• "
    fi
    printf '%s%s\t%s\t%s\n' "$marker" "${THEME_NAME}" "${THEME_DESCRIPTION}" "$theme_file"
  done < <(printf '%s\n' "$themes_repo_dir"/*/wm/hyprland/theme.conf | sort)
} | rofi \
  -dmenu \
  -i \
  -markup-rows \
  -p 'Tema' \
  -matching fuzzy \
  -theme "$rofi_theme")"

[[ -n "$selection" ]] || exit 0

theme_file="${selection##*$'\t'}"
theme_dir="$(dirname "$(dirname "$(dirname "$theme_file")")")"
slug="$(basename "$theme_dir")"

"$apply_script" "$slug"
