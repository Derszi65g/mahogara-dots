pkill waybar
sleep 1 # Dar tiempo real para morir

# Usar variables del paquete (config.env)
# Si no existen, usamos fallback a la ruta del paquete
W_CONF="${WAYBAR_CONFIG_FILE:-$PACKAGE_DIR/dotfiles/waybar/config}"
W_STYLE="${WAYBAR_STYLE_FILE:-$PACKAGE_DIR/dotfiles/waybar/style.css}"

# Carga de modo dinámico (cache)
[ -f "$HOME/.cache/waybar_active.sh" ] && source "$HOME/.cache/waybar_active.sh"

if [ "$WAYBAR_MODE" == "bibjaw99" ]; then
     VARIANT=${WAYBAR_VARIANT:-waybar_block_1}
     # Nota: Aquí asumo que bibjaw99 también debería estar en el paquete o en un path estándar
     waybar -c "$HOME/.config/waybar/bibjaw99/$VARIANT/config.jsonc" -s "$HOME/.config/waybar/bibjaw99/$VARIANT/style.css" > /tmp/waybar_hook.log 2>&1 & disown
elif [ "$WAYBAR_MODE" == "spelljinxer" ]; then
     waybar -c "$HOME/.config/waybar-spelljinxer/config.jsonc" -s "$HOME/.config/waybar-spelljinxer/style.css" > /tmp/waybar_hook.log 2>&1 & disown
else
     # Ejecución estándar usando las rutas del paquete
     waybar -c "$W_CONF" -s "$W_STYLE" > /tmp/waybar_hook.log 2>&1 & disown
fi
