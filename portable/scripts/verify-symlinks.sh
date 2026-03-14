#!/usr/bin/env bash
set -euo pipefail

declare -a LINKS=(
  "$HOME/.zshrc"
  "$HOME/.config/kitty"
  "$HOME/.config/nvim"
  "$HOME/.config/hypr"
  "$HOME/.config/waybar"
  "$HOME/.config/eww"
  "$HOME/.config/rofi"
  "$HOME/.config/fastfetch"
  "$HOME/.config/opencode"
  "$HOME/.local/share/mis-dotfiles-portable"
)

FAIL=0
for LINK in "${LINKS[@]}"; do
  if [ ! -L "$LINK" ]; then
    echo "MISSING SYMLINK: $LINK"
    FAIL=1
  fi
done

if [ "$FAIL" -ne 0 ]; then
  exit 1
fi

echo "All required symlinks are present."
