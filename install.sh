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
    "git"
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
    "pokemon-colorscripts-git"
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

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Instalando Oh My Zsh..."
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
}

install_zsh_extras() {
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "WARN: Oh My Zsh no esta instalado. Omitiendo plugins/tema."
        return
    fi

    if [ ! -d "$custom_dir/themes/powerlevel10k" ]; then
        echo "Instalando tema powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
    fi

    if [ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]; then
        echo "Instalando plugin zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
    fi

    if [ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]; then
        echo "Instalando plugin zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
    fi

    if [ ! -d "$custom_dir/plugins/zsh-history-substring-search" ]; then
        echo "Instalando plugin zsh-history-substring-search..."
        git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search.git "$custom_dir/plugins/zsh-history-substring-search"
    fi
}

enable_user_service() {
    local service_name=$1
    if systemctl --user status "$service_name" &>/dev/null; then
        systemctl --user enable --now "$service_name" >/dev/null 2>&1 || true
    else
        systemctl --user enable --now "$service_name" >/dev/null 2>&1 || true
    fi
}

enable_services() {
    local enable_services=${ENABLE_SERVICES:-true}
    if [ "$enable_services" != "true" ]; then
        echo "Servicios deshabilitados por ENABLE_SERVICES=false"
        return
    fi

    if ! command -v systemctl &>/dev/null; then
        echo "WARN: systemctl no disponible. Omitiendo servicios."
        return
    fi

    echo "Habilitando servicios de usuario (pipewire, wireplumber, portal)..."
    enable_user_service pipewire.service
    enable_user_service pipewire-pulse.service
    enable_user_service wireplumber.service
    enable_user_service xdg-desktop-portal.service
    enable_user_service xdg-desktop-portal-hyprland.service
}

# Funcion para crear enlaces simbolicos
create_symlink() {
    local source=$1
    local destination=$2

    if [ ! -e "$source" ]; then
        echo "WARN: No existe el origen $source, se omite el symlink."
        return
    fi
    
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

# Instalar Oh My Zsh y plugins/tema
install_oh_my_zsh
install_zsh_extras

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

# Habilitar servicios necesarios
enable_services

echo "Dotfiles instalados correctamente."
