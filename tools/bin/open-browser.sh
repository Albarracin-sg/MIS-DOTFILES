#!/usr/bin/env bash
set -euo pipefail

if command -v zen-browser >/dev/null 2>&1; then
  exec zen-browser "$@"
fi

if command -v firefox >/dev/null 2>&1; then
  exec firefox "$@"
fi

echo "ERROR: no hay navegador disponible (zen-browser/firefox)." >&2
exit 1
