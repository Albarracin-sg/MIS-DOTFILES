#!/bin/bash
# Script para recargar la configuración de Eww

echo "Cerrando todas las ventanas de Eww..."
eww kill

echo "Iniciando el daemon de Eww..."
eww daemon

echo "Esperando un momento..."
sleep 1

echo "Iniciando barras..."
~/.config/eww/scripts/start_bars.sh

echo "Listo!"