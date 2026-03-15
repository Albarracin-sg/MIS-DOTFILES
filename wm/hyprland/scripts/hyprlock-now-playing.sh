#!/usr/bin/env bash
set -euo pipefail

mode="${1:-title}"

if ! playerctl metadata --format '{{title}}' >/dev/null 2>&1; then
  exit 0
fi

case "$mode" in
  status)
    status=$(playerctl status 2>/dev/null || true)
    if [ -n "$status" ]; then
      printf '%s\n' "$status"
    fi
    ;;
  status_label)
    status=$(playerctl status 2>/dev/null || true)
    case "$status" in
      Playing)
        printf '%s\n' '󰐊 Now Playing'
        ;;
      Paused)
        printf '%s\n' '󰏤 Paused'
        ;;
    esac
    ;;
  title)
    playerctl metadata --format '{{title}}' 2>/dev/null | cut -c1-40
    ;;
  artist)
    artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null || true)
    if [ -n "$artist" ]; then
      printf '%s\n' "$artist" | cut -c1-44
    fi
    ;;
esac
