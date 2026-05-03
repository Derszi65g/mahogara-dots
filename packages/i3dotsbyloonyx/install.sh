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
    $PKG_MANAGER $PKG_INSTALL_CMD $PKG_LIST
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

# 4. Matugen (Binario precompilado)
if ! command -v matugen &> /dev/null; then
    echo "Instalando Matugen (Binario)..."
    TEMP_MATUGEN=$(mktemp -d)
    # Detectar arquitectura y descargar último release
    URL=$(curl -s https://api.github.com/repos/InioX/matugen/releases/latest | grep "browser_download_url.*linux-x86_64.tar.gz" | cut -d '"' -f 4)
    if [[ -n "$URL" ]]; then
        wget -P "$TEMP_MATUGEN" "$URL"
        tar -xzf "$TEMP_MATUGEN"/*.tar.gz -C "$TEMP_MATUGEN"
        sudo mv "$TEMP_MATUGEN"/matugen /usr/local/bin/
        sudo chmod +x /usr/local/bin/matugen
    else
        echo "No se pudo encontrar binario, instalando vía Cargo (lento)..."
        cargo install matugen
    fi
    rm -rf "$TEMP_MATUGEN"
fi

# Añadir ~/.local/bin y ~/.cargo/bin al PATH si no están
if ! grep -q ".local/bin" "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
fi

# 5. Crear Symlinks
mkdir -p ~/.config
ln -sf "$PACKAGE_DIR/dotfiles/i3" "$HOME/.config/i3"
ln -sf "$PACKAGE_DIR/dotfiles/polybar" "$HOME/.config/polybar"
ln -sf "$PACKAGE_DIR/dotfiles/rofi" "$HOME/.config/rofi"
ln -sf "$PACKAGE_DIR/dotfiles/kitty" "$HOME/.config/kitty"
ln -sf "$PACKAGE_DIR/dotfiles/picom" "$HOME/.config/picom"
ln -sf "$PACKAGE_DIR/dotfiles/gtk-3.0" "$HOME/.config/gtk-3.0"
ln -sf "$PACKAGE_DIR/dotfiles/gtk-4.0" "$HOME/.config/gtk-4.0"
ln -sf "$PACKAGE_DIR/dotfiles/qt6ct" "$HOME/.config/qt6ct"
ln -sf "$PACKAGE_DIR/dotfiles/matugen" "$HOME/.config/matugen"

# 6. Permisos de ejecución
find "$PACKAGE_DIR/dotfiles/rofi/bin" -type f -name "*.sh" -o -not -name "*.*" -exec chmod +x {} +
find "$PACKAGE_DIR/dotfiles/polybar/scripts" -type f -name "*.sh" -exec chmod +x {} +
chmod +x "$PACKAGE_DIR/dotfiles/i3/set-wallpaper.sh"
chmod +x "$PACKAGE_DIR/dotfiles/i3/mini-matugen-j"

# 7. Copiar Wallpaper inicial si no existe
[ ! -d "$HOME/wall" ] && cp -r "$PACKAGE_DIR/dotfiles/wall" "$HOME/wall"

# 8. Matugen inicial (Colores por defecto)
if command -v matugen &> /dev/null; then
    matugen image "$HOME/wall/wall.png"
fi

echo "Instalación completada para $VARIANT_NAME."
