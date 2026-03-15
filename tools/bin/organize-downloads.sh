#!/usr/bin/env bash
set -euo pipefail

DOWNLOADS_DIR="$HOME/Downloads"
IMAGES_DIR="$DOWNLOADS_DIR/Imagenes"
VIDEOS_DIR="$DOWNLOADS_DIR/Videos"
DOCUMENTS_DIR="$DOWNLOADS_DIR/Documentos"

mkdir -p \
  "$DOWNLOADS_DIR/Apps" \
  "$DOWNLOADS_DIR/Audio" \
  "$DOWNLOADS_DIR/Comprimidos" \
  "$DOWNLOADS_DIR/Documentos" \
  "$DOWNLOADS_DIR/Temp" \
  "$DOWNLOADS_DIR/Imagenes" \
  "$DOWNLOADS_DIR/Videos"

shopt -s nullglob nocaseglob

move_file() {
  local source="$1"
  local destination_dir="$2"
  local filename target base extension counter

  mkdir -p "$destination_dir"
  filename="$(basename "$source")"
  target="$destination_dir/$filename"

  if [ ! -e "$target" ]; then
    mv "$source" "$target"
    return 0
  fi

  base="${filename%.*}"
  extension="${filename##*.}"

  if [ "$base" = "$filename" ]; then
    extension=""
  else
    extension=".$extension"
  fi

  counter=1
  while [ -e "$destination_dir/${base}-$counter$extension" ]; do
    counter=$((counter + 1))
  done

  mv "$source" "$destination_dir/${base}-$counter$extension"
}

categorize_file() {
  local file="$1"
  local name lower_name ext

  [ -f "$file" ] || return 0

  name="$(basename "$file")"
  lower_name="${name,,}"
  ext="${lower_name##*.}"

  case "$lower_name" in
    *.crdownload|*.part|*.tmp|*.temp)
      return 0
      ;;
    *.tar.gz|*.tar.xz|*.tar.zst|*.pkg.tar.zst|*.pkg.tar.xz)
      move_file "$file" "$DOWNLOADS_DIR/Comprimidos"
      return 0
      ;;
  esac

  case "$ext" in
    jpg|jpeg|png|gif|webp|svg|bmp|tiff|avif|heic)
      move_file "$file" "$IMAGES_DIR"
      ;;
    mp4|mkv|webm|mov|avi|m4v)
      move_file "$file" "$VIDEOS_DIR"
      ;;
    mp3|wav|flac|ogg|m4a|aac)
      move_file "$file" "$DOWNLOADS_DIR/Audio"
      ;;
    zip|tar|gz|tgz|bz2|xz|7z|rar|zst)
      move_file "$file" "$DOWNLOADS_DIR/Comprimidos"
      ;;
    appimage|deb|rpm|flatpakref|flatpak|iso)
      move_file "$file" "$DOWNLOADS_DIR/Apps"
      ;;
    pdf|doc|docx|odt|ppt|pptx|xls|xlsx|csv)
      move_file "$file" "$DOCUMENTS_DIR"
      ;;
    txt|md)
      move_file "$file" "$DOCUMENTS_DIR"
      ;;
    torrent)
      move_file "$file" "$DOWNLOADS_DIR/Temp"
      ;;
  esac
}

for file in "$DOWNLOADS_DIR"/*; do
  case "$(basename "$file")" in
    Apps|Audio|Comprimidos|Documentos|Temp|Imagenes|Videos)
      continue
      ;;
  esac

  categorize_file "$file"
done
