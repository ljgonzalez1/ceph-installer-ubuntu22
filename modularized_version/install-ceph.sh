#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${SCRIPT_DIR}/signature.sh"
source "${SCRIPT_DIR}/messages.sh"
source "${SCRIPT_DIR}/root-checker.sh"
source "${SCRIPT_DIR}/package-checker.sh"
source "${SCRIPT_DIR}/package-installer.sh"
source "${SCRIPT_DIR}/installation-checker.sh"
source "${SCRIPT_DIR}/hostname-selector.sh"
source "${SCRIPT_DIR}/docker-installer.sh"
source "${SCRIPT_DIR}/root-password.sh"
source "${SCRIPT_DIR}/network-configuration.sh"

cleanup() {
    stop_spinner
    echo
    show_error "Installation cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

main() {
    show_signature

    check_root_user

    if ! check_dependencies; then
        install_missing_dependencies "${MISSING_PKGS[@]}"
    fi

    # Preguntar al usuario sobre la instalación
    ask_installation_requirements

    # Configurar hostname
    if ! set_hostname; then
        cleanup
    fi

    echo

    setup_network

    setup_root_password

    install_docker
}

echo

main

echo
exit 0
