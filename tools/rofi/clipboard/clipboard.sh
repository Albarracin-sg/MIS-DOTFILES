#!/usr/bin/env bash

set -euo pipefail

rofi_theme="$HOME/.config/rofi/themes/current.rasi"
if [[ ! -f "$rofi_theme" ]]; then
  rofi_theme="$HOME/.config/rofi/themes/tokyonight.rasi"
fi

rofi \
  -modi clipboard:~/.config/rofi/clipboard/cliphist-rofi \
  -show clipboard \
  -theme "$rofi_theme"
