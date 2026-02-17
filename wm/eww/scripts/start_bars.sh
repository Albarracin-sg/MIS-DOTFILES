
echo "🚀 Iniciando EWW Multi-Monitor..."

# Cerrar todas las ventanas
eww close-all
sleep 0.5

# Detectar número de monitores
MONITORS=$(hyprctl monitors -j | jq length)
echo "📺 Detectados $MONITORS monitores"

# Abrir barra en cada monitor
for ((i=0; i<$MONITORS; i++)); do
    echo "   Abriendo barra en monitor $i..."
    eww open "bar_widget_${i}"
done

echo "✅ EWW iniciado en ${MONITORS} monitores"
