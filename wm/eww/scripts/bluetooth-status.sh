#!/bin/bash
# Script para obtener estado de Bluetooth (SIN ESPACIOS EN JSON)
# Guarda como: ~/.config/eww/scripts/bluetooth-status.sh

if ! command -v bluetoothctl &>/dev/null; then
  echo '{"icon":"","status":"unavailable","tooltip":"Bluetooth no disponible"}'
  exit 0
fi

BT_POWER=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

if [ "$BT_POWER" != "yes" ]; then
  echo '{"icon":"","status":"disabled","tooltip":"Bluetooth desactivado"}'
  exit 0
fi

CONNECTED=$(bluetoothctl devices Connected 2>/dev/null | wc -l)

if [ "$CONNECTED" -eq 0 ]; then
  echo '{"icon":"","status":"enabled","tooltip":"Bluetooth activado"}'
else
  DEVICE=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)
  echo "{\"icon\":\"\",\"status\":\"connected\",\"tooltip\":\"Conectado: $DEVICE\"}"
fi
