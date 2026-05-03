#!/usr/bin/env bash
# $1 es el valor del .txt (ej: kitty_colors.conf)
source_kitty_file="$HELLWAL_CACHE_DIR/$1"
if [ -f "$source_kitty_file" ]; then
    ln -sf "$source_kitty_file" "$KITTY_CONFIG_DIR/kitty.conf"
fi
