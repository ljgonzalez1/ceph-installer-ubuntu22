#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

cleanup() {
    stop_spinner
    echo
    show_error "Installation cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

install_missing_dependencies() {
    local packages=("$@")
    
    echo -e "${BOLD}## Installing missing dependencies...${RESET}"
    
    start_spinner "Updating apt repositories..."
    if ! apt-get update -qq >/dev/null 2>&1; then
        stop_spinner
        show_error "Failed to update repositories."
        crit_error
    fi
    stop_spinner
    show_ok "Apt repositories updated."

    for pkg in "${packages[@]}"; do
        start_spinner "Installing package '$pkg'..."
        if ! apt-get install -y -qq "$pkg" >/dev/null 2>&1; then
            stop_spinner
            show_error "Failed to install ${ITALIC}'$pkg'${END_ITALIC}."
            crit_error
        fi
        stop_spinner
        show_ok "Package ${ITALIC}'$pkg'${END_ITALIC} installed successfully."
    done

    show_ok "${BOLD}All missing dependencies were successfully installed.${RESET}"
    echo
}
