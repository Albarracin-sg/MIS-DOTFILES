#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="/boot/grub/themes/crossgrub"
THEME_REPO="https://github.com/krypciak/crossgrub.git"

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: run as root (sudo)." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git not found." >&2
  exit 1
fi

mkdir -p /boot/grub/themes

if [ ! -f "$THEME_DIR/theme.txt" ]; then
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  git clone --depth=1 "$THEME_REPO" "$TMP_DIR/crossgrub"
  cp -a "$TMP_DIR/crossgrub" "$THEME_DIR"
fi

if [ ! -f /etc/default/grub ]; then
  touch /etc/default/grub
fi

if grep -q '^GRUB_THEME=' /etc/default/grub; then
  sed -i 's|^GRUB_THEME=.*|GRUB_THEME=/boot/grub/themes/crossgrub/theme.txt|' /etc/default/grub
else
  printf '\nGRUB_THEME=/boot/grub/themes/crossgrub/theme.txt\n' >> /etc/default/grub
fi

echo "Crossgrub theme ready at $THEME_DIR"
