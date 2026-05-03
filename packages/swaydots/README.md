# Swaydots

Configuración modular para Sway con generación dinámica de colores (Hellwal).

## Estructura

- `config.env`: Definición de variables de entorno y secuencias de ejecución (`DOT_SEQUENCE`).
- `install.sh`: Script para instalar el paquete en el sistema.
- `hooks/`:
    - `components/`: Scripts que aplican cambios específicos por componente (waybar, kitty, etc).
    - `envs/`: Scripts de inicialización de entorno.
- `templates/`: Plantillas para el motor de colores Hellwal.
- `dotfiles/`: Archivos de configuración estáticos.

## Cómo añadir un componente

1. Crea la configuración en `dotfiles/`.
2. Añade las variables necesarias en `config.env`.
3. Crea un hook en `hooks/components/<componente>.sh`.
4. Registra el componente en `MANAGED_COMPONENTS` dentro de `config.env`.

## Secuencias (`DOT_SEQUENCE`)

Define el orden de ejecución de los binarios del core (`wp_select.sh`, `engine_hellwal.sh`, `apply_dots.sh`).
