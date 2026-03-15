hyprctl reload

if command -v eww >/dev/null 2>&1; then
  "$HOME/.config/eww/reload.sh" >/dev/null 2>&1 || true
fi

killall hyprpaper

hyprpaper
