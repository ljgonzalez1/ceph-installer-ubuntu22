#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"

set_hostname() {
    echo -e "${BOLD}Configuring hostname...${RESET}"

    local current_hostname
    current_hostname=$(hostname)

    local new_hostname=""
    local validation_message=""
    local is_valid=0

    while [[ $is_valid -eq 0 ]]; do
        # Crear archivos temporales
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_NEW_HOSTNAME=$(mktemp /tmp/new_hostname.XXXXXX)

        # Crear el script para usar con screen
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Hostname Configuration" \
    --no-cancel \
    --ok-label "OK" \
    --inputbox "${validation_message}Enter the hostname for this node:\n(Leave empty to keep current):" 15 70 "$current_hostname" 2>"$TEMP_NEW_HOSTNAME"
EOF
        chmod +x "$TEMP_SCREEN_SCRIPT"

        # Ejecutar el diálogo en screen
        screen -q -dmS hostname_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r hostname_session

        # Mover el cursor hacia arriba y borrar la línea
        printf "\033[A\r\033[K"

        # Leer el hostname ingresado
        new_hostname=$(<"$TEMP_NEW_HOSTNAME")
        rm -f "$TEMP_NEW_HOSTNAME" "$TEMP_SCREEN_SCRIPT"

        # Si el input está vacío, conservar el hostname actual
        if [[ -z "$new_hostname" ]]; then
            show_ok "Keeping current hostname: $current_hostname"
            return 0
        fi

        # Validar el nuevo hostname
        if [[ "$new_hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9\._-]{1,253}[a-zA-Z0-9]$ && ${#new_hostname} -ge 3 && ${#new_hostname} -le 255 ]]; then
            is_valid=1
        else
            validation_message="Invalid hostname:\n- 3-255 characters.\n- Only letters, numbers, dots (.), hyphens (-) and underscores (_).\n- Must start and end with letter or number.\n- Middle section can be 1-253 characters.\n\n"
        fi
    done

    # Resto del código permanece igual...
    if [[ "$new_hostname" == "$current_hostname" ]]; then
        show_ok "Hostname unchanged: $current_hostname"
        return 0
    fi

    echo "$new_hostname" > /etc/hostname
    show_ok "/etc/hostname updated."

    local tmpfile
    tmpfile=$(mktemp)

    while IFS= read -r line; do
        if echo "$line" | grep -q "\b$current_hostname\b"; then
            updated_line=$(echo "$line" | sed "s/\b$current_hostname\b/$new_hostname/g")
            echo "$updated_line" >> "$tmpfile"
        else
            echo "$line" >> "$tmpfile"
        fi
    done < /etc/hosts

    sed -i "/^127\.0\.1\.1\b/d" "$tmpfile"
    echo "127.0.1.1 $new_hostname.local $new_hostname" >> "$tmpfile"

    mv "$tmpfile" /etc/hosts
    show_ok "/etc/hosts updated with new hostname."

    hostnamectl set-hostname "$new_hostname"

    local services=("systemd-hostnamed" "networking")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            if ! systemctl restart "$service"; then
                show_warn "Failed to restart $service: $(systemctl status "$service" | grep -o 'Unit .* not found')"
            else
                show_ok "Restarted $service successfully."
            fi
        else
            show_warn "$service is not active or available."
        fi
    done

    show_ok "Hostname changed to '$new_hostname'."
}