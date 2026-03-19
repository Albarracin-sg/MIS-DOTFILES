#!/usr/bin/env bash
set -euo pipefail

echo "Reiniciando EWW por completo..."
pkill -x eww 2>/dev/null || true
eww kill 2>/dev/null || true
sleep 1

config_dir="$HOME/.config/eww/current"
if [[ ! -f "$config_dir/eww.yuck" ]]; then
  mkdir -p "$config_dir"
  ln -sfn "$HOME/.config/eww/scripts" "$config_dir/scripts"
  cp "$HOME/TOOLS/MIS-DOTFILES/themes/tokyonight/wm/eww/eww.yuck" "$config_dir/eww.yuck"
  cp "$HOME/TOOLS/MIS-DOTFILES/themes/tokyonight/wm/eww/eww.scss" "$config_dir/eww.scss"
fi

echo "Iniciando daemon limpio..."
eww -c "$config_dir" daemon >/dev/null 2>&1 &
sleep 1

echo "Levantando barras correctas..."
"$HOME/.config/eww/scripts/start_bars.sh"

echo "Listo"
