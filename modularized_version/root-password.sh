#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

cleanup() {
    stop_spinner
    echo
    show_error "Password setup cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

check_root_password() {
    # Verificar si root tiene contraseña establecida
    local has_password
    has_password=$(passwd -S root | awk '{print $2}')
    
    if [[ "$has_password" == "P" ]]; then
        return 0  # Tiene contraseña
    else
        return 1  # No tiene contraseña
    fi
}

validate_password() {
    local password="$1"
    
    # Verificar longitud mínima de 12 caracteres
    if [[ ${#password} -lt 12 ]]; then
        echo "Password must be at least 12 characters long."
        return 1
    fi
    
    return 0
}

confirm_cancel() {
    local TEMP_SCREEN_SCRIPT DIALOG_OUTPUT
    
    TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
    DIALOG_OUTPUT=$(mktemp /tmp/dialog_output.XXXXXX)
    
    cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Confirm Cancel" --yesno \
"Root password is required. Are you sure you want to cancel the installation?" 8 60
echo \$? > "$DIALOG_OUTPUT"
EOF
    
    chmod +x "$TEMP_SCREEN_SCRIPT"
    
    screen -q -dmS dialog_session bash "$TEMP_SCREEN_SCRIPT"
    screen -q -r dialog_session
    
    printf "\033[A\033[K"
    
    RESPONSE=$(<"$DIALOG_OUTPUT")
    rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
    
    return "$RESPONSE"
}

set_root_password() {
    local password1 password2 validation_message=""
    local TEMP_SCREEN_SCRIPT TEMP_PASSWORD1 TEMP_PASSWORD2
    local has_password=$1
    
    while true; do
        # Crear archivos temporales
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_PASSWORD1=$(mktemp /tmp/password1.XXXXXX)
        TEMP_PASSWORD2=$(mktemp /tmp/password2.XXXXXX)
        
        # Crear script para dialog con o sin botón de cancelar según el caso
        if [[ "$has_password" == "true" ]]; then
            cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Root Password Setup" \
    --ok-label "OK" \
    --cancel-label "Cancel" \
    --insecure \
    --passwordbox "${validation_message}Enter new root password:
(Minimum 12 characters)" 12 70 2>"$TEMP_PASSWORD1"
if [ \$? -eq 1 ]; then
    exit 1
fi

dialog --title "Root Password Setup" \
    --ok-label "OK" \
    --cancel-label "Cancel" \
    --insecure \
    --passwordbox "Confirm root password:" 10 70 2>"$TEMP_PASSWORD2"
if [ \$? -eq 1 ]; then
    exit 1
fi
EOF
        else
            cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Root Password Setup" \
    --ok-label "OK" \
    --cancel-label "Cancel" \
    --insecure \
    --passwordbox "${validation_message}Enter new root password:
(Minimum 12 characters)" 12 70 2>"$TEMP_PASSWORD1"
if [ \$? -eq 1 ]; then
    exit 2
fi

dialog --title "Root Password Setup" \
    --ok-label "OK" \
    --cancel-label "Cancel" \
    --insecure \
    --passwordbox "Confirm root password:" 10 70 2>"$TEMP_PASSWORD2"
if [ \$? -eq 1 ]; then
    exit 2
fi
EOF
        fi
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        # Ejecutar diálogo en screen
        screen -q -dmS password_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r password_session
        DIALOG_EXIT_CODE=$?
        
        # Mover el cursor
        printf "\033[A\033[K"
        
        # Manejar la cancelación según el caso
        if [[ "$DIALOG_EXIT_CODE" -eq 1 ]]; then
            if [[ "$has_password" == "true" ]]; then
                show_ok "Keeping current root password."
                return 0
            fi
        elif [[ "$DIALOG_EXIT_CODE" -eq 2 ]]; then
            if confirm_cancel; then
                show_error "Root password setup cancelled. A root password is required."
                exit 1
            else
                continue
            fi
        fi
        
        # Leer contraseñas
        if [[ -f "$TEMP_PASSWORD1" && -f "$TEMP_PASSWORD2" ]]; then
            password1=$(<"$TEMP_PASSWORD1")
            password2=$(<"$TEMP_PASSWORD2")
        else
            # Si los archivos no existen, significa que se canceló
            if [[ "$has_password" == "true" ]]; then
                show_ok "Keeping current root password."
                return 0
            else
                continue
            fi
        fi
        
        # Limpiar archivos temporales
        rm -f "$TEMP_PASSWORD1" "$TEMP_PASSWORD2" "$TEMP_SCREEN_SCRIPT"
        
        # Validar contraseña
        validation_result=$(validate_password "$password1")
        if [[ $? -ne 0 ]]; then
            validation_message="Error: $validation_result

"
            continue
        fi
        
        # Verificar que las contraseñas coincidan
        if [[ "$password1" != "$password2" ]]; then
            validation_message="Error: Passwords do not match.

"
            continue
        fi
        
        break
    done
    
    # Cambiar la contraseña
    echo "root:$password1" | chpasswd
    if [[ $? -eq 0 ]]; then
        show_ok "Root password successfully updated."
        return 0
    else
        show_error "Failed to update root password."
        return 1
    fi
}

setup_root_password() {
    echo -e "${BOLD}## Setting up root password...${RESET}"
    
    start_spinner "Checking current root password..."
    if check_root_password; then
        stop_spinner
        show_warn "Root password is already set."
        
        # Preguntar si desea cambiar la contraseña
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        DIALOG_OUTPUT=$(mktemp /tmp/dialog_output.XXXXXX)
        
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Root Password" \
    --yes-label "Change" \
    --no-label "Keep" \
    --yesno "A root password is already set. Would you like to change it?" 10 60
echo \$? > "$DIALOG_OUTPUT"
EOF
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        screen -q -dmS dialog_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r dialog_session
        
        printf "\033[A\033[K"
        
        RESPONSE=$(<"$DIALOG_OUTPUT")
        rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
        
        if [[ "$RESPONSE" -eq 0 ]]; then
            set_root_password "true"
        else
            show_ok "Keeping current root password."
        fi
    else
        stop_spinner
        show_warn "No root password is set."
        set_root_password "false"
    fi
    
    echo
}