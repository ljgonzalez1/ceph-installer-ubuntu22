#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

cleanup() {
    stop_spinner
    echo
    show_error "SSH setup cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

check_ssh_key() {
    if [[ -f "/root/.ssh/id_rsa" && -f "/root/.ssh/id_rsa.pub" ]]; then
        return 0
    fi
    return 1
}

generate_ssh_key() {
    echo -e "${BOLD}## Generating SSH key pair...${RESET}"
    
    start_spinner "Creating SSH directory..."
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    stop_spinner
    show_ok "SSH directory created."
    
    start_spinner "Generating new SSH key pair..."
    ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        stop_spinner
        show_ok "SSH key pair generated successfully."
        chmod 600 /root/.ssh/id_rsa
        chmod 644 /root/.ssh/id_rsa.pub
        return 0
    else
        stop_spinner
        show_error "Failed to generate SSH key pair."
        return 1
    fi
}

configure_ssh() {
    echo -e "${BOLD}## Configuring SSH daemon...${RESET}"
    
    local sshd_config="/etc/ssh/sshd_config"
    local temp_config
    temp_config=$(mktemp)
    
    start_spinner "Updating SSH configuration..."
    
    # Eliminar líneas existentes de PermitRootLogin
    grep -v "^#*PermitRootLogin" "$sshd_config" > "$temp_config"
    
    # Agregar nueva configuración al final
    echo "" >> "$temp_config"
    echo "# Added by Ceph installation script" >> "$temp_config"
    echo "PermitRootLogin yes" >> "$temp_config"
    
    # Reemplazar archivo original
    mv "$temp_config" "$sshd_config"
    chmod 644 "$sshd_config"
    
    stop_spinner
    show_ok "SSH configuration updated."
    
    start_spinner "Restarting SSH service..."
    if systemctl restart sshd >/dev/null 2>&1; then
        stop_spinner
        show_ok "SSH service restarted successfully."
        return 0
    else
        stop_spinner
        show_error "Failed to restart SSH service."
        return 1
    fi
}

setup_ssh() {
    echo -e "${BOLD}## Setting up SSH...${RESET}"
    
    # Verificar si ya existe una clave SSH
    start_spinner "Checking for existing SSH key..."
    if check_ssh_key; then
        stop_spinner
        show_ok "SSH key already exists."
    else
        stop_spinner
        show_warn "No SSH key found."
        if ! generate_ssh_key; then
            crit_error
        fi
    fi
    
    # Configurar el servicio SSH
    if ! configure_ssh; then
        crit_error
    fi
    
    show_ok "${BOLD}SSH setup completed successfully.${RESET}"
    echo
}
