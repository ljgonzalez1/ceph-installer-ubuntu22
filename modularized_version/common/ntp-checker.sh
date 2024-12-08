#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

cleanup() {
    stop_spinner
    echo
    show_error "Time synchronization check cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

check_time_sync() {
    echo -e "${BOLD}## Checking time synchronization...${RESET}"

    # Verificar si timedatectl está disponible
    start_spinner "Checking timedatectl availability..."
    if ! command -v timedatectl >/dev/null 2>&1; then
        stop_spinner
        show_error "timedatectl command not found"
        crit_error
    fi
    stop_spinner
    show_ok "timedatectl is available"

    # Obtener el estado de la sincronización forzando idioma inglés
    start_spinner "Checking NTP synchronization status..."
    
    # Capturar la salida forzando el idioma inglés
    local timedatectl_output
    timedatectl_output=$(LANG=C timedatectl)
    
    # Verificar NTP service
    if ! echo "$timedatectl_output" | grep -q "NTP service: active"; then
        stop_spinner
        show_error "NTP service is not active"
        crit_error
    fi

    # Verificar sincronización
    if ! echo "$timedatectl_output" | grep -q "System clock synchronized: yes"; then
        stop_spinner
        show_error "Time is not synchronized"
        crit_error
    fi

    stop_spinner
    show_ok "Time is properly synchronized with NTP"
    echo
    return 0
}
