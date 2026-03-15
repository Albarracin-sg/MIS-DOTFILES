#!/usr/bin/env bash
set -euo pipefail

mode="${1:-lock}"
base_conf="$HOME/.config/hypr/hyprlock.conf"
generated_conf="/tmp/hyprlock-generated.conf"
fallback_image="$HOME/Imagenes/Wallpapers/gachakuta"
sample_image=""

extract_background_path() {
  awk -F'= ' '/^[[:space:]]*path = / {print $2; exit}' "$base_conf"
}

resolve_sample_image() {
  local configured_path
  configured_path="$(extract_background_path || true)"

  if [ -n "$configured_path" ] && [ -f "$configured_path" ]; then
    printf '%s\n' "$configured_path"
    return 0
  fi

  if [ -f "$fallback_image" ]; then
    printf '%s\n' "$fallback_image"
    return 0
  fi

  sample_image="/tmp/hyprlock-sample.png"
  grim -t png "$sample_image"
  printf '%s\n' "$sample_image"
}

avg_rgb() {
  local image="$1"
  local crop_filter="$2"

  ffmpeg -v error -i "$image" -vf "$crop_filter,scale=1:1" -frames:v 1 -f rawvideo -pix_fmt rgb24 - 2>/dev/null | \
    python3 -c 'import sys; data=sys.stdin.buffer.read(3); print(*(list(data)+[0,0,0])[:3])'
}

derive_palette() {
  local r="$1"
  local g="$2"
  local b="$3"

  python3 - "$r" "$g" "$b" <<'PY'
import colorsys, sys

r, g, b = [int(x) / 255 for x in sys.argv[1:4]]
lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) * 255
h, l, s = colorsys.rgb_to_hls(r, g, b)

if lum < 145:
    text = (248, 245, 255)
    muted = (214, 208, 226)
    accent_h = (h + 0.5) % 1.0
    accent = tuple(int(v * 255) for v in colorsys.hls_to_rgb(accent_h, 0.72, max(s, 0.55)))
else:
    text = (18, 22, 32)
    muted = (78, 88, 108)
    accent_h = (h + 0.5) % 1.0
    accent = tuple(int(v * 255) for v in colorsys.hls_to_rgb(accent_h, 0.34, max(s, 0.45)))

def fmt(rgb):
    return f"rgb({rgb[0]}, {rgb[1]}, {rgb[2]})"

def hexfmt(rgb):
    return ''.join(f'{c:02x}' for c in rgb)

print(fmt(text))
print(fmt(accent))
print(fmt(muted))
print(hexfmt(text))
PY
}

build_config() {
  local background_path="$1"
  local primary_color="$2"
  local accent_color="$3"
  local muted_color="$4"
  local primary_hex="$5"

  cat > "$generated_conf" <<EOF
# BACKGROUND
background {
    monitor =
    path = $background_path
}

general {
    no_fade_in = false
    no_fade_out = false
    hide_cursor = true
    grace = 0
    disable_loading_bar = true
    ignore_empty_input = true
}

shape {
    monitor =
    size = 580, 400
    color = rgba(0, 0, 0, 0.42)
    rounding = 22
    border_size = 1
    border_color = rgba(255, 255, 255, 0.12)
    position = 0, 145
    halign = center
    valign = center
    zindex = 0
}

input-field {
    monitor =
    size = 250, 60
    outline_thickness = 2
    dots_size = 0.2
    dots_spacing = 0.35
    dots_center = true
    outer_color = rgba(255, 255, 255, 0)
    inner_color = rgba(0, 0, 0, 0.18)
    font_color = $primary_color
    fade_on_empty = false
    rounding = -1
    placeholder_text =
    hide_input = false
    position = 0, -200
    halign = center
    valign = center
    zindex = 1
    check_color = rgb(108, 112, 134)
    fail_color = rgb(243, 139, 168)
    fail_text = <b>\$ATTEMPTS</b>
    fail_timeout = 2000
    fail_transition = 300
}

label {
  monitor =
  text = cmd[update:1000] date +"%A, %B %d"
  color = $muted_color
  font_size = 22
  font_family = JetBrains Mono
  position = 0, 300
  halign = center
  valign = center
  zindex = 1
}

label {
  monitor =
  text = cmd[update:1000] date +"%-I:%M"
  color = $primary_color
  font_size = 95
  font_family = JetBrains Mono Extrabold
  position = 0, 200
  halign = center
  valign = center
  zindex = 1
}

label {
  monitor =
  text = cmd[update:1000] ~/.config/hypr/scripts/hyprlock-now-playing.sh status_label
  color = $accent_color
  font_size = 16
  font_family = JetBrains Mono Bold
  position = 0, 95
  halign = center
  valign = center
  zindex = 1
}

label {
  monitor =
  text = cmd[update:1000] ~/.config/hypr/scripts/hyprlock-now-playing.sh title
  color = $primary_color
  font_size = 20
  font_family = JetBrains Mono Extrabold
  position = 0, 65
  halign = center
  valign = center
  zindex = 1
}

label {
  monitor =
  text = cmd[update:1000] ~/.config/hypr/scripts/hyprlock-now-playing.sh artist
  color = $muted_color
  font_size = 14
  font_family = JetBrains Mono
  position = 0, 35
  halign = center
  valign = center
  zindex = 1
}
EOF
}

sample_image="$(resolve_sample_image)"
read -r r g b <<< "$(avg_rgb "$sample_image" 'crop=900:520:(iw-900)/2:(ih-520)/2')"
mapfile -t palette < <(derive_palette "$r" "$g" "$b")
build_config "$sample_image" "${palette[0]}" "${palette[1]}" "${palette[2]}" "${palette[3]}"

case "$mode" in
  print-config)
    sed -n '1,200p' "$generated_conf"
    ;;
  lock)
    exec hyprlock -c "$generated_conf"
    ;;
  *)
    printf 'Unknown mode: %s\n' "$mode" >&2
    exit 1
    ;;
esac
