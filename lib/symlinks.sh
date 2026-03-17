#!/usr/bin/env bash

if [ -z "${DOTFILES_DIR:-}" ]; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

DOTFILES_BACKUP_TIMESTAMP="${DOTFILES_BACKUP_TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"

validate_install_mode() {
  case "$1" in
    normal|portable)
      ;;
    *)
      echo "ERROR: modo invalido: $1" >&2
      return 1
      ;;
  esac
}

infer_install_mode() {
  if [ -L "$HOME/.local/share/mis-dotfiles-portable" ] || [ -e "$HOME/.local/share/mis-dotfiles-portable" ]; then
    printf '%s\n' "portable"
  else
    printf '%s\n' "normal"
  fi
}

build_symlink_specs() {
  local mode="${1:-normal}"
  local -n specs_ref=$2

  validate_install_mode "$mode" || return 1

  specs_ref=(
    "$DOTFILES_DIR/shell/zsh/.zshrc|$HOME/.zshrc"
    "$DOTFILES_DIR/terminal/kitty|$HOME/.config/kitty"
    "$DOTFILES_DIR/editors/nvim|$HOME/.config/nvim"
    "$DOTFILES_DIR/editors/vsc/settings.json|$HOME/.config/Code/User/settings.json"
    "$DOTFILES_DIR/editors/vsc/keybindings.json|$HOME/.config/Code/User/keybindings.json"
    "$DOTFILES_DIR/gemini|$HOME/.gemini"
    "$DOTFILES_DIR/wm/hyprland|$HOME/.config/hypr"
    "$DOTFILES_DIR/wm/waybar|$HOME/.config/waybar"
    "$DOTFILES_DIR/wm/eww|$HOME/.config/eww"
    "$DOTFILES_DIR/tools/fastfetch|$HOME/.config/fastfetch"
    "$DOTFILES_DIR/tools/rofi|$HOME/.config/rofi"
    "$DOTFILES_DIR/tools/btop|$HOME/.config/btop"
    "$DOTFILES_DIR/tools/starship|$HOME/.config/starship"
    "$DOTFILES_DIR/tools/starship/starship.toml|$HOME/.config/starship.toml"
    "$DOTFILES_DIR/tools/opencode|$HOME/.config/opencode"
    "$DOTFILES_DIR/tools/bin/opencode-profile.sh|$HOME/.local/bin/opencode-profile"
    "$DOTFILES_DIR/tools/bin/open-browser.sh|$HOME/.local/bin/open-browser.sh"
    "$DOTFILES_DIR/tools/bin/organize-downloads.sh|$HOME/.local/bin/organize-downloads.sh"
    "$DOTFILES_DIR/tools/systemd-user/organize-downloads.service|$HOME/.config/systemd/user/organize-downloads.service"
    "$DOTFILES_DIR/tools/systemd-user/organize-downloads.path|$HOME/.config/systemd/user/organize-downloads.path"
    "$DOTFILES_DIR/wallpapers|$HOME/Imagenes/Wallpapers"
  )

  if [ "$mode" = "portable" ]; then
    specs_ref+=("$DOTFILES_DIR/portable|$HOME/.local/share/mis-dotfiles-portable")
  fi
}

symlink_points_to_source() {
  local source=$1
  local destination=$2
  local source_resolved
  local destination_resolved

  if [ ! -L "$destination" ]; then
    return 1
  fi

  source_resolved="$(readlink -f "$source" 2>/dev/null || true)"
  destination_resolved="$(readlink -f "$destination" 2>/dev/null || true)"

  [ -n "$source_resolved" ] && [ "$source_resolved" = "$destination_resolved" ]
}

backup_existing_destination() {
  local destination=$1
  local backup_root="${DOTFILES_BACKUP_DIR:-$HOME/.local/state/mis-dotfiles/backups}"
  local relative_path
  local backup_path

  if [[ "$destination" == "$HOME/"* ]]; then
    relative_path="${destination#"$HOME/"}"
  else
    relative_path="$(basename "$destination")"
  fi

  backup_path="$backup_root/$DOTFILES_BACKUP_TIMESTAMP/$relative_path"
  mkdir -p "$(dirname "$backup_path")"
  mv "$destination" "$backup_path"
  echo "Backup creado: $destination -> $backup_path"
}

create_symlink() {
  local source=$1
  local destination=$2

  if [ ! -e "$source" ] && [ ! -L "$source" ]; then
    echo "WARN: No existe el origen $source, se omite el symlink."
    return
  fi

  mkdir -p "$(dirname "$destination")"

  if symlink_points_to_source "$source" "$destination"; then
    echo "Symlink ya correcto: $destination"
    return
  fi

  if [ -L "$destination" ] || [ -e "$destination" ]; then
    backup_existing_destination "$destination"
  fi

  ln -s "$source" "$destination"
  echo "Enlace simbolico creado: $destination"
}

create_all_symlinks() {
  local mode="${1:-normal}"
  local specs=()
  local spec
  local source
  local destination

  build_symlink_specs "$mode" specs

  for spec in "${specs[@]}"; do
    source="${spec%%|*}"
    destination="${spec#*|}"
    create_symlink "$source" "$destination"
  done
}

verify_symlinks() {
  local mode="${1:-normal}"
  local specs=()
  local spec
  local source
  local destination
  local fail=0

  build_symlink_specs "$mode" specs

  for spec in "${specs[@]}"; do
    source="${spec%%|*}"
    destination="${spec#*|}"

    if ! symlink_points_to_source "$source" "$destination"; then
      echo "INVALID SYMLINK: $destination -> $source"
      fail=1
    fi
  done

  return "$fail"
}

reload_running_configs() {
  local reloaded=false

  if command -v hyprctl >/dev/null 2>&1 && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    if [ -f "$HOME/.config/hypr/scripts/reload.sh" ]; then
      bash "$HOME/.config/hypr/scripts/reload.sh" >/dev/null 2>&1 || true
    else
      hyprctl reload >/dev/null 2>&1 || true
    fi
    echo "Hyprland recargado."
    reloaded=true
  fi

  if command -v pgrep >/dev/null 2>&1 && command -v pkill >/dev/null 2>&1 && pgrep -x waybar >/dev/null 2>&1; then
    pkill -SIGUSR2 waybar >/dev/null 2>&1 || true
    echo "Waybar recargado."
    reloaded=true
  fi

  if [ "$reloaded" = false ]; then
    echo "Symlinks actualizados. No habia procesos activos para recargar."
  fi
}
