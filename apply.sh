#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/symlinks.sh"

selected_mode="${INSTALL_MODE:-$(infer_install_mode)}"
reload_after_apply=true

while [ $# -gt 0 ]; do
  case "$1" in
    normal|portable)
      selected_mode="$1"
      ;;
    --normal)
      selected_mode="normal"
      ;;
    --portable)
      selected_mode="portable"
      ;;
    --no-reload)
      reload_after_apply=false
      ;;
    *)
      echo "Uso: $0 [normal|portable|--normal|--portable] [--no-reload]" >&2
      exit 1
      ;;
  esac
  shift
done

validate_install_mode "$selected_mode"
create_all_symlinks "$selected_mode"
verify_symlinks "$selected_mode"

if [ "$reload_after_apply" = true ]; then
  reload_running_configs
fi

echo "Configuracion aplicada desde $DOTFILES_DIR ($selected_mode)."
