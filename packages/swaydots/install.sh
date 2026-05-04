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

# 2. Función de Enlazado Robusta
safe_link() {
    local src="$1"
    local dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -d "$dst" ]; then
        echo "Aviso: '$dst' es un directorio real. Haciendo backup a '${dst}.bak'..."
        mv "$dst" "${dst}.bak"
    fi
    ln -s "$src" "$dst"
    echo "Enlazado: $dst -> $src"
}

# 3. Enlaces simbólicos
mkdir -p ~/.config
safe_link "$PACKAGE_DIR/dotfiles/waybar" "$HOME/.config/waybar"
safe_link "$PACKAGE_DIR/dotfiles/rofi" "$HOME/.config/rofi"
safe_link "$PACKAGE_DIR/dotfiles/wofi" "$HOME/.config/wofi"

echo "Instalacion finalizada."
