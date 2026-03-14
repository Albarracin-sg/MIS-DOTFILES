#!/usr/bin/env bash
set -euo pipefail

# Preview switcher (hyprswitch) with graceful fallback
if command -v hyprswitch >/dev/null 2>&1; then
  hyprswitch 2>/dev/null || hyprswitch gui 2>/dev/null || true
  exit 0
fi

# Fallback without preview
hyprctl dispatch cyclenext
