#!/usr/bin/env bash
set -euo pipefail

echo "Iniciando EWW..."

eww close-all || true
for window in bar_widget_0 bar_widget_1; do
  eww close "$window" 2>/dev/null || true
done
sleep 0.5

monitor_count=$(hyprctl monitors -j | jq 'length')
opened=0

if [ "$monitor_count" -ge 1 ]; then
  echo "Abriendo bar_widget_0 en monitor 0"
  eww open bar_widget_0 || true
  opened=$((opened + 1))
fi

if [ "$monitor_count" -ge 2 ]; then
  echo "Abriendo bar_widget_1 en monitor 1"
  eww open bar_widget_1 || true
  opened=$((opened + 1))
fi

echo "EWW iniciado en ${opened} monitor(es)"
