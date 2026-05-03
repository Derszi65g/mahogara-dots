#!/usr/bin/env bash
# hooks/components/i3.sh

# Aplicar variaciones en el config de i3 usando sed
# Esto evita tener dos archivos de i3 separados.

I3_CONFIG="$HOME/.config/i3/conf.d/autostart.conf"
APPEARANCE_CONFIG="$HOME/.config/i3/conf.d/appearance.conf"

if [ -f "$I3_CONFIG" ]; then
    # Ajustar Polkit Agent
    sed -i "s|exec_always --no-startup-id .*polkit.*|exec_always --no-startup-id $POLKIT_AGENT \&|g" "$I3_CONFIG"
fi

if [ -f "$APPEARANCE_CONFIG" ]; then
    # Ajustar Fuente
    sed -i "s|font pango:.*|font pango:$I3_FONT 9|g" "$APPEARANCE_CONFIG"
fi
