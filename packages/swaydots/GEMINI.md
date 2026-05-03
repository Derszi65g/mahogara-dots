# Reglas de Desarrollo - Swaydots

Este paquete sigue una arquitectura orientada a hooks.

## Convenciones

- **Hooks de Componentes**: Deben recibir `$1` como el nombre del archivo de recurso (ej. `colors.css`).
- **Variables de Entorno**: Usar prefijos claros en `config.env`.
- **Rutas**: Preferir rutas relativas a `$PACKAGE_DIR` cuando sea posible.
- **Portabilidad**: Evitar rutas hardcodeadas a `/home/dereck`. Usar `$HOME`.

## Flujo de Aplicación

1. El core (`apply_dots.sh`) lee `MANAGED_COMPONENTS`.
2. Para cada componente, busca `hooks/components/<componente>.sh`.
3. Ejecuta el script pasando el valor de `COMPONENT_<NOMBRE>`.
