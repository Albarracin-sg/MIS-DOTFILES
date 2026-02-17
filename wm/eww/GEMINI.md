# Resumen del Proyecto

Este proyecto es una configuración completa para `eww` (Elkowar's Wacky Widgets), un sistema de widgets para escritorios de Linux. Proporciona una experiencia de escritorio altamente personalizada y rica en funciones con múltiples barras, widgets y paneles de control. La configuración está diseñada para un entorno de múltiples monitores y utiliza una combinación de `yuck` para las definiciones de los widgets, `scss` para el estilo y una colección de scripts de shell para la recopilación de datos.

## Tecnologías Principales

*   **eww:** El sistema de widgets principal.
*   **yuck:** Un lenguaje declarativo similar a Lisp que se utiliza para definir la estructura y el comportamiento de los widgets.
*   **scss:** Un preprocesador de CSS que se utiliza para dar estilo a los widgets.
*   **shell scripts:** Se utilizan una variedad de scripts para obtener datos del sistema, como el estado de la batería, la información de la red Wi-Fi, los procesos en ejecución, el estado del reproductor de música y más.

## Arquitectura

El proyecto se estructura de la siguiente manera:

*   `eww.yuck`: El archivo de configuración principal que define todos los widgets, ventanas y variables. Está diseñado para admitir múltiples monitores.
*   `eww.scss`: La hoja de estilos que proporciona la apariencia visual de todos los widgets.
*   `scripts/`: Un directorio que contiene varios scripts de shell que actúan como fuentes de datos para los widgets. `eww` sondea estos scripts para actualizar la interfaz de usuario con información en tiempo real.
*   `start.sh`: Un script simple para lanzar el demonio de `eww` y abrir el widget de la barra principal.

# Compilación y Ejecución

Para ejecutar esta configuración de `eww`, necesitas tener `eww` instalado en tu sistema. Luego puedes lanzar los widgets ejecutando el script `start.sh`:

```bash
~/.config/eww/start.sh
```

Esto iniciará el demonio de `eww` y mostrará la barra principal en tu monitor primario. La configuración está preparada para manejar múltiples monitores, y los widgets deberían aparecer en todas las pantallas conectadas.

# Convenciones de Desarrollo

*   **Modularidad:** El archivo `eww.yuck` está organizado en secciones lógicas para diferentes widgets (por ejemplo, barra, menú, calendario, etc.).
*   **Obtención de Datos:** Todos los datos dinámicos se obtienen a través de scripts de shell externos ubicados en el directorio `scripts/`. Esto mantiene el archivo `eww.yuck` limpio y centrado en la estructura de la interfaz de usuario.
*   **Estilo:** Todo el estilo se realiza en el archivo `eww.scss`, siguiendo las convenciones estándar de SCSS.
*   **Soporte Multi-monitor:** La configuración está diseñada para funcionar en múltiples monitores, con definiciones de ventana separadas para cada pantalla.
