#!/usr/bin/env bash
# $1 es el valor del .txt (ej: waybar_base.css)

# 0. Protocolo de Consulta para el Core
if [ "$1" == "--query" ]; then
    echo "themes_dir=$PACKAGE_DIR/dotfiles/waybar/themes"
    echo "default_theme=waybar_base"
    echo "height_options=20px\n24px\n28px\n32px"
    echo "height_unit=px"
    echo "has_modes=false"
    exit 0
fi

# 1. Leer Estilo, Posición y Transparencia desde el estado
STYLE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/style" 2>/dev/null || echo "$BAR_STYLE")
POS=$(cat "$STATE_DIR/$CURRENT_ENV/bar/position" 2>/dev/null || echo "$BAR_POSITION")
TRANS=$(cat "$STATE_DIR/$CURRENT_ENV/bar/transparency" 2>/dev/null || echo "$BAR_TRANSPARENCY")

# 2. Aplicar Posición al config
if [ -f "$WAYBAR_CONFIG_FILE" ]; then
    sed -i "s/\"position\": \".*\"/\"position\": \"$POS\"/g" "$WAYBAR_CONFIG_FILE"
fi

# 3. Aplicar Transparencia al CSS si existe una variable de background
if [ -f "$WAYBAR_STYLE_SYMLINK" ]; then
    target_file="$(readlink -f "$WAYBAR_STYLE_SYMLINK")"
    if [ "$TRANS" == "false" ]; then
        # Opacidad completa
        sed -i "s/rgba(.*, .* , .*, 0\..*)/rgba(58, 56, 62, 1.0)/g" "$target_file"
    fi
fi

# 4. Linkear base theme
source_waybar_base_file="$WAYBAR_THEMES_BASE_DIR/$1"
if [ -f "$source_waybar_base_file" ]; then
    ln -sf "$source_waybar_base_file" "$WAYBAR_STYLE_SYMLINK"
fi

# 3. Aplicar Radio y Márgenes al estilo actual
if [ -f "$WAYBAR_STYLE_SYMLINK" ]; then
    # Resolvemos el link para aplicar el cambio al archivo real
    target_file="$(readlink -f "$WAYBAR_STYLE_SYMLINK")"
    
    if [ "$STYLE" == "round" ]; then
        RADIUS="10px"
        MARGIN="2px 3px"
    else
        RADIUS="0px"
        MARGIN="2px 0px"
    fi

    sed -i "s/border-radius: .*px;/border-radius: $RADIUS;/g" "$target_file"
    sed -i "s/margin: .*px;/margin: $MARGIN;/g" "$target_file"
fi
