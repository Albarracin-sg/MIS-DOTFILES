# Mis Dotfiles Personales

![Licencia](https://img.shields.io/badge/licencia-MIT-blue.svg)
![Ultimo Commit](https://img.shields.io/github/last-commit/tu-usuario/mis-dotfiles)
![Tamaño del Repositorio](https://img.shields.io/github/repo-size/tu-usuario/mis-dotfiles)

Un vistazo a mi rincón digital. Este repositorio contiene la configuración completa de mi entorno de desarrollo en Arch Linux, diseñado para ser minimalista, productivo y estéticamente agradable.

---

### Vista Previa

*Aquí puedes añadir una captura de pantalla de tu escritorio para que otros puedan ver cómo luce.*

![Mi Escritorio](https://via.placeholder.com/800x450.png?text=Mi+Escritorio+Personalizado)

---

### Filosofía

-   **Minimalismo Funcional:** Solo lo esencial, sin sacrificar funcionalidad.
-   **Centrado en el Teclado:** Flujos de trabajo optimizados para no depender del ratón.
-   **Automatización:** Scripts y alias para acelerar tareas repetitivas.
-   **Estética Agradable:** Un entorno visualmente coherente y agradable a la vista.

---

### Características Principales

-   **Gestor de Ventanas:** Hyprland, con animaciones fluidas y una gestión de ventanas eficiente.
-   **Barra de Estado:** Waybar, altamente personalizable para mostrar información relevante del sistema.
-   **Lanzador de Aplicaciones:** Rofi, con menús personalizados para aplicaciones, emojis, portapapeles y más.
-   **Terminal:** Kitty, un emulador de terminal rápido y potente, acelerado por GPU.
-   **Editores de Código:**
    -   **Neovim:** Configuración basada en LazyVim, con autocompletado, linters y depuradores integrados.
    -   **Visual Studio Code:** Ajustes para una experiencia de desarrollo limpia y sin distracciones.
-   **Shell:** Zsh, con autocompletado, historial mejorado y un prompt minimalista.

---

### Estructura del Repositorio

```
/
├── shell/          # Configuracion de Zsh
├── terminal/       # Configuracion de Kitty
├── editors/        # Configuracion de Neovim y VSCode
├── wm/             # Configuracion de Hyprland y Waybar
├── tools/          # Configuracion de Rofi y Fastfetch
├── wallpapers/     # Mi coleccion de fondos de pantalla
└── install.sh      # Script de instalacion automatizada
```

---

### Instalación

**Advertencia:** Este script está diseñado para mi configuración personal en Arch Linux. Úsalo bajo tu propio riesgo.

1.  **Clona el repositorio:**

    ```bash
    git clone https://github.com/tu-usuario/mis-dotfiles.git
    cd mis-dotfiles
    ```

2.  **Ejecuta el script de instalación:**

    ```bash
    ./install.sh
    ```

El script se encargará de:

-   Instalar y/o actualizar las dependencias necesarias usando `yay`.
-   Crear enlaces simbólicos de las configuraciones a sus directorios correspondientes.

---

### Atajos de Teclado

La mayoría de los atajos de teclado están definidos en los siguientes archivos:

-   **Hyprland:** `wm/hyprland/configs/bind.conf`
-   **Neovim:** `editors/nvim/lua/config/keymaps.lua`

Te recomiendo que los revises para familiarizarte con mi flujo de trabajo.

---

### Contribuciones

Aunque estos son mis dotfiles personales, estoy abierto a sugerencias y mejoras. Si tienes alguna idea, no dudes en abrir un *issue* o un *pull request*.

---

### Licencia

Este proyecto está bajo la licencia MIT. 
