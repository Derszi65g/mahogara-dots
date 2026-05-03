#!/usr/bin/env bash
# hooks/components/polybar.sh

# Aplicar variaciones en el config de Polybar (Icono de OS)
POLY_SYSTEM_CONFIG="$HOME/.config/polybar/system.ini"

if [ -f "$POLY_SYSTEM_CONFIG" ] && [ -n "$OS_ICON" ]; then
    # Reemplazar el icono en el modulo launcher
    # Buscamos la linea content= y cambiamos el icono
    sed -i "s|content=.*|content= $OS_ICON |g" "$POLY_SYSTEM_CONFIG"
    
    # Reiniciar polybar si está corriendo
    if pgrep -x polybar > /dev/null; then
        bash "$HOME/.config/polybar/launch.sh" &
    fi
fi
