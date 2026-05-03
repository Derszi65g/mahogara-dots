#!/usr/bin/env bash
# $1 es el valor del .txt (ej: power)
value_base=$(echo "$1" | sed 's/\.rasi$//')
source_rasi_file="$HELLWAL_CACHE_DIR/${value_base}.rasi"
target_symlink_path="$ROFI_SHARED_THEMES_DIR/power.rasi"
if [ -f "$source_rasi_file" ]; then
    ln -sf "$source_rasi_file" "$target_symlink_path"
fi
