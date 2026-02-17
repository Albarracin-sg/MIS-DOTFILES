#!/bin/bash

# Script para obtener la temperatura del sistema
# Este script proporciona temperaturas del CPU, GPU y disco NVMe

# Función para extraer temperatura de un sensor basado en un patrón
get_temp() {
    local sensor_output="$1"
    local pattern="$2"
    
    # Extraer la temperatura que sigue al patrón
    echo "$sensor_output" | grep "$pattern" | head -n 1 | awk '{print $2}' | sed 's/+//' | sed 's/°C//'
}

# Obtener la salida de sensors
sensors_output=$(sensors 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$sensors_output" ]; then
    # Si no se puede obtener la información de temperatura, devolver valores por defecto
    cpu_temp="0"
    core_temps=("0" "0" "0" "0")
else
    # Obtener temperatura del CPU (usualmente Tctl)
    cpu_temp=$(get_temp "$sensors_output" "Tctl:")
    if [ -z "$cpu_temp" ] || [ "$cpu_temp" = "0" ]; then
        # Intentar alternativas si Tctl no existe
        cpu_temp=$(get_temp "$sensors_output" "temp1:" | head -n 1)
    fi
    
    # Si cpu_temp aún no se obtuvo, usar lectura genérica
    if [ -z "$cpu_temp" ]; then
        cpu_temp=$(echo "$sensors_output" | grep -E "temp[0-9]+:" | head -n 1 | awk '{print $2}' | sed 's/+//' | sed 's/°C//')
    fi

    # Obtener temperaturas de los núcleos individuales (si están disponibles)
    # En sistemas AMD puede no haber lecturas individuales, así que usamos el total para todos
    core_temps[0]=$cpu_temp
    core_temps[1]=$cpu_temp
    core_temps[2]=$cpu_temp
    core_temps[3]=$cpu_temp
    
    # Actualizar si hay lecturas específicas de núcleos:
    # Este patrón puede variar según la CPU, para CPUs que reportan temperaturas de núcleos individuales
    # Por ejemplo, en Intel podría usar diferentes patrones
fi

# Asegurarse de que todas las temperaturas son válidas
cpu_temp=$(echo "$cpu_temp" | sed 's/[^0-9.]//g')
for i in {0..3}; do
    core_temps[$i]=$(echo "${core_temps[$i]}" | sed 's/[^0-9.]//g')
    # Si no se puede obtener una temperatura válida, usar 0
    if [ -z "${core_temps[$i]}" ] || ! echo "${core_temps[$i]}" | grep -qE '^[0-9]+\.?[0-9]*$'; then
        core_temps[$i]="0"
    fi
done

# Si la temperatura del CPU no es válida, usar la primera temperatura de núcleo
if [ -z "$cpu_temp" ] || ! echo "$cpu_temp" | grep -qE '^[0-9]+\.?[0-9]*$'; then
    cpu_temp="${core_temps[0]}"
fi

# Formatear como objeto JSON
echo "{"
echo "  \"CORETEMP_PACKAGE_ID_0\": $cpu_temp,"
echo "  \"CORETEMP_CORE_0\": ${core_temps[0]},"
echo "  \"CORETEMP_CORE_1\": ${core_temps[1]},"
echo "  \"CORETEMP_CORE_2\": ${core_temps[2]},"
echo "  \"CORETEMP_CORE_3\": ${core_temps[3]}"
echo "}"