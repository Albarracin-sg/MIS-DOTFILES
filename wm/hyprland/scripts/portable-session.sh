#!/usr/bin/env bash
set -euo pipefail

"$HOME/.config/hypr/scripts/detect-gpu.sh"
#"$HOME/.config/hypr/scripts/detect-monitors.sh"

# Apply generated monitor/GPU config in this session.
hyprctl reload >/dev/null 2>&1 || true

# Start EWW bars for all connected monitors.
if command -v eww >/dev/null 2>&1; then
  eww kill >/dev/null 2>&1 || true
  eww daemon >/dev/null 2>&1 || true
  sleep 0.3
  if [ -x "$HOME/.config/eww/scripts/start_bars.sh" ]; then
    "$HOME/.config/eww/scripts/start_bars.sh" >/dev/null 2>&1 || true
  else
    eww open bar_widget_0 >/dev/null 2>&1 || true
  fi
fi
