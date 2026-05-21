# i3 dots

# Imagenes

<details><summary><h2>Fullscreen</h2></summary>

![](/assets/Screenshot_2026-04-30_17-12-09.jpg)

</details><br>

<details><summary><h2>Rofi Launcher</h2></summary>

![](/assets/Screenshot_2026-04-30_17-12-45.jpg)

</details><br>

<details><summary><h2>Wallpaper Selector</h2></summary>

![](/assets/Screenshot_2026-04-30_17-13-07.jpg)

</details><br>

<details><summary><h2>Rofi Powermenu</h2></summary>

![](/assets/Screenshot_2026-04-30_17-13-40.jpg)

</details><br>

### Dependencias: 
```
sudo apt install i3 polybar rofi feh maim xclip xdotool nemo autotiling kitty
cargo install matugen
```
# Instalacion 

```
mkdir screenshots
```

```
git clone https://github.com/Loonyx1/i3dots.git
```

```
cd i3dots
```
### Para install del dotfile en debian 13
```
./install.sh
```
### Para install del dotfile en voidlinux/nekovoid
```
./installvoid.sh
```

# Gestión de Barras (Polybar)

Este paquete incluye un motor dinámico para gestionar múltiples estilos y temas de Polybar sin editar archivos manualmente.

### Comandos Principales
Puedes gestionar la barra usando el orquestador `dots`:
- **Menú Interactivo**: `./dots bar` (abre un selector para estilo, posición, temas y transparencia).
- **Cambiar Tema**: `./dots bar -b <nombre_del_tema>`
- **Cambiar Estilo de Bordes**: `./dots bar -s <round|square>`
- **Cambiar Posición**: `./dots bar -p <top|bottom>`
- **Alternar Transparencia**: `./dots bar -t <true|false>`

### Temas Disponibles
1.  **principal**: La barra base con soporte para modos `round` y `square`.
2.  **polybar_compact**: Versión flotante con módulos pegados (estilo bloque).
3.  **polybar_floating**: Versión flotante con separaciones finas entre módulos.
4.  **polybar_underline**: Estilo con barras de colores inferiores.

### Personalización en `config.env`
Puedes definir tus preferencias por defecto editando `packages/i3dots/config.env`:
```bash
export BAR_STYLE="square"       # round o square
export BAR_POSITION="bottom"    # top o bottom
export BAR_TRANSPARENCY="true"  # true o false
```

### Integración con Matugen
Todos los temas están sincronizados con **Matugen**. Al cambiar el wallpaper o desactivar la transparencia, la barra usará automáticamente los colores generados (`background-solid`, `primary`, `secondary`, etc.) para mantener la armonía visual.

# Teclas/Atajos

| Keys | Action |
|:-|:-|
|<kbd>super</kbd> + <kbd>D</kbd>|Rofi Launcher
|<kbd>super</kbd> + <kbd>F</kbd>| Fullscreen switcher
|<kbd>super</kbd> + <kbd>Q</kbd>| Kill Focused Window
|<kbd>super</kbd> + <kbd>W</kbd>|  wallpaper Selector
|<kbd>super</kbd> + <kbd>Tab</kbd>|Powermenu
|<kbd>Super</kbd> + <kbd> E | nemo
|<kbd>super</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd>| Restart I3
|<kbd>Super</kbd> | Hold to drag floating windows to the desired position
# Screenshots keys on clipboard

| Keys | Screenshot  |
|:-|:-|
|<kbd>super</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd>|Selection|
|<kbd>super</kbd> + <kbd>print</kbd>|Active Window
|<kbd>Print</kbd>|Full Screen|

# Screenshots (Carpeta ~/screenshots)

| Keys | Screenshot  |
|:-|:-|
|<kbd>Shift</kbd> + <kbd>print</kbd>|Selection|
|<kbd>super</kbd> + <kbd>Ctrl</kbd> + <kbd>print</kbd>|Active Window
|<kbd>Ctrl</kbd> + <kbd>Print</kbd> |Full Screen|
