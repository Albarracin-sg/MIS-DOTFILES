#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-generic}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_FILE="$ROOT_DIR/profiles/${PROFILE}.conf"
TARGET_FILE="$HOME/.config/hypr/profiles.conf"

if [ ! -f "$PROFILE_FILE" ]; then
  echo "ERROR: profile not found: $PROFILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET_FILE")"
cp "$PROFILE_FILE" "$TARGET_FILE"

hyprctl reload >/dev/null 2>&1 || true
echo "Applied profile: $PROFILE"
