#!/usr/bin/env bash

set -euo pipefail

# Make sure to edit the path of snippets.txt.
# Then, create snippets.txt and add important snippet text.
# You can store and copy text snippets that you frequently use here.
# Think of it as a pinned clipboard.
# Note: wl-copy is part of wl-clipboard.
# https://github.com/sameemul-haque/dotfiles/tree/master/.config/rofi/snippet
#                    __  _                      _                      _   
#                   / _|(_)                    (_)                    | |  
#      _ __   ___  | |_  _          ___  _ __   _  _ __   _ __    ___ | |_ 
#     | '__| / _ \ |  _|| | ______ / __|| '_ \ | || '_ \ | '_ \  / _ \| __|
#     | |   | (_) || |  | ||______|\__ \| | | || || |_) || |_) ||  __/| |_ 
#     |_|    \___/ |_|  |_|        |___/|_| |_||_|| .__/ | .__/  \___| \__|
#                                                 | |    | |               
#                                                 |_|    |_|               

rofi_theme="$HOME/.config/rofi/themes/current.rasi"
if [[ ! -f "$rofi_theme" ]]; then
  rofi_theme="$HOME/.config/rofi/themes/tokyonight.rasi"
fi

selection=$(rofi -i -theme "$rofi_theme" -dmenu "$@" < /path-to-your/snippets.txt -p "󰅍")
snippet=$(echo $selection)
echo -n "$snippet" | wl-copy
sleep 0.1
