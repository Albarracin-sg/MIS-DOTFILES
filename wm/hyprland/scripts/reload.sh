#!/usr/bin/env bash

hyprctl reload >/dev/null 2>&1 || true

if [ -x "$HOME/.config/hypr/autostart.sh" ]; then
  nohup "$HOME/.config/hypr/autostart.sh" >/dev/null 2>&1 &
fi
