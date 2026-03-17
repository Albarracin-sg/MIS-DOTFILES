#!/usr/bin/env bash
set -euo pipefail

DOWNLOADS_DIR=""
if command -v xdg-user-dir >/dev/null 2>&1; then
  candidate="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
  if [ -n "$candidate" ]; then
    DOWNLOADS_DIR="$candidate"
  fi
fi

if [ -z "$DOWNLOADS_DIR" ]; then
  for candidate in "$HOME/Descargas" "$HOME/Downloads"; do
    if [ -n "$candidate" ] && [ -d "$candidate" ]; then
      DOWNLOADS_DIR="$candidate"
      break
    fi
  done
fi

DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Downloads}"
ORGANIZE_DIR="$DOWNLOADS_DIR/zen"
IMAGES_DIR="$ORGANIZE_DIR/Imagenes"
VIDEOS_DIR="$ORGANIZE_DIR/Videos"
DOCUMENTS_DIR="$ORGANIZE_DIR/Documentos"

mkdir -p \
  "$ORGANIZE_DIR/Apps" \
  "$ORGANIZE_DIR/Audio" \
  "$ORGANIZE_DIR/Comprimidos" \
  "$ORGANIZE_DIR/Documentos" \
  "$ORGANIZE_DIR/Temp" \
  "$ORGANIZE_DIR/Imagenes" \
  "$ORGANIZE_DIR/Videos"

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
      move_file "$file" "$ORGANIZE_DIR/Comprimidos"
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
      move_file "$file" "$ORGANIZE_DIR/Audio"
      ;;
    zip|tar|gz|tgz|bz2|xz|7z|rar|zst)
      move_file "$file" "$ORGANIZE_DIR/Comprimidos"
      ;;
    appimage|deb|rpm|flatpakref|flatpak|iso)
      move_file "$file" "$ORGANIZE_DIR/Apps"
      ;;
    pdf|doc|docx|odt|ppt|pptx|xls|xlsx|csv)
      move_file "$file" "$DOCUMENTS_DIR"
      ;;
    txt|md)
      move_file "$file" "$DOCUMENTS_DIR"
      ;;
    torrent)
      move_file "$file" "$ORGANIZE_DIR/Temp"
      ;;
  esac
}

process_directory() {
  local dir="$1"
  local entry

  for entry in "$dir"/*; do
    [ -e "$entry" ] || continue

    if [ -d "$entry" ]; then
      case "$(basename "$entry")" in
        Apps|Audio|Comprimidos|Documentos|Temp|Imagenes|Videos)
          continue
          ;;
      esac

      process_directory "$entry"
      rmdir "$entry" 2>/dev/null || true
      continue
    fi

    categorize_file "$entry"
  done
}

process_download_roots() {
  local entry

  for entry in "$DOWNLOADS_DIR"/*; do
    [ -e "$entry" ] || continue

    if [ "$entry" = "$ORGANIZE_DIR" ]; then
      continue
    fi

    if [ -d "$entry" ]; then
      process_directory "$entry"
      rmdir "$entry" 2>/dev/null || true
      continue
    fi

    categorize_file "$entry"
  done

  process_directory "$ORGANIZE_DIR"
}

process_download_roots
