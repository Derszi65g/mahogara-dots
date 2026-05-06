#!/usr/bin/env bash
# hooks/components/polybar.sh - Versión Ultra-Optimizada (RAM + Symlinks)

# 1. Leer Estado
STYLE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/style" 2>/dev/null || echo "square")
POS=$(cat "$STATE_DIR/$CURRENT_ENV/bar/position" 2>/dev/null || echo "$BAR_POSITION")
TRANS=$(cat "$STATE_DIR/$CURRENT_ENV/bar/transparency" 2>/dev/null || echo "$BAR_TRANSPARENCY")
HEIGHT=$(cat "$STATE_DIR/$CURRENT_ENV/bar/height" 2>/dev/null || echo "$BAR_HEIGHT")
TYPE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/type" 2>/dev/null || echo "polybar_antigua")
MODE=$(cat "$STATE_DIR/$CURRENT_ENV/bar/mode" 2>/dev/null || echo "solid")

# Limpiar espacios
STYLE=$(echo "$STYLE" | tr -d '[:space:]'); POS=$(echo "$POS" | tr -d '[:space:]')
TRANS=$(echo "$TRANS" | tr -d '[:space:]'); HEIGHT=$(echo "$HEIGHT" | tr -d '[:space:]')
TYPE=$(echo "$TYPE" | tr -d '[:space:]'); MODE=$(echo "$MODE" | tr -d '[:space:]')
[[ -z "$HEIGHT" ]] && HEIGHT="15pt"

# 2. Setup de Directorio con Enlaces Simbólicos
CONF_DIR="$HOME/.config/polybar"
[ -f "$CONF_DIR/colors.ini" ] && cp "$CONF_DIR/colors.ini" "/tmp/poly_colors.ini"
rm -rf "$CONF_DIR"
mkdir -p "$CONF_DIR"

if [ -f "/tmp/poly_colors.ini" ]; then
    mv "/tmp/poly_colors.ini" "$CONF_DIR/colors.ini"
else
    ln -sf "$PACKAGE_DIR/dotfiles/polybar_base/colors.ini" "$CONF_DIR/colors.ini"
fi

ln -sf "$PACKAGE_DIR/dotfiles/polybar_base/hardware.ini" "$CONF_DIR/hardware.ini"
ln -sf "$PACKAGE_DIR/dotfiles/polybar_base/scripts" "$CONF_DIR/scripts"

THEME_SRC="$PACKAGE_DIR/dotfiles/polybar_configs/$TYPE"
if [ -d "$THEME_SRC" ]; then
    ln -sfT "$THEME_SRC" "$CONF_DIR/current_theme"
    ln -sf "$CONF_DIR/current_theme/launch.sh" "$CONF_DIR/launch.sh"
fi

# 3. Preparar Variables para RAM (/dev/shm)
[ "$STYLE" == "round" ] && RADIUS=10 || RADIUS=0
[ "$POS" == "top" ] && IS_BOTTOM="false" || IS_BOTTOM="true"

H_NUM=$(echo "$HEIGHT" | grep -oE '[0-9]+' | head -n 1)
[[ -z "$H_NUM" ]] && H_NUM=15
if [ "$H_NUM" -le 15 ]; then
    F_TEXT=9; F_ICON=12; F_OFFSET=3
elif [ "$H_NUM" -le 18 ]; then
    F_TEXT=10; F_ICON=14; F_OFFSET=4
else
    F_TEXT=11; F_ICON=16; F_OFFSET=4
fi

if [ "$TRANS" == "false" ]; then
    BG_COLOR="\${colors.background-solid}"
    P_TRANS="false"
else
    BG_COLOR="#00000000"
    P_TRANS="true"
fi

if [ "$MODE" == "underline" ]; then
    MOD_FOC_BG="\${colors.background-solid}"
    MOD_FOC_FG="\${colors.primary}"
    MOD_FOC_UND="\${colors.primary}"
    MOD_PRE_BG="\${colors.background-solid}"
    MOD_PRE_FG="\${colors.primary}"
    MOD_ROFI_BG="\${colors.primary}"
    MOD_ROFI_FG="\${colors.background-solid}"
else
    MOD_FOC_BG="\${colors.primary}"
    MOD_FOC_FG="\${colors.background-solid}"
    MOD_FOC_UND="\${colors.primary}"
    MOD_PRE_BG="\${colors.primary}"
    MOD_PRE_FG="\${colors.background-solid}"
    MOD_ROFI_BG="\${colors.primary}"
    MOD_ROFI_FG="\${colors.background-solid}"
fi

LAUNCH_ICON="${OS_ICON:-󱘊}"

# 4. Escribir en RAM
RAM_CONFIG="/dev/shm/user_configs.ini"
cat > "$RAM_CONFIG" <<EOF
[vars]
height = $HEIGHT
radius = $RADIUS
bottom = $IS_BOTTOM
pseudo-transparency = $P_TRANS
background = $BG_COLOR
font-0 = "JetBrainsMono Nerd Font Mono:style=Bold:size=$F_TEXT;$F_OFFSET"
font-1 = "JetBrainsMono Nerd Font Mono:size=$F_ICON;$F_OFFSET"
font-2 = "JetBrainsMono Nerd Font Mono:size=$F_TEXT:antialias=false;$F_OFFSET"
module-padding = 1
label-padding = 1
focused-bg = $MOD_FOC_BG
focused-fg = $MOD_FOC_FG
focused-underline = $MOD_FOC_UND
prefix-bg = $MOD_PRE_BG
prefix-fg = $MOD_PRE_FG
rofi-bg = $MOD_ROFI_BG
rofi-fg = $MOD_ROFI_FG
launcher-icon = "$LAUNCH_ICON"
EOF

# 5. Configuración de entrada única para Polybar
cat > "$CONF_DIR/config.ini" <<EOF
[global/wm]
include-file = \$HOME/.config/polybar/colors.ini
include-file = /dev/shm/user_configs.ini
include-file = \$HOME/.config/polybar/current_theme/config.ini
EOF

# 6. Lanzar
bash "$CONF_DIR/launch.sh" &
