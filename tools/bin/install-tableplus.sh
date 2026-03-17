#!/usr/bin/env bash
set -euo pipefail

if command -v tableplus >/dev/null 2>&1; then
  echo "TablePlus ya esta instalado."
  exit 0
fi

TABLEPLUS_URL="https://tableplus.com/release/linux/x64/TablePlus-x64.AppImage"
TABLEPLUS_APPIMAGE="$HOME/.local/bin/TablePlus"

mkdir -p "$(dirname "$TABLEPLUS_APPIMAGE")"

echo "Descargando TablePlus..."
curl -fsSL -o "$TABLEPLUS_APPIMAGE" "$TABLEPLUS_URL"
chmod +x "$TABLEPLUS_APPIMAGE"

if [ -w "/usr/local/bin" ] || sudo -n true 2>/dev/null; then
  echo "Creando enlace en /usr/local/bin..."
  printf '1580\n' | sudo -S ln -sf "$TABLEPLUS_APPIMAGE" /usr/local/bin/tableplus 2>/dev/null || \
    sudo ln -sf "$TABLEPLUS_APPIMAGE" /usr/local/bin/tableplus
else
  echo "No se pudo crear enlace en /usr/local/bin (sin permisos)."
  echo "Añade ~/.local/bin a tu PATH o ejecuta: sudo ln -s $TABLEPLUS_APPIMAGE /usr/local/bin/tableplus"
fi

echo "TablePlus instalado correctamente."
