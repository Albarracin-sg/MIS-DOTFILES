#!/usr/bin/env bash
set -euo pipefail

if ! command -v pactl >/dev/null 2>&1; then
  printf 'ERROR: pactl no esta instalado o no esta en PATH.\n' >&2
  exit 1
fi

mapfile -t sink_input_ids < <(pactl list sink-inputs short | awk '{print $1}')

if [ "${#sink_input_ids[@]}" -eq 0 ]; then
  printf 'No hay streams de audio activos para desmutear.\n'
  exit 0
fi

for id in "${sink_input_ids[@]}"; do
  pactl set-sink-input-mute "$id" 0
done

printf 'Streams de audio desmuteados:\n'
pactl list sink-inputs | awk '
  /^Sink Input #/ { current=$0 }
  /^\tapplication.name = / { app=$0; sub(/^\tapplication.name = "/, "", app); sub(/"$/, "", app) }
  /^\tmedia.name = / { media=$0; sub(/^\tmedia.name = "/, "", media); sub(/"$/, "", media) }
  /^\tMute: / {
    mute=$2
    printf "- %s | %s | Mute: %s\n", (app ? app : "desconocida"), (media ? media : "sin media"), mute
    app=""
    media=""
  }
'
