#!/usr/bin/env bash
# swaydots/install.sh

# Determinar la ruta absoluta del paquete
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Persistir variante si se pasa como argumento (ej: dots swaydots apply void)
if [[ -n "$1" ]]; then
    echo "$1" > "$PACKAGE_DIR/.current_variant"
    echo "Variante registrada: $1"
fi

echo "Instalando Swaydots desde: $PACKAGE_DIR"

# 2. Enlaces simbólicos (puedes añadir los que necesites aquí)
# mkdir -p "$HOME/.config/waybar"
# ln -sf "$PACKAGE_DIR/dotfiles/waybar/config" "$HOME/.config/waybar/config"

echo "Instalacion finalizada."
