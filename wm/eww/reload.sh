#!/usr/bin/env bash
set -euo pipefail

echo "Reiniciando EWW por completo..."
pkill -x eww 2>/dev/null || true
eww kill 2>/dev/null || true
sleep 1

echo "Iniciando daemon limpio..."
eww daemon >/dev/null 2>&1 &
sleep 1

echo "Levantando barras correctas..."
"$HOME/.config/eww/scripts/start_bars.sh"

echo "Listo"
