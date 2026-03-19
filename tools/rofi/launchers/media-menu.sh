#!/usr/bin/env bash

set -euo pipefail

dir="$HOME/.config/rofi/themes"
theme='current'
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

pkill -x rofi >/dev/null 2>&1 || true
sleep 0.12

python - <<'PY' > "$tmp_file"
from pathlib import Path

dirs = [
    Path('/home/guayaba/.local/share/applications'),
    Path('/home/guayaba/.local/share/flatpak/exports/share/applications'),
    Path('/var/lib/flatpak/exports/share/applications'),
    Path('/usr/share/applications'),
]

allowed_apps = {
    'pear-desktop': 'Pear Desktop',
    'spotify': 'Spotify',
}

apps = {}
for base in dirs:
    if not base.exists():
        continue
    for desktop in sorted(base.glob('*.desktop')):
        fields = {
            'Name': None,
            'Icon': 'multimedia-player',
            'NoDisplay': 'false',
            'Hidden': 'false',
            'Type': 'Application',
            'Categories': '',
        }
        for line in desktop.read_text(errors='ignore').splitlines():
            if '=' not in line:
                continue
            key, value = line.split('=', 1)
            if key in fields and fields[key] in (None, 'multimedia-player', 'false', 'Application', ''):
                fields[key] = value.strip()

        name = fields['Name']
        if not name:
            continue
        if fields['NoDisplay'].lower() == 'true' or fields['Hidden'].lower() == 'true':
            continue
        if fields['Type'] != 'Application':
            continue

        desktop_id = desktop.stem
        if desktop_id not in allowed_apps:
            continue

        apps[desktop_id] = (allowed_apps[desktop_id], fields['Icon'] or 'multimedia-player')

for desktop_id, (name, icon) in sorted(apps.items(), key=lambda item: (item[1][0].casefold(), item[0].casefold())):
    print(f"{name}\t{icon}\t{desktop_id}")
PY

if [[ ! -s "$tmp_file" ]]; then
  exit 0
fi

item_count="$(wc -l < "$tmp_file")"

selection_index="$({
  while IFS=$'\t' read -r name icon desktop_id; do
    printf '%s\0icon\x1f%s\n' "$name" "$icon"
  done < "$tmp_file"
} | rofi \
  -dmenu \
  -i \
  -show-icons \
  -format i \
  -p 'Reproductor' \
  -matching fuzzy \
  -theme "${dir}/${theme}.rasi" \
  -theme-str "listview { lines: ${item_count}; dynamic: true; scrollbar: false; }")"

[[ -n "$selection_index" ]] || exit 0

desktop_id="$(python - "$tmp_file" "$selection_index" <<'PY'
import sys

rows = []
with open(sys.argv[1], encoding='utf-8', errors='ignore') as handle:
    for line in handle:
        line = line.rstrip('\n')
        if not line:
            continue
        rows.append(line.split('\t', 2))

index = int(sys.argv[2])
if 0 <= index < len(rows):
    print(rows[index][2])
PY
)"

[[ -n "$desktop_id" ]] || exit 0
gtk-launch "$desktop_id" >/dev/null 2>&1 & disown
