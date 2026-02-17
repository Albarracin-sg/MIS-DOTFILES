#!/bin/bash
base_dir="$HOME/.config/eww/"
image_file="${base_dir}image.jpg"
mkdir -p "$base_dir"

playerctl metadata -F -f '{{playerName}}|{{title}}|{{artist}}|{{mpris:artUrl}}|{{status}}|{{mpris:length}}' 2>/dev/null | while IFS='|' read -r name title artist artUrl status length; do
    # Calcular duración
    if [[ -n "$length" && "$length" =~ ^[0-9]+$ ]]; then
        len_sec=$(( (length + 500000) / 1000000 ))
        mins=$((len_sec / 60))
        secs=$((len_sec % 60))
        lengthStr=$(printf "%d:%02d" "$mins" "$secs")
    else
        len_sec="0"
        lengthStr="0:00"
    fi

    # Descargar imagen
    if [[ "$artUrl" =~ ^https?:// ]]; then
        tmp_image="${image_file}.tmp"
        if wget -q -T 5 -O "$tmp_image" "$artUrl" 2>/dev/null; then
            mv "$tmp_image" "$image_file"
        else
            rm -f "$tmp_image"
            cp "${base_dir}scripts/cover.png" "$image_file" 2>/dev/null || true
        fi
    elif [[ "$artUrl" =~ ^file:// ]]; then
        # Manejar URLs locales (file://)
        local_path="${artUrl#file://}"
        cp "$local_path" "$image_file" 2>/dev/null || cp "${base_dir}scripts/cover.png" "$image_file"
    else
        cp "${base_dir}scripts/cover.png" "$image_file" 2>/dev/null || true
    fi

    # Output JSON
    jq -n -c \
        --arg name "$name" \
        --arg title "$title" \
        --arg artist "$artist" \
        --arg thumbnail "$image_file" \
        --arg status "$status" \
        --arg length "$len_sec" \
        --arg lengthStr "$lengthStr" \
        '{name: $name, title: $title, artist: $artist, thumbnail: $thumbnail, status: $status, length: $length, lengthStr: $lengthStr}'
done
