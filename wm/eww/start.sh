#!/bin/bash

set -euo pipefail

theme_file="$HOME/.config/hypr/themes/current.conf"
theme_name="Tokyo Night"
theme_bar_orientation="h"
theme_bar_class=""
theme_section_orientation="h"
theme_center_orientation="h"
theme_metrics_orientation="h"
theme_workspaces_orientation="h"
theme_show_now_playing="true"
theme_show_time_date="true"
theme_metrics_show_separators="true"
theme_bar_anchor="top center"
theme_bar_width="99.5%"
theme_bar_height="44px"
theme_bar_x="0px"
theme_bar_y="0px"

if [[ -f "$theme_file" ]]; then
  # shellcheck disable=SC1090
  source "$theme_file"
  theme_name="${THEME_NAME:-$theme_name}"
  theme_bar_orientation="${THEME_EWW_BAR_ORIENTATION:-$theme_bar_orientation}"
  theme_bar_class="${THEME_EWW_BAR_CLASS:-$theme_bar_class}"
  theme_section_orientation="${THEME_EWW_SECTION_ORIENTATION:-$theme_section_orientation}"
  theme_center_orientation="${THEME_EWW_CENTER_ORIENTATION:-$theme_center_orientation}"
  theme_metrics_orientation="${THEME_EWW_METRICS_ORIENTATION:-$theme_metrics_orientation}"
  theme_workspaces_orientation="${THEME_EWW_WORKSPACES_ORIENTATION:-$theme_workspaces_orientation}"
  theme_show_now_playing="${THEME_EWW_SHOW_NOW_PLAYING:-$theme_show_now_playing}"
  theme_show_time_date="${THEME_EWW_SHOW_TIME_DATE:-$theme_show_time_date}"
  theme_metrics_show_separators="${THEME_EWW_METRICS_SHOW_SEPARATORS:-$theme_metrics_show_separators}"
  theme_bar_anchor="${THEME_EWW_BAR_ANCHOR:-$theme_bar_anchor}"
  theme_bar_width="${THEME_EWW_BAR_WIDTH:-$theme_bar_width}"
  theme_bar_height="${THEME_EWW_BAR_HEIGHT:-$theme_bar_height}"
  theme_bar_x="${THEME_EWW_BAR_X:-$theme_bar_x}"
  theme_bar_y="${THEME_EWW_BAR_Y:-$theme_bar_y}"
fi

# Cerrar instancias previas
eww close-all 2>/dev/null || true

window_prefix="bar_widget"
if [[ "$theme_bar_orientation" == "v" ]]; then
  window_prefix="bar_widget_vertical"
fi

eww update \
  current_theme_name="$theme_name" \
  current_theme_bar_orientation="$theme_bar_orientation" \
  current_theme_bar_class="$theme_bar_class" \
  current_theme_section_orientation="$theme_section_orientation" \
  current_theme_center_orientation="$theme_center_orientation" \
  current_theme_metrics_orientation="$theme_metrics_orientation" \
  current_theme_workspaces_orientation="$theme_workspaces_orientation" \
  current_theme_show_now_playing="$theme_show_now_playing" \
  current_theme_show_time_date="$theme_show_time_date" \
  current_theme_metrics_show_separators="$theme_metrics_show_separators" \
  current_theme_bar_anchor="$theme_bar_anchor" \
  current_theme_bar_width="$theme_bar_width" \
  current_theme_bar_height="$theme_bar_height" \
  current_theme_bar_x="$theme_bar_x" \
  current_theme_bar_y="$theme_bar_y" 2>/dev/null || true

# Detectar número de monitores
monitor_count=$(hyprctl monitors -j 2>/dev/null | jq 'length' || echo "1")

# Abrir barras según monitores disponibles
if [ "$monitor_count" -ge 1 ]; then
    eww open "${window_prefix}_0"
fi

if [ "$monitor_count" -ge 2 ]; then
    eww open "${window_prefix}_1"
fi
