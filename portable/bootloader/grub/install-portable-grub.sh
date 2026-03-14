#!/usr/bin/env bash
set -euo pipefail

EFI_DIR="${1:-/boot}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v grub-install >/dev/null 2>&1; then
  echo "ERROR: grub-install not found." >&2
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: run as root (sudo)." >&2
  exit 1
fi

if [ ! -d "$EFI_DIR" ]; then
  echo "ERROR: EFI dir not found: $EFI_DIR" >&2
  exit 1
fi

"$SCRIPT_DIR/install-crossgrub-theme.sh"

cp "$SCRIPT_DIR/grub.default" /etc/default/grub
grub-install --target=x86_64-efi --efi-directory="$EFI_DIR" --removable
grub-mkconfig -o /boot/grub/grub.cfg

echo "Portable GRUB installed with --removable and Crossgrub theme"
