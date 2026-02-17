#!/bin/bash
set -euo pipefail

# Directorio de origen
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Lista de dependencias
dependencies=(
    "atuin"
    "brightnessctl"
    "btop"
    "cliphist"
    "eww"
    "fastfetch"
    "grim"
    "gtk3"
    "gtk4"
    "hyprcursor"
    "hyprgraphics"
    "hypridle"
    "hyprland"
    "hyprland-guiutils"
    "hyprland-qt-support"
    "hyprlang"
    "hyprlock"
    "hyprpaper"
    "hyprpicker-git"
    "hyprtoolkit"
    "hyprutils"
    "hyprwayland-scanner-git"
    "hyprwire"
    "kitty"
    "neovim"
    "noto-fonts"
    "pamixer"
    "pavucontrol"
    "pipewire"
    "pipewire-pulse"
    "playerctl"
    "qt6ct"
    "ranger"
    "rofi"
    "slurp"
    "thefuck"
    "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd"
    "visual-studio-code-bin"
    "waybar"
    "wireplumber"
    "wl-clipboard"
    "xdg-desktop-portal-hyprland"
    "zoxide"
    "zsh"
)

require_yay() {
    if ! command -v yay &>/dev/null; then
        echo "ERROR: 'yay' no esta instalado. Instala yay y vuelve a ejecutar el script."
        exit 1
    fi
}

# Funcion para verificar e instalar/actualizar dependencias
install_dependencies() {
    require_yay

    local update_packages=${UPDATE_PACKAGES:-true}
    if [ "$update_packages" = "true" ]; then
        echo "Instalando/actualizando dependencias con yay -Syu..."
        yay -Syu --noconfirm --needed "${dependencies[@]}"
    else
        echo "Instalando dependencias (sin actualizar el sistema)..."
        yay -S --noconfirm --needed "${dependencies[@]}"
    fi
}

# Funcion para crear enlaces simbolicos
create_symlink() {
    local source=$1
    local destination=$2
    
    # Crear directorio de destino si no existe
    mkdir -p "$(dirname "$destination")"
    
    # Eliminar archivo o enlace simbÃ³lico existente
    if [ -L "$destination" ] || [ -e "$destination" ]; then
        rm -rf "$destination"
    fi
    
    # Crear nuevo enlace simbolico
    ln -s "$source" "$destination"
    echo "Enlace simbolico creado para $destination"
}

# Instalar/actualizar dependencias
install_dependencies

# Crear enlaces simbÃ³licos
create_symlink "$DOTFILES_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/terminal/kitty" "$HOME/.config/kitty"
create_symlink "$DOTFILES_DIR/editors/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/editors/vsc/settings.json" "$HOME/.config/Code/User/settings.json"
create_symlink "$DOTFILES_DIR/editors/vsc/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
create_symlink "$DOTFILES_DIR/gemini" "$HOME/.gemini"
create_symlink "$DOTFILES_DIR/wm/hyprland" "$HOME/.config/hypr"
create_symlink "$DOTFILES_DIR/wm/waybar" "$HOME/.config/waybar"
create_symlink "$DOTFILES_DIR/wm/eww" "$HOME/.config/eww"
create_symlink "$DOTFILES_DIR/tools/fastfetch" "$HOME/.config/fastfetch"
create_symlink "$DOTFILES_DIR/tools/rofi" "$HOME/.config/rofi"
create_symlink "$DOTFILES_DIR/tools/opencode" "$HOME/.config/opencode"
create_symlink "$DOTFILES_DIR/wallpapers" "$HOME/Wallpapers"

echo "Dotfiles instalados correctamente."
