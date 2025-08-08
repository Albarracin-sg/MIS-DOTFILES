#!/bin/bash

# Directorio de origen
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Lista de dependencias
dependencies=(
    "zsh"
    "kitty"
    "neovim"
    "visual-studio-code-bin"
    "hyprland"
    "waybar"
    "fastfetch"
    "rofi"
)

# FunciÃ³n para verificar e instalar/actualizar dependencias
install_dependencies() {
    for pkg in "${dependencies[@]}"; do
        if ! yay -Q "$pkg" &>/dev/null; then
            echo "Instalando $pkg..."
            yay -S --noconfirm "$pkg"
        else
            echo "Actualizando $pkg..."
            yay -Syu --noconfirm "$pkg"
        fi
    done
}

# FunciÃ³n para crear enlaces simbÃ³licos
create_symlink() {
    local source=$1
    local destination=$2
    
    # Crear directorio de destino si no existe
    mkdir -p "$(dirname "$destination")"
    
    # Eliminar archivo o enlace simbÃ³lico existente
    if [ -L "$destination" ] || [ -e "$destination" ]; then
        rm -rf "$destination"
    fi
    
    # Crear nuevo enlace simbÃ³lico
    ln -s "$source" "$destination"
    echo "Enlace simbÃ³lico creado para $destination"
}

# Instalar/actualizar dependencias
install_dependencies

# Crear enlaces simbÃ³licos
create_symlink "$DOTFILES_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/terminal/kitty" "$HOME/.config/kitty"
create_symlink "$DOTFILES_DIR/editors/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/editors/vsc/settings.json" "$HOME/.config/Code/User/settings.json"
create_symlink "$DOTFILES_DIR/wm/hyprland" "$HOME/.config/hypr"
create_symlink "$DOTFILES_DIR/wm/waybar" "$HOME/.config/waybar"
create_symlink "$DOTFILES_DIR/tools/fastfetch" "$HOME/.config/fastfetch"
create_symlink "$DOTFILES_DIR/tools/rofi" "$HOME/.config/rofi"
create_symlink "$DOTFILES_DIR/wallpapers" "$HOME/Wallpapers"

echo "Dotfiles instalados correctamente."