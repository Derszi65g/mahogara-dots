#!/usr/bin/env bash
# launch.sh - Lanzador de aplicaciones para i3dotsbyloonyx

# 1. Obtener la ruta del wallpaper actual desde el estado gestionado
IMAGE_PATH=$(cat "$HOME/.config/matugen/wallpaper.txt" 2>/dev/null || echo "$HOME/wall/wall.png")

# 2. Obtener el tema configurado desde el entorno
THEME="${ROFI_THEME:-$HOME/.config/rofi/themes/launcher.rasi}"

# 3. Ejecutar Rofi con el override de la imagen de fondo
rofi -show drun -theme "$THEME" -theme-str "inputbar { background-image: url(\"$IMAGE_PATH\", width); }"
