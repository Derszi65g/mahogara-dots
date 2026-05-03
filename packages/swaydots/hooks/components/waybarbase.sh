#!/usr/bin/env bash
# $1 es el valor del .txt (ej: waybar_base.css)
source_waybar_base_file="$WAYBAR_THEMES_BASE_DIR/$1"
if [ -f "$source_waybar_base_file" ]; then
    ln -sf "$source_waybar_base_file" "$WAYBAR_STYLE_SYMLINK"
fi
