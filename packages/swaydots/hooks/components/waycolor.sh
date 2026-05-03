#!/usr/bin/env bash
# $1: Nombre del archivo generado (ej: colors.css)

# El archivo de origen viene de la caché local del entorno
source_color_file="${HELLWAL_CACHE_DIR}${1}"

# El destino se basa en la variable de entorno WAYBAR_CONFIG_DIR del .env
if [ -z "$WAYBAR_CONFIG_DIR" ]; then
    echo "Error: WAYBAR_CONFIG_DIR no definida en el .env" >&2
    exit 1
fi

if [ -f "$source_color_file" ]; then
    # Crear el enlace simbólico dinámicamente
    ln -sf "$source_color_file" "${WAYBAR_CONFIG_DIR}/colors.css"
fi
