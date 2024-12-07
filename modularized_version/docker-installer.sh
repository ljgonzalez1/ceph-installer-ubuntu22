#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

# Lista de paquetes conflictivos que deben eliminarse
declare -x CONFLICTING_PACKAGES=(
    "docker.io"
    "docker-doc"
    "docker-compose"
    "docker-compose-v2"
    "podman-docker"
    "containerd"
    "runc"
    # Instalaciones viejas
    "docker-ce"
    "docker-ce-cli"
    "containerd.io"
    "docker-buildx-plugin"
    "docker-compose-plugin"
)

# Lista de paquetes de Docker a instalar
declare -x DOCKER_PACKAGES=(
    "docker-ce"
    "docker-ce-cli"
    "containerd.io"
    "docker-buildx-plugin"
    "docker-compose-plugin"
)

cleanup() {
    stop_spinner
    echo
    show_error "Docker installation cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

remove_conflicting_packages() {
    echo -e "${BOLD}Removing conflicting packages...${RESET}"
    
    for pkg in "${CONFLICTING_PACKAGES[@]}"; do
        if dpkg -l | grep -q "^ii.*$pkg"; then
            start_spinner "Removing package '$pkg'..."
            if ! apt-get remove -y -qq "$pkg" >/dev/null 2>&1; then
                stop_spinner
                show_warn "Failed to remove ${ITALIC}'$pkg'${END_ITALIC}. Continuing anyway..."
            else
                stop_spinner
                show_ok "Package ${ITALIC}'$pkg'${END_ITALIC} removed successfully."
            fi
        fi
    done

    show_ok "${BOLD}Conflictind packages successfully removed.${RESET}"
}

setup_docker_keys() {
    echo -e "${BOLD}Setting up Docker repository keys...${RESET}"
    
    start_spinner "Creating keyring directory..."
    if ! install -m 0755 -d /etc/apt/keyrings; then
        stop_spinner
        show_error "Failed to create keyring directory."
        crit_error
    fi
    stop_spinner
    show_ok "Keyring directory created."
    
    start_spinner "Downloading Docker GPG key..."
    if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; then
        stop_spinner
        show_error "Failed to download Docker GPG key."
        crit_error
    fi
    stop_spinner
    show_ok "Docker GPG key downloaded."
    
    start_spinner "Setting key permissions..."
    if ! chmod a+r /etc/apt/keyrings/docker.asc; then
        stop_spinner
        show_error "Failed to set key permissions."
        crit_error
    fi
    stop_spinner
    show_ok "Key permissions set."
    
    show_ok "${BOLD}GPG Keys successfully imported.${RESET}"
}

add_docker_repository() {
    echo -e "${BOLD}Adding Docker repository...${RESET}"
    
    start_spinner "Adding Docker repository..."
    if ! echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null; then
        stop_spinner
        show_error "Failed to add Docker repository."
        crit_error
    fi
    stop_spinner
    show_ok "Docker repository added."
    
    start_spinner "Updating apt repositories..."
    if ! apt-get update -qq >/dev/null 2>&1; then
        stop_spinner
        show_error "Failed to update repositories."
        crit_error
    fi
    stop_spinner
    show_ok "Apt repositories updated."
    
    show_ok "${BOLD}Docker repositiory ready.${RESET}"
}

install_docker_packages() {
    echo -e "${BOLD}Installing Docker packages...${RESET}"
    
    for pkg in "${DOCKER_PACKAGES[@]}"; do
        start_spinner "Installing package '$pkg'..."
        if ! apt-get install -y -qq "$pkg" >/dev/null 2>&1; then
            stop_spinner
            show_error "Failed to install ${ITALIC}'$pkg'${END_ITALIC}."
            crit_error
        fi
        stop_spinner
        show_ok "Package ${ITALIC}'$pkg'${END_ITALIC} installed successfully."
    done
    
    show_ok "${BOLD}Docker installation completed successfully.${RESET}"
    echo
}

install_docker() {
    echo -e "${BOLD}## Installing Docker Engine...${RESET}"

    remove_conflicting_packages
    setup_docker_keys
    add_docker_repository
    install_docker_packages
}
