#!/usr/bin/env bash
set -euo pipefail

hyprctl switchxkblayout at-translated-set-2-keyboard 0 && ~/.config/hypr/scripts/hyprlock-adaptive.sh
