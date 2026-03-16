#!/bin/bash

# Cerrar instancias previas
eww close-all 2>/dev/null || true

# Detectar número de monitores
monitor_count=$(hyprctl monitors -j 2>/dev/null | jq 'length' || echo "1")

# Abrir barras según monitores disponibles
if [ "$monitor_count" -ge 1 ]; then
    eww open bar_widget_0
fi

if [ "$monitor_count" -ge 2 ]; then
    eww open bar_widget_1
fi
