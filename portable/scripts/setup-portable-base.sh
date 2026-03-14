#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACMAN_LIST="$ROOT_DIR/packages/pacman.txt"
AUR_LIST="$ROOT_DIR/packages/aur.txt"

if ! command -v pacman >/dev/null 2>&1; then
  echo "ERROR: pacman not found. This script is for Arch Linux." >&2
  exit 1
fi

sudo pacman -Syu --needed --noconfirm - < "$PACMAN_LIST"

if command -v yay >/dev/null 2>&1; then
  yay -S --needed --noconfirm - < "$AUR_LIST"
else
  echo "WARN: yay not found, skipping AUR packages."
fi

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable NetworkManager.service
  sudo systemctl enable bluetooth.service
  systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service || true
fi

echo "Portable base setup completed."
