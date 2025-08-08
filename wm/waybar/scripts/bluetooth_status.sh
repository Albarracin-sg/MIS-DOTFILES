#!/bin/bash

# Script para mostrar estado de Bluetooth en Waybar

# Verificar si bluetoothctl está disponible
if ! command -v bluetoothctl &>/dev/null; then
  echo '{"text": "", "class": "unavailable", "tooltip": "Bluetooth no disponible"}'
  exit 0
fi

# Obtener estado del adaptador Bluetooth
BT_STATUS=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

if [ "$BT_STATUS" != "yes" ]; then
  echo '{"text": "", "class": "disabled", "tooltip": "Bluetooth desactivado"}'
  exit 0
fi

# Obtener dispositivos conectados
CONNECTED_DEVICES=$(bluetoothctl devices Connected 2>/dev/null | wc -l)

if [ "$CONNECTED_DEVICES" -eq 0 ]; then
  echo '{"text": "", "class": "enabled", "tooltip": "Bluetooth activado - Sin dispositivos"}'
else
  # Obtener nombre del primer dispositivo conectado
  DEVICE_NAME=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)

  if [ "$CONNECTED_DEVICES" -eq 1 ]; then
    TOOLTIP="Conectado: $DEVICE_NAME"
    TEXT="$DEVICE_NAME"
  else
    TOOLTIP="$CONNECTED_DEVICES dispositivos conectados"
    TEXT="$CONNECTED_DEVICES"
  fi

  # Limitar longitud del texto
  if [ ${#TEXT} -gt 15 ]; then
    TEXT="${TEXT:0:12}..."
  fi

  echo "{\"text\": \"$TEXT\", \"class\": \"connected\", \"tooltip\": \"$TOOLTIP\"}"
fi
