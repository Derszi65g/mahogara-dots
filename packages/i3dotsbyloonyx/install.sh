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

# 3.5. Temas (adw-gtk3)
mkdir -p ~/.themes
if [ ! -d ~/.themes/adw-gtk3-dark ]; then
    echo "Instalando adw-gtk3..."
    wget https://github.com/lassekongo83/adw-gtk3/releases/download/v6.5/adw-gtk3v6.5.tar.xz -O /tmp/adw-gtk3.tar.xz
    tar -xf /tmp/adw-gtk3.tar.xz -C ~/.themes
    rm /tmp/adw-gtk3.tar.xz
fi

# 4. Matugen (Binario precompilado)
if ! command -v matugen &> /dev/null; then
    echo "Instalando Matugen (Binario)..."
    TEMP_MATUGEN=$(mktemp -d)
    URL=$(curl -s https://api.github.com/repos/InioX/matugen/releases/latest | grep "browser_download_url.*x86_64.tar.gz" | cut -d '"' -f 4)
    if [[ -n "$URL" ]]; then
        wget -P "$TEMP_MATUGEN" "$URL"
        tar -xzf "$TEMP_MATUGEN"/*.tar.gz -C "$TEMP_MATUGEN"
        
        # El binario puede tener el nombre completo o solo 'matugen'
        # Buscamos el ejecutable que se extrajo
        MATUGEN_BIN=$(find "$TEMP_MATUGEN" -type f -executable -name "matugen*" | head -n 1)
        
        if [[ -n "$MATUGEN_BIN" ]]; then
            if [ -w /usr/local/bin ]; then
                mv "$MATUGEN_BIN" /usr/local/bin/matugen
                chmod +x /usr/local/bin/matugen
            else
                mkdir -p "$HOME/.local/bin"
                mv "$MATUGEN_BIN" "$HOME/.local/bin/matugen"
                chmod +x "$HOME/.local/bin/matugen"
            fi
        else
            echo "No se encontró el binario extraído, intentando vía Cargo..."
            cargo install matugen
        fi
    else
        echo "No se pudo encontrar binario, instalando vía Cargo (lento)..."
        cargo install matugen
    fi
    rm -rf "$TEMP_MATUGEN"
fi

# Asegurar que las rutas locales estén en el PATH para el resto del script
export PROJECT_ROOT="$(cd "$PACKAGE_DIR/../.." && pwd)"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PROJECT_ROOT:$PATH"

# Añadir a .bashrc para persistencia futura
if ! grep -q ".local/bin" "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
fi

if ! grep -q "MAHOGARA_DOTS" "$HOME/.bashrc"; then
    echo "# Mahogara Dots" >> "$HOME/.bashrc"
    echo "export PATH=\"$PROJECT_ROOT:\$PATH\"" >> "$HOME/.bashrc"
    echo "export MAHOGARA_DOTS=\"$PROJECT_ROOT\"" >> "$HOME/.bashrc"
fi

# 5. Variables de entorno (QT)
if ! grep -q "QT_QPA_PLATFORMTHEME" "$HOME/.bashrc"; then
    echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> "$HOME/.bashrc"
fi

# 6. Crear Symlinks
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

# 7. Permisos de ejecución
find "$PACKAGE_DIR/dotfiles/rofi/bin" -type f -name "*.sh" -o -not -name "*.*" -exec chmod +x {} +
find "$PACKAGE_DIR/dotfiles/polybar/scripts" -type f -name "*.sh" -exec chmod +x {} +

# 8. Copiar Wallpaper inicial si no existe
[ ! -d "$HOME/wall" ] && cp -r "$PACKAGE_DIR/dotfiles/wall" "$HOME/wall"

# 9. Matugen inicial (Colores por defecto)
if command -v matugen &> /dev/null; then
    matugen image "$HOME/wall/wall.png"
fi

echo "Instalación completada para $VARIANT_NAME."
