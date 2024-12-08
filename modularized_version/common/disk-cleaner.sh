#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

cleanup() {
    stop_spinner
    echo
    show_error "Disk cleaning cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

clean_disk() {
    local disk=$1
    local success=true

    # Intentar desmontaje si está montado
    if mount | grep -q "^$disk"; then
        start_spinner "Unmounting ${disk}..."
        if ! umount -f "$disk" >/dev/null 2>&1; then
            stop_spinner
            show_error "Failed to unmount ${disk}"
            success=false
        else
            stop_spinner
            show_ok "Disk ${disk} unmounted"
        fi
    fi

    # Limpiar tabla de particiones
    if [ "$success" = true ]; then
        start_spinner "Cleaning partition table on ${disk}..."
        if ! sgdisk --zap-all "$disk" >/dev/null 2>&1; then
            stop_spinner
            show_error "Failed to clean partition table on ${disk}"
            success=false
        else
            stop_spinner
            show_ok "Partition table cleaned on ${disk}"
        fi
    fi

    # Limpiar firmas del sistema de archivos
    if [ "$success" = true ]; then
        start_spinner "Wiping filesystem signatures on ${disk}..."
        if ! wipefs --all --force "$disk" >/dev/null 2>&1; then
            stop_spinner
            show_error "Failed to wipe filesystem signatures on ${disk}"
            success=false
        else
            stop_spinner
            show_ok "Filesystem signatures wiped on ${disk}"
        fi
    fi

    return $([ "$success" = true ])
}

clean_selected_disks() {
    if [ -z "$CEPH_DISKS" ]; then
        show_error "No disks selected for cleaning"
        return 1
    fi

    echo -e "${BOLD}## Cleaning selected disks...${RESET}"
    
    local all_success=true

    for disk in "${CEPH_DISKS[@]}"; do
        if ! clean_disk "$disk"; then
            all_success=false
            show_warn "Failed to clean disk ${disk}"
        else
            show_ok "Disk ${disk} cleaned successfully"
        fi
    done

    if [ "$all_success" = true ]; then
        show_ok "${BOLD}All disks cleaned successfully${RESET}"
        echo
        return 0
    else
        show_error "${BOLD}Some disks could not be cleaned${RESET}"
        echo
        return 1
    fi
}
