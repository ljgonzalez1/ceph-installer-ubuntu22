#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"

ask_installation_requirements() {
    echo -e "${BOLD}## Waiting for user consent to proceed with the installation...${RESET}"

    # Archivo temporal para capturar el resultado del diálogo
    TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
    DIALOG_OUTPUT=$(mktemp /tmp/dialog_output.XXXXXX)

    # Crear el script que ejecutará el diálogo
    cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Ceph Installation" --yesno \
"Ceph installation requires Docker and Cephadm. Do you wish to proceed?" 10 60
echo \$? > "$DIALOG_OUTPUT"
EOF

    chmod +x "$TEMP_SCREEN_SCRIPT"

    # Ejecutar el diálogo en screen
    screen -q -dmS dialog_session bash "$TEMP_SCREEN_SCRIPT"
    screen -q -r dialog_session

    # Mover el cursor hacia arriba y borrar la línea
    printf "\033[A\r\033[K"

    # Leer el resultado del diálogo
    if [[ -f "$DIALOG_OUTPUT" ]]; then
        RESPONSE=$(<"$DIALOG_OUTPUT")
        rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
    else
        show_error "Failed to capture user input."
        exit 1
    fi

    # Procesar la respuesta del usuario
    if [[ "$RESPONSE" -eq 0 ]]; then
        show_ok "User accepted the installation."
    else
        show_error "User declined the installation."
        exit 1
    fi

    echo
}
