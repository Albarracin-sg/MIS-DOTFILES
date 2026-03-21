#!/usr/bin/env bash
set -euo pipefail

# Eww always runs from a generated runtime config.
# That lets each theme ship its own `eww.yuck` / `eww.scss` safely.

# Fix common SCSS errors (spacing is not valid CSS, must be margin)
fix_eww_scss() {
  local file="$1"
  if [[ -f "$file" ]]; then
    # Fix spacing: Npx; in SCSS (not :spacing in yuck which is valid)
    sed -i 's/spacing:\s*[0-9]*px\s*;/margin: 0 5px;/g' "$file"
    # Also fix letter-spacing which should be fine, but ensure no trailing semicolon issues
    echo "  Fixed SCSS: $file"
  fi
}

echo "Reiniciando EWW por completo..."
pkill -x eww 2>/dev/null || true
eww kill 2>/dev/null || true
sleep 1

config_dir="$HOME/.config/eww/current"
rm -f "$config_dir/eww.css"
if [[ ! -f "$config_dir/eww.yuck" ]]; then
  mkdir -p "$config_dir"
  ln -sfn "$HOME/.config/eww/scripts" "$config_dir/scripts"
  # Tokyo Night acts as the safe bootstrap theme if runtime files do not exist yet.
  cp "$HOME/TOOLS/MIS-DOTFILES/themes/tokyonight/wm/eww/eww.yuck" "$config_dir/eww.yuck"
  cp "$HOME/TOOLS/MIS-DOTFILES/themes/tokyonight/wm/eww/eww.scss" "$config_dir/eww.scss"
fi

# Always fix SCSS errors after copying
fix_eww_scss "$config_dir/eww.scss"

echo "Iniciando daemon limpio..."
eww -c "$config_dir" daemon >/dev/null 2>&1 &
sleep 1

echo "Levantando barras correctas..."
EWW_CONFIG_DIR="$config_dir" "$HOME/.config/eww/scripts/start_bars.sh"

echo "Listo"
