#!/usr/bin/env bash
# i3dotsbyloonyx/install.sh

# 1. Persistencia de variante
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "$1" ]]; then
    echo "$1" > "$PACKAGE_DIR/.current_variant"
fi

# Cargar variante para tener las variables de paquetes
VARIANT_NAME=$(cat "$PACKAGE_DIR/.current_variant" 2>/dev/null || echo "debian")
source "$PACKAGE_DIR/envs/${VARIANT_NAME}.env"

echo "Instalando i3dotsbyloonyx (Variante: $VARIANT_NAME)..."

# 2. Instalar dependencias
if [ -n "$PKG_LIST" ]; then
    eval "$PKG_MANAGER $PKG_INSTALL_CMD $PKG_LIST"
fi

# 3. Nerd Fonts (JetBrainsMono y Hack)
mkdir -p ~/.local/share/fonts
if [ ! -d ~/.local/share/fonts/JetBrainsMonoNerd ]; then
    TEMP_FONTS=$(mktemp -d)
    wget -P "$TEMP_FONTS" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    unzip "$TEMP_FONTS/JetBrainsMono.zip" -d ~/.local/share/fonts/JetBrainsMonoNerd
    rm -rf "$TEMP_FONTS"
    fc-cache -fv
fi

# 4. Matugen (vía Cargo)
if ! command -v matugen &> /dev/null; then
    cargo install matugen
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# 5. Crear Symlinks
mkdir -p ~/.config
ln -sf "$PACKAGE_DIR/dotfiles/i3" "$HOME/.config/i3"
ln -sf "$PACKAGE_DIR/dotfiles/polybar" "$HOME/.config/polybar"
ln -sf "$PACKAGE_DIR/dotfiles/rofi" "$HOME/.config/rofi"
ln -sf "$PACKAGE_DIR/dotfiles/kitty" "$HOME/.config/kitty"
ln -sf "$PACKAGE_DIR/dotfiles/picom" "$HOME/.config/picom"

# 6. Copiar Wallpaper inicial si no existewa
[ ! -d "$HOME/wall" ] && cp -r "$PACKAGE_DIR/dotfiles/wall" "$HOME/wall"

echo "Instalación completada para $VARIANT_NAME."
