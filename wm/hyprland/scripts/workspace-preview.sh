#!/usr/bin/env bash
set -euo pipefail

# Try hyprexpo first
if hyprctl dispatch hyprexpo:expo toggle >/dev/null 2>&1; then
  exit 0
fi

# Try generic overview dispatcher if available
if hyprctl dispatch overview:toggle all >/dev/null 2>&1; then
  exit 0
fi

# Fallback + hint
if command -v dunstify >/dev/null 2>&1; then
  dunstify "Workspace preview no disponible" "Instala y habilita hyprexpo para previews" -t 2200
fi
