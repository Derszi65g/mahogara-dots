#!/usr/bin/env bash
# hooks/components/polybar.sh

# 1. Aplicar variaciones en el config de Polybar (Icono de OS)
POLY_SYSTEM_CONFIG="$POLYBAR_CONFIG_DIR/system.ini"

if [ -f "$POLY_SYSTEM_CONFIG" ] && [ -n "$OS_ICON" ]; then
    target_file="$(readlink -f "$POLY_SYSTEM_CONFIG")"
    sed -i "/\[module\/launcher\]/,/format=/ s|format=.*|format= $OS_ICON |" "$target_file"
fi

# 2. Reiniciar polybar usando el script del paquete
if [ -f "$POLYBAR_LAUNCH_SCRIPT" ]; then
    bash "$POLYBAR_LAUNCH_SCRIPT" &
fi
