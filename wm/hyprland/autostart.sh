#!/usr/bin/env bash
set -e

# Espera a que Hyprland termine de levantar outputs
sleep 1

# --- Wallpaper (swww) ---
pkill swww-daemon 2>/dev/null || true
swww-daemon >/dev/null 2>&1 &
sleep 1

swww img -o HDMI-A-1 "/home/sandia/Imagenes/wallpapers/05. Paranoid Sweet.png" --transition-type none
swww img -o DP-2 "/home/sandia/Imagenes/wallpapers/05. Paranoid Sweet.png" --transition-type none

# --- EWW ---
eww kill 2>/dev/null || true
eww daemon >/dev/null 2>&1 &
sleep 0.5
eww open bar_widget_0
eww open bar_widget_1
