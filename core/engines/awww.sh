#!/usr/bin/env bash

# Engine: awww (wrapper de swww)

engine_init() {
    awww query >/dev/null 2>&1 || awww init || { echo "Error: Daemon awww no inicia." >&2; return 1; }
}

engine_set() {
    local wp_path="$1"
    
    # Usar opciones de config.env o defaults si no existen
    if [[ -z "${WP_TRANSITION_OPTS[*]}" ]]; then
        local opts=(
            "--transition-type" "wipe"
            "--transition-fps" "60"
            "--transition-duration" "0.7"
        )
    else
        local opts=("${WP_TRANSITION_OPTS[@]}")
    fi
    
    awww img "$wp_path" "${opts[@]}"
}
