#!/bin/sh
kill_polybar() {
  pkill -USR1 polybar
  sleep 1
  pkill polybar
}

# Matar instancias existentes
pkill polybar

# 1. Detectar Hardware y entorno para modulos dinamicos
export BACKLIGHT_CARD=$(ls -1 /sys/class/backlight/ | head -n 1)
HAS_BATTERY=$(ls -1 /sys/class/power_supply/ | grep -i "BAT")
HAS_AUDIO=$(pactl info >/dev/null 2>&1 && echo "yes")

# 2. Construir listas de modulos (Evita "islas" vacias si no hay hardware)
export POLY_LEFT="space left launcher right space left cpu-usage space-alt cpu-memory right space left i3-workspaces right"
[ -n "$BACKLIGHT_CARD" ] && POLY_LEFT="$POLY_LEFT space left backlight right"

export POLY_CENTER="left date right"

export POLY_RIGHT="left cpu-temperature right"
[ -n "$HAS_AUDIO" ] && POLY_RIGHT="$POLY_RIGHT space space left volume right"
[ -n "$HAS_BATTERY" ] && POLY_RIGHT="$POLY_RIGHT space left battery right"
export POLY_RIGHT="$POLY_RIGHT space left tray right space"

# 3. Iniciar las nuevas instancias de forma silenciosa
polybar -q bottom &
