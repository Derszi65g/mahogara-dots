#!/bin/sh
# launch.sh - Script de lanzamiento de Polybar

# Matar instancias existentes de forma robusta
pkill polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

# 1. Detectar Hardware y entorno para modulos dinamicos
export BACKLIGHT_CARD=$(ls -1 /sys/class/backlight/ | head -n 1)
HAS_BATTERY=$(ls -1 /sys/class/power_supply/ | grep -i "BAT")
HAS_AUDIO=$(pactl info >/dev/null 2>&1 && echo "yes")

# Detectar sensor de temperatura (hwmon)
for i in /sys/class/hwmon/hwmon*/name; do
    if grep -qE "coretemp|fam15h_power|k10temp" "$i" >/dev/null 2>&1; then
        export HWMON_PATH="$(dirname $i)/temp1_input"
        break
    fi
done
[ -z "$HWMON_PATH" ] && export HWMON_PATH=$(ls -1 /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1)

# 2. Leer Estilo desde el estado
STYLE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/style" 2>/dev/null || echo "$BAR_STYLE")
STYLE=$(echo "$STYLE" | tr -d '[:space:]')

# 3. Construir listas de modulos
if [ "$STYLE" = "round" ]; then
    # Estilo Redondo (Con Glifos/Separadores)
    export POLY_LEFT="space left launcher right space left cpu-usage space-alt cpu-memory right space left i3-workspaces right"
    [ -n "$BACKLIGHT_CARD" ] && POLY_LEFT="$POLY_LEFT space left backlight right"

    export POLY_CENTER="left date right"

    export POLY_RIGHT="left cpu-temperature right"
    [ -n "$HAS_AUDIO" ] && POLY_RIGHT="$POLY_RIGHT space space left volume right"
    [ -n "$HAS_BATTERY" ] && POLY_RIGHT="$POLY_RIGHT space left battery right"
    export POLY_RIGHT="$POLY_RIGHT space left tray right space"
else
    # Estilo Cuadrado (Reorganizado)
    # Launcher y Workspaces a la izquierda, CPU, RAM y Temp a la derecha
    export POLY_LEFT="space launcher i3-workspaces"
    [ -n "$BACKLIGHT_CARD" ] && POLY_LEFT="$POLY_LEFT space backlight"

    export POLY_CENTER="date"

    export POLY_RIGHT="cpu-usage cpu-memory cpu-temperature"
    [ -n "$HAS_AUDIO" ] && POLY_RIGHT="$POLY_RIGHT space volume"
    [ -n "$HAS_BATTERY" ] && POLY_RIGHT="$POLY_RIGHT space battery"
    export POLY_RIGHT="$POLY_RIGHT space tray space"
fi

# 4. Esperar un momento para asegurar que i3 socket esté listo (evita Connection Refused)
sleep 0.5

# 5. Iniciar las nuevas instancias
polybar -q bottom &
