#!/usr/bin/env bash

rofi_theme="$HOME/.config/rofi/themes/current.rasi"
if [[ ! -f "$rofi_theme" ]]; then
    rofi_theme="$HOME/.config/rofi/themes/tokyonight.rasi"
fi

rofi \
    -show emoji \
    -theme "$rofi_theme"
