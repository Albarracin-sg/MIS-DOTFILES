#!/usr/bin/env bash

dir="$HOME/.config/rofi/themes"
theme='current'

pkill -x rofi >/dev/null 2>&1 || true
sleep 0.12

rofi \
  -show drun \
  -show-icons \
  -matching fuzzy \
  -theme "${dir}/${theme}.rasi"
