#!/bin/bash
set -euo pipefail

# Directorio de origen
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/symlinks.sh"

# Dependencias comunes
common_dependencies=(
    "atuin"
    "blueman"
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
    "jq"
    "kitty"
    "network-manager-applet"
    "networkmanager"
    "neovim"
    "noto-fonts"
    "obsidian"
    "pamixer"
    "pavucontrol"
    "pipewire"
    "pipewire-pulse"
    "playerctl"
    "pear-desktop"
    "pokemon-colorscripts-git"
    "pciutils"
    "postman-bin"
    "qt6ct"
    "ranger"
    "rofi-lbonn-wayland-git"
    "slurp"
    "thefuck"
    "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd"
    "visual-studio-code-bin"
    "waybar"
    "wireplumber"
    "wl-clipboard"
    "swww"
    "starship"
    "tailscale"
    "xdg-desktop-portal"
    "xdg-desktop-portal-hyprland"
    "zen-browser-bin"
    "zoxide"
    "zsh"
)

normal_extra_dependencies=()

portable_extra_dependencies=(
    "amd-ucode"
    "btrfs-progs"
    "efibootmgr"
    "grub"
    "linux"
    "linux-headers"
    "linux-lts"
    "linux-lts-headers"
    "linux-zen"
    "linux-zen-headers"
)

selected_mode=""
dependencies=()

print_mode_details() {
    echo
    echo "Modo normal instala:"
    echo "- Entorno Hyprland (hypr/waybar/eww), shell, nvim, apps y utilidades."
    echo "- Sin stack extra de boot portable (kernels multiples + grub + efibootmgr)."
    echo
    echo "Modo portable instala:"
    echo "- Todo lo del modo normal."
    echo "- Kernels linux/lts/zen + headers, grub, efibootmgr y btrfs-progs."
    echo "- Enlace simbolico de portable en ~/.local/share/mis-dotfiles-portable."
    echo
}

select_install_mode() {
    if [ -n "${INSTALL_MODE:-}" ]; then
        case "$INSTALL_MODE" in
            normal|portable)
                selected_mode="$INSTALL_MODE"
                ;;
            *)
                echo "ERROR: INSTALL_MODE debe ser 'normal' o 'portable'." >&2
                exit 1
                ;;
        esac
        return
    fi

    print_mode_details
    echo "Selecciona tipo de instalacion:"
    echo "1) normal"
    echo "2) portable"
    read -r -p "Opcion [1-2] (default 1): " choice

    case "${choice:-1}" in
        1)
            selected_mode="normal"
            ;;
        2)
            selected_mode="portable"
            ;;
        *)
            echo "Opcion invalida. Se usara modo normal."
            selected_mode="normal"
            ;;
    esac
}

prepare_dependencies() {
    dependencies=("${common_dependencies[@]}")
    if [ "$selected_mode" = "portable" ]; then
        dependencies+=("${portable_extra_dependencies[@]}")
    else
        dependencies+=("${normal_extra_dependencies[@]}")
    fi
}

require_yay() {
    if ! command -v yay &>/dev/null; then
        echo "ERROR: 'yay' no esta instalado. Instala yay y vuelve a ejecutar el script."
        exit 1
    fi
}

# Funcion para verificar e instalar/actualizar dependencias
install_dependencies() {
    require_yay

    if [ "${SKIP_PACKAGE_INSTALL:-false}" = "true" ]; then
        echo "SKIP_PACKAGE_INSTALL=true, se omite instalacion de paquetes."
        return
    fi

    local update_packages=${UPDATE_PACKAGES:-true}
    if [ "$update_packages" = "true" ]; then
        echo "Instalando/actualizando dependencias ($selected_mode) con yay -Syu..."
        yay -Syu --noconfirm --needed "${dependencies[@]}"
    else
        echo "Instalando dependencias ($selected_mode) sin actualizar el sistema..."
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
    enable_user_service organize-downloads.path

    if command -v sudo &>/dev/null; then
        echo "Habilitando servicios del sistema (NetworkManager y Bluetooth)..."
        sudo systemctl enable NetworkManager.service >/dev/null 2>&1 || true
        sudo systemctl enable bluetooth.service >/dev/null 2>&1 || true
        if [ "$selected_mode" = "portable" ]; then
            sudo systemctl enable tailscaled.service >/dev/null 2>&1 || true
        fi
    fi
}

select_install_mode
prepare_dependencies

echo "Modo seleccionado: $selected_mode"

# Instalar/actualizar dependencias
install_dependencies

# Instalar Oh My Zsh y plugins/tema
install_oh_my_zsh
install_zsh_extras

# Crear enlaces simbolicos
create_all_symlinks "$selected_mode"
verify_symlinks "$selected_mode"

# Asegurar permisos de ejecucion para scripts clave
chmod +x "$HOME/.config/hypr/autostart.conf" || true
chmod +x "$HOME/.config/hypr/scripts/detect-monitors.sh" || true
chmod +x "$HOME/.config/hypr/scripts/detect-gpu.sh" || true
chmod +x "$HOME/.config/hypr/scripts/portable-session.sh" || true
chmod +x "$HOME/.config/eww/scripts/start_bars.sh" || true
chmod +x "$HOME/.local/bin/opencode-profile" || true
chmod +x "$HOME/.local/bin/open-browser.sh" || true
chmod +x "$HOME/.local/bin/organize-downloads.sh" || true
chmod +x "$HOME/.local/bin/fix-audio-streams" || true
chmod +x "$DOTFILES_DIR/tools/bin/install-tableplus.sh" || true

# Instalar aplicaciones adicionales
if [ -f "$DOTFILES_DIR/tools/bin/install-tableplus.sh" ]; then
  "$DOTFILES_DIR/tools/bin/install-tableplus.sh"
fi

# Habilitar servicios necesarios
enable_services

echo "Dotfiles instalados correctamente."
