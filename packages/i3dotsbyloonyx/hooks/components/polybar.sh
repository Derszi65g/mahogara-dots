#!/usr/bin/env bash
# hooks/components/polybar.sh

# 1. Leer Estado (Estilo, Posición, Transparencia, Tema)
STYLE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/style" 2>/dev/null || echo "square")
STYLE=$(echo "$STYLE" | tr -d '[:space:]')

POS=$(cat "$STATE_DIR/$CURRENT_ENV/bar/position" 2>/dev/null || echo "$BAR_POSITION")
POS=$(echo "$POS" | tr -d '[:space:]')

TRANS=$(cat "$STATE_DIR/$CURRENT_ENV/bar/transparency" 2>/dev/null || echo "$BAR_TRANSPARENCY")
TRANS=$(echo "$TRANS" | tr -d '[:space:]')

HEIGHT=$(cat "$STATE_DIR/$CURRENT_ENV/bar/height" 2>/dev/null || echo "$BAR_HEIGHT")
HEIGHT=$(echo "$HEIGHT" | tr -d '[:space:]')
[[ -z "$HEIGHT" ]] && HEIGHT="15pt"

TYPE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/type" 2>/dev/null || echo "principal")
TYPE=$(echo "$TYPE" | tr -d '[:space:]')

MODE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/mode" 2>/dev/null || echo "solid")
MODE=$(echo "$MODE" | tr -d '[:space:]')

# 2. Desplegar Archivos del Tema (Copia)
# Si es un enlace simbólico (de la instalación original), lo removemos para que sea independiente
if [ -L "$HOME/.config/polybar" ]; then
    rm "$HOME/.config/polybar"
fi

mkdir -p "$HOME/.config/polybar"
# Limpiar contenido anterior para evitar mezcla de archivos de distintos temas
rm -rf "$HOME/.config/polybar"/*

# Siempre copiar system.ini y hardware.ini (contiene la detección de hardware)
cp -f "$PACKAGE_DIR/dotfiles/polybar/system.ini" "$HOME/.config/polybar/"
cp -f "$PACKAGE_DIR/dotfiles/polybar/hardware.ini" "$HOME/.config/polybar/"

if [ "$TYPE" == "principal" ]; then
    cp -rf "$PACKAGE_DIR/dotfiles/polybar/." "$HOME/.config/polybar/"
elif [ -d "$PACKAGE_DIR/dotfiles/polybar_configs/$TYPE" ]; then
    cp -rf "$PACKAGE_DIR/dotfiles/polybar_configs/$TYPE/." "$HOME/.config/polybar/"
fi

# Asegurar que los colores dinámicos se apliquen sobre el tema nuevo
if [ -f "$STATE_DIR/$CURRENT_ENV/bar/transparency" ]; then
    # Forzamos una actualización de Matugen para que regenere colors.ini con el template correcto
    # Usamos el motor del core para mantener la consistencia
    if [ -f "$BIN_DIR/engine_matugen.sh" ]; then
        # No usamos DOT_SEQUENCE para evitar bucles, llamamos al motor directamente
        # Recuperamos la imagen actual del link
        IMG_PATH=$(readlink -f "$CURRENT_WALLPAPER_LINK")
        if [ -f "$IMG_PATH" ]; then
             bash "$BIN_DIR/engine_matugen.sh" -D -T scheme-fidelity -P saturation >/dev/null 2>&1
        fi
    fi
fi

# 3. Lógica de Radio, Posición y Escalado de Fuente
if [ "$STYLE" == "round" ]; then
    RADIUS=10
else
    RADIUS=0
fi

if [ "$POS" == "top" ]; then
    IS_BOTTOM="false"
else
    IS_BOTTOM="true"
fi

# Cálculo dinámico de fuentes basado en la altura (HEIGHT)
# Extraer solo el número de la altura (ej: 15pt -> 15)
H_NUM=$(echo "$HEIGHT" | grep -oE '[0-9]+' | head -n 1)
[[ -z "$H_NUM" ]] && H_NUM=15

if [ "$H_NUM" -le 15 ]; then
    F_TEXT=9
    F_ICON=12
    F_OFFSET=3
elif [ "$H_NUM" -le 18 ]; then
    F_TEXT=10
    F_ICON=14
    F_OFFSET=4
else
    F_TEXT=11
    F_ICON=16
    F_OFFSET=4
fi

# 4. Aplicar a config.ini (Preservando symlinks internos si los hay)
POLY_CONFIG="$HOME/.config/polybar/config.ini"
POLY_COLORS="$HOME/.config/polybar/colors.ini"
POLY_SYSTEM="$HOME/.config/polybar/system.ini"

if [ -f "$POLY_CONFIG" ]; then
    target_config="$(readlink -f "$POLY_CONFIG")"
    sed -i "s/^radius = .*/radius = $RADIUS/" "$target_config"
    sed -i "s/^bottom = .*/bottom = $IS_BOTTOM/" "$target_config"
    sed -i "s/^height = .*/height = $HEIGHT/" "$target_config"
    
    # Aplicar escalado de fuentes dinámico
    sed -i "s/^font-0 = .*/font-0 = \"JetBrainsMono Nerd Font Mono:style=Bold:size=$F_TEXT;$F_OFFSET\"/" "$target_config"
    sed -i "s/^font-1 = .*/font-1 = \"JetBrainsMono Nerd Font Mono:size=$F_ICON;$F_OFFSET\"/" "$target_config"
    sed -i "s/^font-2 = .*/font-2 = \"JetBrainsMono Nerd Font Mono:size=$F_TEXT:antialias=false;$F_OFFSET\"/" "$target_config"
    
    # Solo forzamos margin/padding en el tema principal para mantener su look de bloques
    if [ "$TYPE" == "principal" ]; then
        sed -i "s/^module-margin = .*/module-margin = 0/" "$target_config"
        sed -i "s/^padding-left = .*/padding-left = 0/" "$target_config"
        sed -i "s/^padding-right = .*/padding-right = 0/" "$target_config"
    fi
    
    # Transparencia Falsa
    if [ "$TRANS" == "false" ]; then
        sed -i "s/^pseudo-transparency = .*/pseudo-transparency = false/" "$target_config"
    else
        sed -i "s/^pseudo-transparency = .*/pseudo-transparency = true/" "$target_config"
    fi
fi

# 5. Aplicar Color de Fondo a colors.ini (Si existe)
if [ -f "$POLY_COLORS" ]; then
    target_colors="$(readlink -f "$POLY_COLORS")"
    if [ "$TRANS" == "false" ]; then
        SOLID_BG=$(grep "^background-solid =" "$target_colors" | cut -d' ' -f3)
        [[ -z "$SOLID_BG" ]] && SOLID_BG="#1a1b1e"
        sed -i "s/^background = .*/background = $SOLID_BG/" "$target_colors"
    else
        sed -i "s/^background = .*/background = #00000000/" "$target_colors"
    fi
fi

# 6. Ajustar Padding Interno de los módulos (Si existe system.ini o modules.ini)
POLY_MODULES="$HOME/.config/polybar/modules.ini"

if [ -f "$POLY_SYSTEM" ] || [ -f "$POLY_MODULES" ]; then
    # Determinar qué archivo usar (system.ini para principal, modules.ini para variantes)
    if [ "$TYPE" == "principal" ]; then
        TARGET_FILE="$(readlink -f "$POLY_SYSTEM")"
    else
        TARGET_FILE="$(readlink -f "$POLY_MODULES")"
    fi
    
    if [ -f "$TARGET_FILE" ]; then
        if [ "$STYLE" == "square" ]; then
            PAD=1
            W_PAD=1
        else
            PAD=1
            W_PAD=1
        fi
        sed -i "s/format-padding = .*/format-padding = $PAD/g" "$TARGET_FILE"
        sed -i "s/format-volume-padding = .*/format-volume-padding = $PAD/g" "$TARGET_FILE"
        sed -i "s/format-muted-padding = .*/format-muted-padding = $PAD/g" "$TARGET_FILE"
        sed -i "s/format-charging-padding = .*/format-charging-padding = $PAD/g" "$TARGET_FILE"
        sed -i "s/format-discharging-padding = .*/format-discharging-padding = $PAD/g" "$TARGET_FILE"
        sed -i "s/format-full-padding = .*/format-full-padding = $PAD/g" "$TARGET_FILE"

        # Aplicar Icono de OS
        if [ -n "$OS_ICON" ]; then
            # Intentar con [module/launcher] (Barra Principal)
            sed -i "/\[module\/launcher\]/,/format=/ s|format=.*|format=$OS_ICON|" "$TARGET_FILE"
            # Intentar con [module/rofi] (Variantes como floating/compact)
            # Primero eliminamos cualquier margen o fuente previa para evitar duplicados
            sed -i "/\[module\/rofi\]/,/\[/ { /format-margin =/ d; /format-font =/ d; /format-padding =/ d }" "$TARGET_FILE"
            # Inyectamos el icono limpio, padding en pixeles y el margen negativo
            sed -i "/\[module\/rofi\]/,/format=/ s|format=.*|format=\"$OS_ICON\"\nformat-font = 2\nformat-padding = 10px\nformat-margin-right = -7px|" "$TARGET_FILE"
        fi
    fi
fi

# 7. Ajustar i3-workspaces en config.ini
if [ -f "$POLY_CONFIG" ]; then
    target_config="$(readlink -f "$POLY_CONFIG")"
    sed -i "s/label-focused-padding = .*/label-focused-padding = $W_PAD/g" "$target_config"
    sed -i "s/label-visible-padding = .*/label-visible-padding = $W_PAD/g" "$target_config"
    sed -i "s/label-urgent-padding = .*/label-urgent-padding = $W_PAD/g" "$target_config"
    sed -i "s/label-unfocused-padding = .*/label-unfocused-padding = $W_PAD/g" "$target_config"
fi

# 8. Reiniciar polybar de forma segura
if [ -f "$HOME/.config/polybar/launch.sh" ]; then
    # Transformación dinámica para polybar_underline según el MODE (solid vs underline)
    if [ "$TYPE" == "polybar_underline" ] && [ -f "$POLY_MODULES" ]; then
        target_modules="$(readlink -f "$POLY_MODULES")"
        if [ "$MODE" == "underline" ]; then
            # Modo Underline: Híbrido. Rofi se queda pintado (solid).
            # Los demás pasan a underline (sin fondo, icono brillante).
            
            # 1. i3 Workspaces (Focused) -> Underline
            sed -i '/\[module\/i3\]/,/\[/ { 
                /label-focused-background/d; 
                s/label-focused-foreground[[:space:]]*=.*/label-focused-foreground = ${colors.primary}/;
                s/label-focused-underline[[:space:]]*=.*/label-focused-underline = ${colors.primary}/;
                /label-urgent-background/d;
                s/label-urgent-foreground[[:space:]]*=.*/label-urgent-foreground = ${colors.white0}/;
                s/label-urgent-underline[[:space:]]*=.*/label-urgent-underline = ${colors.red}/
            }' "$target_modules"
            
            # 2. XWindow -> Underline
            sed -i '/\[module\/xwindow\]/,/\[/ { /format-prefix-background/d; s/format-prefix-foreground.*/format-prefix-foreground = ${colors.green}/ }' "$target_modules"
            
            # 3. Time -> Underline
            sed -i '/\[module\/time\]/,/\[/ { /format-prefix-background/d; s/format-prefix-foreground.*/format-prefix-foreground = ${colors.primary}/ }' "$target_modules"
            
            # 4. CPU / Temp / Memory / Filesystem -> Underline
            sed -i '/\[module\/cpu\]/,/\[/ { /format-prefix-background/d; s/format-prefix-foreground.*/format-prefix-foreground = ${colors.green}/ }' "$target_modules"
            sed -i '/\[module\/temp\]/,/\[/ { /format-prefix-background/d; s/format-prefix-foreground.*/format-prefix-foreground = ${colors.green}/ }' "$target_modules"
            sed -i '/\[module\/memory\]/,/\[/ { /format-prefix-background/d; s/format-prefix-foreground.*/format-prefix-foreground = ${colors.green}/ }' "$target_modules"
            sed -i '/\[module\/filesystem\]/,/\[/ { /format-mounted-prefix-background/d; s/format-mounted-prefix-foreground.*/format-mounted-prefix-foreground = ${colors.green}/ }' "$target_modules"
            
            # 5. Pulseaudio -> Underline
            sed -i '/\[module\/pulseaudio\]/,/\[/ { /format-volume-prefix-background/d; s/format-volume-prefix-foreground.*/format-volume-prefix-foreground = ${colors.secondary}/ }' "$target_modules"
            
            # 6. Backlight -> Underline
            sed -i '/\[module\/backlight\]/,/\[/ { /format-prefix-background/d; s/format-prefix-foreground.*/format-prefix-foreground = ${colors.yellow}/ }' "$target_modules"

            # 7. Battery -> Underline
            sed -i '/\[module\/battery\]/,/\[/ { 
                /format-full-prefix-background/d; 
                s/format-full-prefix-foreground.*/format-full-prefix-foreground = ${colors.green}/;
                /ramp-capacity-background/d;
                s/ramp-capacity-foreground.*/ramp-capacity-foreground = ${colors.green}/;
                /animation-charging-background/d;
                s/animation-charging-foreground.*/animation-charging-foreground = ${colors.green}/ 
            }' "$target_modules"

            # Nota: Rofi NO se toca en este bloque, por lo que permanece "solid".
        fi
        # Si es "solid", no hacemos nada porque el archivo ya está en modo solid por defecto
    fi

    (sleep 0.2; bash "$HOME/.config/polybar/launch.sh") &
fi
