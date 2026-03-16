#!/usr/bin/env bash

set -euo pipefail

window_title="hypr-keybinds-help"
config_file="$HOME/.config/hypr/bind.conf"

if pgrep -f "rofi.*${window_title}" >/dev/null; then
  pkill -f "rofi.*${window_title}"
  exit 0
fi

if [[ ! -f "$config_file" ]]; then
  rofi -e "No existe $config_file"
  exit 1
fi

entries="$(
  python3 <<'PY'
from pathlib import Path
import re

config_file = Path.home() / ".config/hypr/bind.conf"
lines = config_file.read_text(encoding="utf-8").splitlines()

variables = {}
sections = []
current_section = "General"

dispatcher_labels = {
    "exec": "Ejecutar",
    "killactive": "Cerrar ventana",
    "fullscreen": "Pantalla completa",
    "togglefloating": "Flotante",
    "pseudo": "Pseudo",
    "movefocus": "Mover foco",
    "workspace": "Ir a workspace",
    "movetoworkspace": "Mover a workspace",
    "changegroupactive": "Cambiar ventana del grupo",
    "moveintogroup": "Meter en grupo",
    "moveoutofgroup": "Sacar del grupo",
    "resizeactive": "Redimensionar ventana",
    "movewindow": "Mover ventana con raton",
    "resizewindow": "Redimensionar con raton",
}

raw_command_labels = {
    "$terminal": "Abrir terminal",
    "$fileManager": "Abrir archivos",
    "$browser": "Abrir navegador",
    "$browser --private-window": "Abrir navegador privado",
    "code": "Abrir VS Code",
    "obsidian": "Abrir Obsidian",
    "$spotify": "Abrir Spotify",
    "~/.config/rofi/launchers/launcher.sh": "Abrir lanzador",
    "~/.config/rofi/powermenu/type-2/powermenu.sh": "Abrir menu de apagado",
    "~/.config/rofi/run/run.sh": "Ejecutar comando",
    "~/.config/rofi/filebrowser/filebrowser.sh": "Abrir explorador de archivos",
    "~/.config/rofi/clipboard/clipboard.sh": "Abrir portapapeles",
    "~/.config/rofi/snippet/snippet.sh": "Abrir snippets",
    "~/.config/rofi/emoji/emoji.sh": "Abrir selector de emoji",
    "~/.config/rofi/wifi/wifi.sh": "Abrir menu WiFi",
    "~/.config/rofi/wifi/wifinew.sh": "Abrir menu WiFi nuevo",
    "~/.config/hypr/scripts/keybinds-help.sh": "Abrir ayuda de atajos",
    "~/.config/hypr/scripts/hyprlock-adaptive.sh": "Bloquear pantalla",
    "/home/guayaba/.config/hypr/scripts/reload.sh": "Recargar Hyprland",
    "~/.config/hypr/scripts/record-menu.sh": "Abrir captura o grabacion",
    "~/.config/hypr/scripts/alt-tab-preview.sh": "Cambiar ventana",
    "~/.config/hypr/scripts/workspace-preview.sh": "Ver workspaces",
    "playerctl play-pause": "Pausar o reanudar musica",
    "playerctl next": "Siguiente cancion",
    "playerctl previous": "Cancion anterior",
    "playerctl stop": "Detener musica",
}

key_labels = {
    "RETURN": "Enter",
    "SPACE": "Space",
    "Escape": "Esc",
    "slash": "/",
    "mouse_down": "Rueda abajo",
    "mouse_up": "Rueda arriba",
    "mouse:272": "Click izquierdo",
    "mouse:273": "Click derecho",
    "left": "Left",
    "right": "Right",
    "up": "Up",
    "down": "Down",
}

modifier_labels = {
    "SUPER": "Super",
    "ALT": "Alt",
    "CTRL": "Ctrl",
    "SHIFT": "Shift",
}


def expand_variables(value: str) -> str:
    for name, replacement in sorted(variables.items(), key=lambda item: len(item[0]), reverse=True):
        value = value.replace(name, replacement)
    return value.strip()


def compact_command(command: str) -> str:
    command = expand_variables(command)
    command = command.replace(str(Path.home()), "~")
    command = re.sub(r"\s+", " ", command).strip()
    return command


def describe_exec(command: str) -> str:
    compact = compact_command(command)
    if compact in command_labels:
        return command_labels[compact]

    if compact.startswith("kitty --class floating"):
        return "Abrir terminal flotante"
    if compact.startswith("kitty --class btop-full -e btop"):
        return "Abrir btop"
    if compact.startswith("kitty --class opencode-portable"):
        return "Abrir OpenCode portable"
    if compact.startswith("shutdown -h now"):
        return "Apagar equipo"
    if compact.startswith("reboot"):
        return "Reiniciar equipo"
    if compact.startswith("sleep 1 && hyprctl dispatch dpms off"):
        return "Apagar pantalla"
    if compact.startswith("sleep 1 && hyprctl dispatch dpms on"):
        return "Encender pantalla"
    if compact.startswith("hyprctl dispatch layoutmsg \"togglesplit true\""):
        return "Cambiar orientacion del split"
    if compact.startswith("brillo -q -U"):
        return "Bajar brillo"
    if compact.startswith("brillo -q -A"):
        return "Subir brillo"
    if compact.startswith("pamixer -i"):
        return "Subir volumen"
    if compact.startswith("pamixer -d"):
        return "Bajar volumen"
    if compact.startswith("pamixer -t"):
        return "Silenciar audio"

    pieces = compact.split()
    if not pieces:
        return "Ejecutar comando"
    if pieces[0].startswith("~/") or pieces[0].startswith("/"):
        script_name = Path(pieces[0]).stem.replace("-", " ")
        return f"Ejecutar {script_name}"
    return f"Ejecutar {pieces[0]}"


def normalize_modifiers(raw: str) -> str:
    expanded = expand_variables(raw)
    expanded = expanded.replace("_", " ")
    parts = [part for part in re.split(r"\s+", expanded.strip()) if part]
    if not parts:
        return ""
    return " + ".join(modifier_labels.get(part.upper(), part.title()) for part in parts)


def normalize_key(raw: str) -> str:
    expanded = expand_variables(raw).strip()
    return key_labels.get(expanded, expanded)


def describe_action(dispatcher: str, argument: str) -> str:
    dispatcher = dispatcher.strip()
    argument = expand_variables(argument)

    if dispatcher == "exec":
        return describe_exec(argument)
    if dispatcher == "workspace" and argument.startswith("e"):
        return f"Workspace {argument}"
    if dispatcher == "movetoworkspace" and argument.startswith("e"):
        return f"Mover a workspace {argument}"
    if dispatcher == "movefocus":
        directions = {"l": "izquierda", "r": "derecha", "u": "arriba", "d": "abajo"}
        return f"Mover foco {directions.get(argument, argument)}"
    if dispatcher == "changegroupactive":
        directions = {"f": "Siguiente del grupo", "b": "Anterior del grupo"}
        return directions.get(argument, f"Cambiar grupo {argument}")
    if dispatcher == "moveintogroup":
        directions = {"l": "Agrupar con la izquierda", "r": "Agrupar con la derecha", "u": "Agrupar arriba", "d": "Agrupar abajo"}
        return directions.get(argument, f"Meter en grupo {argument}")
    if dispatcher == "resizeactive":
        return f"Cambiar tamano {argument}"
    if argument:
        label = dispatcher_labels.get(dispatcher, dispatcher)
        return f"{label}: {argument}"
    return dispatcher_labels.get(dispatcher, dispatcher)


command_labels = {compact_command(key): value for key, value in raw_command_labels.items()}


for raw_line in lines:
    line = raw_line.strip()
    if not line:
        continue

    if line.startswith("# ===") and line.endswith("==="):
        current_section = line.replace("# ===", "").replace("===", "").strip()
        continue

    variable_match = re.match(r"^(\$[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+?)\s*(?:#.*)?$", line)
    if variable_match:
        variables[variable_match.group(1)] = variable_match.group(2).strip()
        continue

    bind_match = re.match(r"^(bind|binde|bindm)\s*=\s*(.+)$", line)
    if not bind_match:
        continue

    parts = [part.strip() for part in bind_match.group(2).split(",")]
    if len(parts) < 3:
        continue

    modifiers = normalize_modifiers(parts[0])
    key = normalize_key(parts[1])
    dispatcher = parts[2]
    argument = ", ".join(parts[3:]).strip()
    shortcut = f"{modifiers} + {key}" if modifiers else key
    action = describe_action(dispatcher, argument)
    sections.append((current_section, f"{shortcut} -> {action}"))

last_section = None
for section, entry in sections:
    if section != last_section:
        if last_section is not None:
            print()
        print(f"[{section}]")
        last_section = section
    print(entry)
PY
)"

if [[ -z "$entries" ]]; then
  rofi -e "No se detectaron binds en $config_file"
  exit 1
fi

printf '%s\n' "$entries" | rofi \
  -dmenu \
  -i \
  -no-custom \
  -p "Atajos" \
  -theme tokyonight \
  -theme-str "window { title: \"${window_title}\"; width: 980px; } listview { lines: 28; }"
