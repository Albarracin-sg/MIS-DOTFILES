# Plymouth

Temas animados para el splash screen de boot (después de GRUB).

## Instalación de Plymouth

```bash
# Instalar plymouth (Arch)
sudo pacman -S plymouth

# Habilitar en mkinitcpio
sudo nano /etc/mkinitcpio.conf
# Agregar 'plymouth' en HOOKS=(... plymouth ...)

# Regenerar initramfs
sudo mkinitcpio -P
```

## Temas animados recomendados

### 1. Dragon Boot (recomendado)
Tema animado con dragón sci-fi. 24 frames, Full HD.

```bash
sudo wget -qO- https://raw.githubusercontent.com/statikfintechllc/dragon-boot/master/scripts/install.script | bash
```

### 2. GeekDZ
Tema con animación de logo y efectos neon.

```bash
# Ver: https://github.com/geekdz40/GeekDZ-Plymouth
```

### 3. Tema personalizado (McLOVIN)

Crear un tema estático con McLOVIN:

```bash
# 1. Crear directorio del tema
sudo mkdir -p /usr/share/plymouth/themes/mclovin

# 2. Copiar imagen (asegurarse que sea PNG)
sudo cp ~/tools/MIS-DOTFILES/wallpapers/icons/McLOVIN.jpg /usr/share/plymouth/themes/mclovin/background.png

# 3. Crear archivo .plymouth
sudo tee /usr/share/plymouth/themes/mclovin/mclovin.plymouth << 'EOF'
[Plymouth Theme]
Name=McLOVIN
Description=McLOVIN boot splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/mclovin
ScriptFile=/usr/share/plymouth/themes/mclovin/script.script
EOF

# 4. Crear script simple
sudo tee /usr/share/plymouth/themes/mclovin/script.script << 'EOF'
screen_width = Window.GetWidth();
screen_height = Window.GetHeight();
background_image = Image("background.png");
background_image = background_image.Scale(screen_width, screen_height);
sprite = Sprite(background_image);
sprite.SetZ(-100);
EOF

# 5. Establecer tema
sudo plymouth-set-default-theme -r mclovin
```

## Ver tema en vivo

```bash
plymouthd --debug --no-daemon
# (Ctrl+C para salir)

# O preview:
plymouth message "Hello"
```

## Referencias

- https://github.com/statikfintechllc/dragon-boot
- https://www.baeldung.com/linux/plymouth-install-configure
