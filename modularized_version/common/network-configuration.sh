#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"


cleanup() {
    stop_spinner
    echo
    show_error "Network configuration cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Clean ANSI escape sequences from string
clean_ansi() {
    echo "$1" | sed 's/\[[0-9;]*[JKmsu]//g'
}

# Valida si una cadena es una dirección IP válida
is_ip_valid() {
    local ip=$1
    
    # Verificar formato básico
    if [[ ! "$ip" =~ ^([0-9]+\.){3}[0-9]+$ ]]; then
        return 1
    fi
    
    # Dividir la IP en octetos
    local IFS='.'
    read -ra octets <<< "$ip"
    
    # Debe tener exactamente 4 octetos
    if [ ${#octets[@]} -ne 4 ]; then
        return 1
    fi
    
    # Validar cada octeto
    for octet in "${octets[@]}"; do
        # Verificar que sea un número
        if ! [[ "$octet" =~ ^[0-9]+$ ]]; then
            return 1
        fi
        
        # Remover ceros a la izquierda y verificar el rango (0-255)
        octet=$((10#$octet))
        if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
            return 1
        fi
    done
    
    return 0
}

# Formatea una IP válida para asegurar el formato correcto
format_ip() {
    local ip=$1
    
    # Si la IP no es válida, retornar vacío
    if ! is_ip_valid "$ip"; then
        return 1
    fi
    
    # Formatear cada octeto (eliminar ceros a la izquierda)
    local IFS='.'
    read -ra octets <<< "$ip"
    local formatted_octets=()
    
    for octet in "${octets[@]}"; do
        formatted_octets+=("$((10#$octet))")
    done
    
    # Unir los octetos con puntos
    printf '%d.%d.%d.%d' "${formatted_octets[@]}"
}

# Valida si una cadena es una dirección IP en formato CIDR
is_cidr_valid() {
    local ip_cidr=$1
    
    # Limpiar secuencias ANSI
    ip_cidr=$(clean_ansi "$ip_cidr")
    
    # Separar IP y máscara
    if [[ ! "$ip_cidr" =~ ^([0-9]+\.){3}[0-9]+/[0-9]+$ ]]; then
        return 1
    fi
    
    local ip_addr
    local cidr
    ip_addr=${ip_cidr%/*}
    cidr=${ip_cidr#*/}
    
    # Validar la IP
    if ! is_ip_valid "$ip_addr"; then
        return 1
    fi
    
    # Validar máscara CIDR (debe estar entre 1 y 32)
    if ! [[ "$cidr" =~ ^[0-9]+$ ]] || [ "$cidr" -lt 1 ] || [ "$cidr" -gt 32 ]; then
        return 1
    fi
    
    return 0
}

# Formatea una dirección IP con CIDR
format_cidr() {
    local ip_cidr=$1
    
    # Si el CIDR no es válido, retornar vacío
    if ! is_cidr_valid "$ip_cidr"; then
        return 1
    fi
    
    local ip_addr
    local cidr
    ip_addr=${ip_cidr%/*}
    cidr=${ip_cidr#*/}
    
    # Formatear la IP y mantener el CIDR
    local formatted_ip
    formatted_ip=$(format_ip "$ip_addr")
    
    printf '%s/%d' "$formatted_ip" "$((10#$cidr))"
}

# Get valid network interfaces
get_valid_interfaces() {
    local interfaces=()
    while IFS= read -r line; do
        iface=$(echo "$line" | awk '{print $2}' | sed 's/:$//')
        # Filter out loopback and virtual interfaces
        if [[ ! "$iface" =~ ^(lo|docker|veth|br-|virbr|dummy|bond|team|tun|tap) ]]; then
            interfaces+=("$iface")
        fi
    done < <(ip link show | grep '^[0-9]')
    
    if [ ${#interfaces[@]} -eq 0 ]; then
        show_error "No valid network interfaces found."
        return 1
    fi
    
    printf '%s
' "${interfaces[@]}"
}


get_interface_info() {
    local iface=$1
    
    # Obtener la MAC address
    local mac_address
    mac_address=$(ip link show dev "$iface" | awk '/link\/ether/ {print $2}')
    
    info="Interface: $iface
MAC Address: $mac_address"
    
    echo "$info"
}


get_current_ip() {
    local iface=$1
    local state
    local ip_with_cidr
    
    # Verificar si la interfaz existe
    if ! ip link show "$iface" &>/dev/null; then
        echo "IP Offline (Interface not found)"
        return
    fi
    
    # Verificar el estado de la interfaz
    state=$(ip link show dev "$iface" | grep -o "state.*" | cut -d' ' -f2)
    if [[ "$state" != "UP" ]]; then
        echo "IP Offline (Interface down)"
        return
    fi
    
    # Intentar obtener la IPv4
    ip_with_cidr=$(ip -o -4 addr show dev "$iface" 2>/dev/null | awk '{print $4}' | head -n1)
    
    if [[ -z "$ip_with_cidr" ]]; then
        # Verificar si tiene IPv6 pero no IPv4
        if ip -o -6 addr show dev "$iface" 2>/dev/null | grep -q "inet6"; then
            echo "IP Offline (IPv6 only)"
        else
            echo "IP Offline (No IP assigned)"
        fi
    else
        echo "$ip_with_cidr"
    fi
}

get_current_gateway() {
    local interface=$1
    local gateway
    gateway=$(ip route | grep "^default.*$interface" | head -n1 | awk '{print $3}')
    echo "$gateway"
}

select_interface() {
    local interfaces
    # Leer las interfaces en un array
    mapfile -t interfaces < <(get_valid_interfaces)
    local num_interfaces=0
    
    # Crear un array para las opciones de dialog, solo con interfaces activas
    local dialog_options=()
    for iface in "${interfaces[@]}"; do
        local current_ip
        current_ip=$(get_current_ip "$iface")
        
        # Solo agregar interfaces que no estén offline
        if [[ ! "$current_ip" =~ ^"IP Offline" ]]; then
            dialog_options+=("$iface" "IP: $current_ip")
            ((num_interfaces++))
        fi
    done
    
    if [ "$num_interfaces" -eq 0 ]; then
        show_error "No active network interfaces found."
        crit_error
    fi
    
    TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
    DIALOG_OUTPUT=$(mktemp /tmp/dialog_output.XXXXXX)
    
    # Modificar el script para incluir botón de cancelar
    cat << 'EOF' > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Network Interface Selection" \
    --cancel-label "Cancel" \
    --menu "Select the network interface for Ceph:" \
    15 60 $1 \
EOF
    
    # Añadir las opciones al script de manera segura
    printf '%q ' "${dialog_options[@]}" >> "$TEMP_SCREEN_SCRIPT"
    echo "2>\"$DIALOG_OUTPUT\"" >> "$TEMP_SCREEN_SCRIPT"
    
    chmod +x "$TEMP_SCREEN_SCRIPT"
    
    # Ejecutar dialog
    screen -q -dmS interface_session bash "$TEMP_SCREEN_SCRIPT" "$num_interfaces"
    screen -q -r interface_session
    DIALOG_EXIT_CODE=$?
    
    # Si el usuario cancela
    if [ $DIALOG_EXIT_CODE -eq 1 ]; then
        rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
        show_error "Interface selection cancelled by user"
        exit 1
    fi
    
    selected_interface=$(<"$DIALOG_OUTPUT")
    rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
    
    # Limpiar secuencias ANSI
    selected_interface=$(clean_ansi "$selected_interface")
    echo "$selected_interface"
}

cleanup_ip_config() {
    local temp_ip="$1"
    local temp_script="$2"
    rm -f "$temp_ip" "$temp_script" 2>/dev/null
    stop_spinner
    echo
    show_error "IP configuration cancelled by user"
    exit 1
}

configure_ip() {
    local interface=$1
    local current_ip
    current_ip=$(get_current_ip "$interface")
    local validation_message=""
    local new_ip=""
    
    trap 'cleanup_ip_config "$TEMP_IP" "$TEMP_SCREEN_SCRIPT"' SIGINT SIGTERM
    
    while true; do
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_IP=$(mktemp /tmp/ip.XXXXXX)
        
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "IP Configuration" \
    --ok-label "OK" \
    --cancel-label "Cancel" \
    --inputbox "${validation_message}${interface_info}

Enter IP address in CIDR format (e.g., 192.168.1.10/24):" \
    16 70 "${current_ip}" 2>"$TEMP_IP"
[ \$? -eq 1 ] && exit 1
EOF
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        # Ejecutar dialog
        screen -q -dmS ip_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r ip_session
        DIALOG_EXIT_CODE=$?
        
        if [ $DIALOG_EXIT_CODE -eq 1 ]; then
            cleanup_ip_config "$TEMP_IP" "$TEMP_SCREEN_SCRIPT"
        fi
        
        local new_ip
        new_ip=$(<"$TEMP_IP")
        rm -f "$TEMP_IP" "$TEMP_SCREEN_SCRIPT"
        
        # Limpiar el valor obtenido
        new_ip=$(echo "$new_ip" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')
        
        # Si está vacío y hay una IP actual, usar esa
        if [[ -z "$new_ip" && -n "$current_ip" ]]; then
            new_ip="$current_ip"
        fi
        
        # Validar y formatear IP con CIDR
        if is_cidr_valid "$new_ip"; then
            new_ip=$(format_cidr "$new_ip")
            break
        else
            validation_message="Invalid IP format. Please use CIDR notation (e.g., 192.168.1.10/24)

"
            continue
        fi
    done
    
    printf '%s' "$new_ip"
}

configure_gateway() {
    local interface=$1
    local current_gateway
    current_gateway=$(get_current_gateway "$interface")
    local validation_message=""
    local new_gateway=""
    
    while true; do
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_GATEWAY=$(mktemp /tmp/gateway.XXXXXX)
        
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Gateway Configuration" \
    --no-cancel \
    --inputbox "${validation_message}Enter Gateway IP address for interface '$interface' (e.g., 192.168.1.1)
Current Gateway: ${current_gateway:-None}" \
    12 70 "${current_gateway:-}" 2>"$TEMP_GATEWAY"
EOF
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        # Ejecutar dialog
        screen -q -dmS gateway_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r gateway_session
        
        # Leer gateway ingresado
        new_gateway=$(<"$TEMP_GATEWAY")
        rm -f "$TEMP_GATEWAY" "$TEMP_SCREEN_SCRIPT"

        # Limpiar el valor obtenido
        new_gateway=$(echo "$new_gateway" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')
        
        # Si está vacío y hay un gateway actual, usar ese
        if [[ -z "$new_gateway" && -n "$current_gateway" ]]; then
            new_gateway="$current_gateway"
        fi
        
        # Validar y formatear IP
        if is_ip_valid "$new_gateway"; then
            new_gateway=$(format_ip "$new_gateway")
            break
        else
            validation_message="Invalid IP format. Please enter a valid IPv4 address.

"
            continue
        fi
    done
    
    printf '%s' "$new_gateway"
}

get_current_dns() {
    local dns_number=$1
    local dns=""
    local counter=1

    # Intentar obtener DNS de systemd-resolved primero
    if command -v resolvectl >/dev/null 2>&1; then
        while IFS= read -r line; do
            if [[ "$line" =~ "DNS Servers:" ]]; then
                # Extraer todos los DNS de la línea
                dns_servers=(${line#*: })
                # Retornar el DNS según el número solicitado
                if [ $counter -eq "$dns_number" ] && [ -n "${dns_servers[$dns_number-1]}" ]; then
                    dns="${dns_servers[$dns_number-1]}"
                    break
                fi
            fi
            ((counter++))
        done < <(resolvectl status 2>/dev/null)
    fi

    # Si no hay DNS de systemd-resolved, intentar desde resolv.conf
    if [[ -z "$dns" ]]; then
        counter=1
        while IFS= read -r line; do
            if [[ "$line" =~ ^nameserver ]]; then
                if [ $counter -eq "$dns_number" ]; then
                    dns=$(echo "$line" | awk '{print $2}')
                    break
                fi
                ((counter++))
            fi
        done < /etc/resolv.conf
    fi

    # Si aún no hay DNS, intentar obtenerlo de la configuración de la interfaz
    if [[ -z "$dns" ]]; then
        dns=$(nmcli dev show 2>/dev/null | grep "IP4.DNS\[$(($dns_number-1))\]:" | awk '{print $2}')
    fi

    echo "$dns"
}


configure_dns() {
    local dns_number=$1
    local current_dns
    current_dns=$(get_current_dns "$dns_number")
    local validation_message=""
    local new_dns=""
    
    while true; do
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_DNS=$(mktemp /tmp/dns.XXXXXX)
        
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "DNS Configuration" \
    --no-cancel \
    --inputbox "${validation_message}Enter DNS Server $dns_number IP address (e.g., 8.8.8.8)
Current DNS: ${current_dns:-None}
(Press Enter to use current DNS)" \
    12 70 "${current_dns:-}" 2>"$TEMP_DNS"
EOF
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        # Ejecutar dialog
        screen -q -dmS dns_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r dns_session
        
        # Leer DNS ingresado
        new_dns=$(<"$TEMP_DNS")
        rm -f "$TEMP_DNS" "$TEMP_SCREEN_SCRIPT"

        # Limpiar el valor obtenido de forma más estricta
        new_dns=$(echo "$new_dns" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')
        
        # Si está vacío y hay un DNS actual, usar ese
        if [[ -z "$new_dns" && -n "$current_dns" ]]; then
            new_dns="$current_dns"
            break
        elif [[ -z "$new_dns" && -z "$current_dns" ]]; then
            # Si no hay DNS actual, usar uno por defecto (por ejemplo, Google DNS)
            if [[ "$dns_number" == "1" ]]; then
                new_dns="8.8.8.8"
            else
                new_dns="8.8.4.4"
            fi
            break
        fi
        
        # Validar y formatear IP
        if is_ip_valid "$new_dns"; then
            new_dns=$(format_ip "$new_dns")
            break
        else
            validation_message="Invalid IP format. Please enter a valid IPv4 address.

"
            continue
        fi
    done
    
    printf '%s' "$new_dns"
}

create_netplan_config() {
    local interface=$1
    local ip=$2
    local gateway=$3
    local dns1=$4
    local dns2=$5

    start_spinner "Creating netplan configuration..."

    # Limpiar variables y crear configuración
    interface=$(clean_ansi "$interface" | tr -d '[:space:]')
    ip=$(clean_ansi "$ip" | tr -d '[:space:]')
    gateway=$(clean_ansi "$gateway" | tr -d '[:space:]')
    dns1=$(clean_ansi "$dns1" | tr -d '[:space:]')
    dns2=$(clean_ansi "$dns2" | tr -d '[:space:]')
    
    # Crear directorio si no existe
    mkdir -p /etc/netplan
    
    # Crear archivo de configuración
    cat > "/etc/netplan/01-netcfg.yaml" << EOF
# This file is generated by the Ceph installation script
network:
  version: 2
  renderer: networkd
  ethernets:
    ${interface}:
      addresses:
        - ${ip}
      gateway4: ${gateway}
      nameservers:
        addresses:
          - ${dns1}
          - ${dns2}
EOF

    stop_spinner
    
    # Verificar que el archivo se creó correctamente
    if [[ -f "/etc/netplan/01-netcfg.yaml" ]]; then
        local content
        content=$(<"/etc/netplan/01-netcfg.yaml")
        echo "$content"
        return 0
    else
        return 1
    fi
}

update_resolv_conf() {
    local dns1="$1"
    local dns2="$2"

    echo -e "${BOLD}## Updating DNS configuration...${RESET}"
    
    if [ -f "/etc/resolv.conf" ]; then
        cp "/etc/resolv.conf" "/etc/resolv.conf.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    show_ok "Backup created."

    # Crear el nuevo archivo
    cat > "/etc/resolv.conf" << EOF
# Generated by Ceph installation script
nameserver $dns1
EOF

    # Agregar el DNS secundario solo si es diferente del primario
    if [ -n "$dns2" ] && [ "$dns2" != "$dns1" ]; then
        echo "nameserver $dns2" >> "/etc/resolv.conf"
    fi
    
}

setup_network() {
    echo
    echo -e "${BOLD}## Setting up network configuration...${RESET}"
    
    # Obtener y validar la interfaz
    local interface
    interface=$(select_interface)
    interface=$(echo "$interface" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')
    
    printf "[1A[K"

    if [[ -z "$interface" ]]; then
        show_error "No interface selected."
        crit_error
    fi
    show_ok "Selected interface: '${interface}'"
    
    # Configurar IP
    local ip_address
    ip_address=$(configure_ip "$interface")
    ip_address=$(echo "$ip_address" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')

    printf "[1A[K"

    if [[ -z "$ip_address" ]]; then
        show_error "No IP address configured."
        crit_error
    fi
    show_ok "IP address: '${ip_address}'"
    
    # Configurar gateway
    local gateway
    gateway=$(configure_gateway "$interface")
    gateway=$(echo "$gateway" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')

    printf "[1A[K"

    if [[ -z "$gateway" ]]; then
        show_error "No gateway configured."
        crit_error
    fi
    show_ok "Gateway: '${gateway}'"
    
    # Configurar DNS primario
    local dns1
    dns1=$(configure_dns "1")
    dns1=$(echo "$dns1" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')
    
    printf "[1A[K"

    if [[ -z "$dns1" ]]; then
        show_error "No primary DNS configured."
        crit_error
    fi
    show_ok "Primary DNS: '${dns1}'"
    
    # Configurar DNS secundario
    local dns2
    dns2=$(configure_dns "2")
    dns2=$(echo "$dns2" | tr -d '[:space:]' | sed 's/\[[0-9;]*[a-zA-Z]//g')

    printf "[1A[K"

    if [[ -z "$dns2" ]]; then
        show_warn "No secondary DNS configured, using primary DNS as secondary"
        dns2="$dns1"
    fi
    show_ok "Secondary DNS: '${dns2}'"
    
     # Generar y aplicar la configuración de netplan
    local config_content
    config_content=$(create_netplan_config "$interface" "$ip_address" "$gateway" "$dns1" "$dns2")
    
    start_spinner "Checking network configuration..."
    if netplan generate >/dev/null 2>&1; then
        stop_spinner
        show_ok "Valid network configuration file generated."

        start_spinner "Applying new network configuration"
        netplan apply >/dev/null 2>&1
        stop_spinner
        show_ok "Network configuration applied successfully."

        # Actualizar resolv.conf con los nuevos DNS
        start_spinner "Updating nameservers..."
        update_resolv_conf "$dns1" "$dns2"
        stop_spinner
        show_ok "DNS configuration updated successfully."

        echo -e "${BOLD}Restarting services...${RESET}"
        
        local services=("NetworkManager" "systemd-resolved")

        for service in "${services[@]}"; do
            if systemctl is-active --quiet "$service"; then
                start_spinner "Restarting $service service..."
                if systemctl restart "$service" >/dev/null 2>&1; then
                    stop_spinner
                    show_ok "Service ${ITALIC}'$service'${END_ITALIC} restarted successfully."

                else
                    stop_spinner
                    show_warn "Failed to restart ${ITALIC}'$service'${END_ITALIC} service."
                fi
            fi
        done

        show_ok "${BOLD}Network configured${RESET}"
        

        return 0
    else
        stop_spinner
        show_error "Invalid netplan configuration generated."
        crit_error
        return 1
    fi
}
