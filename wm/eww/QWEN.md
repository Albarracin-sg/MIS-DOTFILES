# Configuración de Dashboard Eww

## Resumen del Proyecto
Esta es una configuración completa de Eww (ElKowar's Wacky Widgets) para Linux, diseñada para configuraciones multi-monitor usando Hyprland como administrador de ventanas. La configuración proporciona un dashboard de escritorio con muchas funciones incluyendo monitoreo del sistema, lanzamiento de aplicaciones, controles de red y manejo multimedia.

### Características Principales
- **Soporte multi-monitor**: Configurado para trabajar en múltiples monitores con widgets separados por monitor
- **Monitoreo del sistema**: CPU, RAM, uso de disco, temperaturas y procesos
- **Controles de red**: Administración de conexión WiFi, estado de Bluetooth
- **Controles multimedia**: Integración de reproductor de música con controles de reproducción
- **Controles del sistema**: Administración de energía (apagar, reiniciar, suspender, hibernar), controles de sesión de usuario
- **Administración de espacios de trabajo**: Integración con espacios de trabajo de Hyprland
- **Estilo personalizado**: Diseño sofisticado usando SCSS con fuentes y colores personalizados

### Arquitectura
- `eww.yuck`: Archivo de configuración principal definiendo widgets, ventanas y variables
- `eww.scss`: Definiciones de estilo usando sintaxis SCSS
- `scripts/`: Directorio conteniendo scripts auxiliares para varias funciones
- `icons/`: Directorio conteniendo íconos para varios elementos de la UI
- `start.sh`: Script de inicio para lanzar el daemon y dashboard de Eww
- `start_bars.sh`: Script de inicio correcto para configuración multi-monitor

### Tecnologías Usadas
- Eww (ElKowar's Wacky Widgets) - Framework de dashboard
- Scripts de shell para integración del sistema
- Hyprland - Compositor Wayland (con integración de espacios de trabajo)
- Herramientas del sistema: pamixer (volumen), brightnessctl (brillo), playerctl (multimedia), etc.

## Compilación y Ejecución

### Prerrequisitos
- Eww instalado (versión compatible con esta configuración)
- Administrador de ventanas Hyprland
- Varias utilidades del sistema:
  - `pamixer` para control de audio
  - `brightnessctl` para control de brillo
  - `playerctl` para control multimedia
  - `jq` para procesamiento JSON
  - Fuentes: "Monocraft Nerd Font" y "JetBrainsMono Nerd Font"

### Instalación
1. Instala Eww: `paru -S eww` o equivalente para tu gestor de paquetes
2. Asegúrate que todas las dependencias mencionadas arriba estén instaladas
3. Copia esta configuración a `~/.config/eww/`
4. Instala las fuentes requeridas para mostrar correctamente los íconos

### Ejecución
Para iniciar el dashboard:
```bash
# Para configuración de un solo monitor
~/.config/eww/start.sh

# Para configuración multi-monitor (recomendado)
~/.config/eww/scripts/start_bars.sh
```

O manualmente:
```bash
eww daemon  # Inicia el daemon de Eww
eww open bar_widget_0  # Abre para monitor 0
eww open bar_widget_1  # Abre para monitor 1 (si aplica)
```

Para detener:
```bash
eww kill  # Mata el daemon de Eww y cierra todas las ventanas
```

### Nota
El script de inicio tiene actualmente un problema - intenta abrir "bar_widget" pero las definiciones reales de ventanas son "bar_widget_0" y "bar_widget_1" para soporte multi-monitor. Usa el script `start_bars.sh` en su lugar, o actualiza el start.sh para abrir las ventanas correctas.

## Convenciones de Desarrollo

### Estructura de Widgets
- Los widgets se definen usando la sintaxis `(defwidget nombre [parámetros] ...)`
- Las ventanas se definen usando la sintaxis `(defwindow nombre ...)`
- Las variables se definen usando `(defvar nombre valor)` y pueden actualizarse dinámicamente
- El sondeo de información del sistema usa `(defpoll nombre :interval "tiempo" comando)`
- La escucha de eventos usa `(deflisten nombre comando)`

### Estilo
- Los estilos se definen en `eww.scss` usando sintaxis SCSS
- Las clases siguen una convención de nombramiento semántico (ej. `.bar`, `.menu`, `.volume-short`)
- Esquema de color usa un tema oscuro con colores de énfasis
- Diseño responsive con espaciado y dimensionamiento apropiado

### Integración de Scripts
- Scripts externos en el directorio `scripts/` proporcionan datos dinámicos
- Los scripts típicamente emiten valores o JSON que son usados por widgets
- Los scripts usan varias herramientas del sistema para recopilar información
- Manejo de eventos a través de comandos bash integrados en la UI

### Soporte Multi-Monitor
- Todas las ventanas están parametrizadas con `monitor_id` para soporte multi-monitor
- Se crean instancias de ventanas separadas para cada monitor (ej. `bar_widget_0`, `bar_widget_1`)
- Cada monitor puede controlar independientemente ventanas como calendarios y menús