#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${SCRIPT_DIR}/common/special-character-support.sh"
source "${SCRIPT_DIR}/common/signature.sh"
source "${SCRIPT_DIR}/common/messages.sh"
source "${SCRIPT_DIR}/common/root-checker.sh"
source "${SCRIPT_DIR}/common/package-checker.sh"
source "${SCRIPT_DIR}/common/package-installer.sh"
source "${SCRIPT_DIR}/common/installation-checker.sh"
source "${SCRIPT_DIR}/common/hostname-selector.sh"
source "${SCRIPT_DIR}/common/docker-installer.sh"
source "${SCRIPT_DIR}/common/root-password.sh"
source "${SCRIPT_DIR}/common/network-configuration.sh"
source "${SCRIPT_DIR}/common/ssh-setup.sh"
source "${SCRIPT_DIR}/common/disk-selector.sh"
source "${SCRIPT_DIR}/common/disk-cleaner.sh"
source "${SCRIPT_DIR}/common/node-type-selector.sh"
source "${SCRIPT_DIR}/common/ntp-checker.sh"


cleanup() {
    stop_spinner
    echo
    show_error "Installation cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

main() {
    test_special_character_support

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

    setup_network

    echo

    setup_root_password

    install_docker

    setup_ssh

    select_ceph_disks

    clean_selected_disks

    check_time_sync

    ask_for_node_type
    
}

echo

main

echo
exit 0
