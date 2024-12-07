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
    echo "$1" | sed 's/\x1B\[[0-9;]*[JKmsu]//g'
}

# Función para validar una dirección IP (sin CIDR)
validate_ip() {
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

# Función para validar una dirección IP en formato CIDR
validate_cidr() {
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
    
    # Validar máscara CIDR (debe estar entre 1 y 32)
    if ! [[ "$cidr" =~ ^[0-9]+$ ]] || [ "$cidr" -lt 1 ] || [ "$cidr" -gt 32 ]; then
        return 1
    fi
    
    # Validar la IP
    validate_ip "$ip_addr"
}

# Función para obtener interfaces de red válidas
get_valid_interfaces() {
    local interfaces
    # Usamos grep -w para asegurar coincidencia de palabra completa
    # y excluimos cualquier línea que contenga IP como palabra
    interfaces=$(ip link show | 
                egrep "^[0-9]" | 
                cut -d" " -f2 | 
                cut -d":" -f1 | 
                grep -v -w "IP" |
                egrep -v "lo|docker|veth|br-|docker")
    
    # Verificar si se encontraron interfaces
    if [[ -z "$interfaces" ]]; then
        show_error "No valid network interfaces found."
        crit_error
    fi
    
    echo "$interfaces"
}

get_interface_info() {
    local iface=$1
    local info=""
    
    # Obtener el estado del link
    local link_state
    link_state=$(ip link show dev "$iface" | grep -o "state.*" | cut -d' ' -f2)
    
    # Obtener la MAC address
    local mac_address
    mac_address=$(ip link show dev "$iface" | awk '/link\/ether/ {print $2}')
    
    # Obtener la velocidad y el modo duplex si está disponible
    local speed=""
    local duplex=""
    if [[ -d "/sys/class/net/$iface" ]]; then
        if [[ -f "/sys/class/net/$iface/speed" ]]; then
            speed=$(cat "/sys/class/net/$iface/speed" 2>/dev/null)
            duplex=$(cat "/sys/class/net/$iface/duplex" 2>/dev/null)
        fi
    fi
    
    info="Interface: $iface
State: $link_state
MAC Address: $mac_address"
    
    if [[ -n "$speed" ]]; then
        info+="
Speed: ${speed}Mbps
Duplex: $duplex"
    fi
    
    echo "$info"
}

# Función para obtener la IP actual de una interfaz
get_current_ip() {
    local iface=$1
    local ip_with_cidr
    ip_with_cidr=$(ip -o -4 addr show dev "$iface" | awk '{print $4}' | head -n1)
    
    if [[ -z "$ip_with_cidr" ]]; then
        # Si no hay IP configurada, retornar vacío
        echo ""
    else
        echo "$ip_with_cidr"
    fi
}

# Función para obtener el gateway actual
get_current_gateway() {
    ip route | awk '/default/ { print $3 }'
}

select_interface() {
    local interfaces=($1)
    local num_interfaces=${#interfaces[@]}
    
    if [ "$num_interfaces" -eq 0 ]; then
        show_error "No valid network interfaces found."
        crit_error
    fi
    
    # Crear lista de opciones para dialog
    local options=""
    for iface in "${interfaces[@]}"; do
        local current_ip
        current_ip=$(get_current_ip "$iface")
        options+="$iface"$'\t'"Current"$'\n'
    done
    
    TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
    DIALOG_OUTPUT=$(mktemp /tmp/dialog_output.XXXXXX)
    
    # Crear script para dialog
    cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Network Interface Selection" \
    --no-cancel \
    --menu "Select the network interface for Ceph:" \
    15 60 $num_interfaces \
    $(echo -e "$options") 2>"$DIALOG_OUTPUT"
EOF
    
    chmod +x "$TEMP_SCREEN_SCRIPT"
    
    # Ejecutar dialog
    screen -q -dmS interface_session bash "$TEMP_SCREEN_SCRIPT"
    screen -q -r interface_session
    
    selected_interface=$(<"$DIALOG_OUTPUT")
    rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
    
    # Limpiar secuencias ANSI
    selected_interface=$(clean_ansi "$selected_interface")
    echo "$selected_interface"
}

configure_ip() {
    local interface=$1
    local current_ip
    current_ip=$(get_current_ip "$interface")
    local validation_message=""
    local interface_info
    interface_info=$(get_interface_info "$interface")
    
    while true; do
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_IP=$(mktemp /tmp/ip.XXXXXX)
        
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "IP Configuration" \
    --no-cancel \
    --inputbox "${validation_message}${interface_info}

Enter IP address in CIDR format (e.g., 192.168.1.10/24):" \
    16 70 "${current_ip}" 2>"$TEMP_IP"
EOF
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        # Ejecutar dialog
        screen -q -dmS ip_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r ip_session
        
        # Leer IP ingresada
        local new_ip
        new_ip=$(<"$TEMP_IP")
        rm -f "$TEMP_IP" "$TEMP_SCREEN_SCRIPT"

        # Limpiar secuencias ANSI
        new_ip=$(clean_ansi "$new_ip")
        
        # Si el usuario no ingresó nada y hay una IP actual, usarla
        if [[ -z "$new_ip" && -n "$current_ip" ]]; then
            new_ip="$current_ip"
        fi
        
        # Validar formato CIDR
        if validate_cidr "$new_ip"; then
            echo "$new_ip"
            break
        else
            validation_message="Invalid IP format. Please use CIDR notation (e.g., 192.168.1.10/24)

"
            continue
        fi
    done
}

configure_gateway() {
    local current_gateway
    current_gateway=$(get_current_gateway)
    local validation_message=""
    
    while true; do
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_GATEWAY=$(mktemp /tmp/gateway.XXXXXX)
        
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Gateway Configuration" \
    --no-cancel \
    --inputbox "${validation_message}Enter Gateway IP address (e.g., 192.168.1.1)
Current Gateway: ${current_gateway:-None}" \
    12 60 "${current_gateway:-}" 2>"$TEMP_GATEWAY"
EOF
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        # Ejecutar dialog
        screen -q -dmS gateway_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r gateway_session
        
        # Leer gateway ingresado
        local new_gateway
        new_gateway=$(<"$TEMP_GATEWAY")
        rm -f "$TEMP_GATEWAY" "$TEMP_SCREEN_SCRIPT"

        # Limpiar secuencias ANSI
        new_gateway=$(clean_ansi "$new_gateway")
        
        # Validar formato IP
        if validate_ip "$new_gateway"; then
            echo "$new_gateway"
            break
        else
            validation_message="Invalid IP format. Please enter a valid IPv4 address.

"
            continue
        fi
    done
}

configure_dns() {
    local current_dns
    current_dns=$(grep -m1 "nameserver" /etc/resolv.conf | awk '{print $2}')
    local validation_message=""
    local dns_number=$1
    
    while true; do
        TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
        TEMP_DNS=$(mktemp /tmp/dns.XXXXXX)
        
        cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "DNS Configuration" \
    --no-cancel \
    --inputbox "${validation_message}Enter DNS Server $dns_number IP address (e.g., 8.8.8.8)
Current DNS: ${current_dns:-None}" \
    12 60 "${current_dns:-}" 2>"$TEMP_DNS"
EOF
        
        chmod +x "$TEMP_SCREEN_SCRIPT"
        
        # Ejecutar dialog
        screen -q -dmS dns_session bash "$TEMP_SCREEN_SCRIPT"
        screen -q -r dns_session
        
        # Leer DNS ingresado
        local new_dns
        new_dns=$(<"$TEMP_DNS")
        rm -f "$TEMP_DNS" "$TEMP_SCREEN_SCRIPT"

        # Limpiar secuencias ANSI
        new_dns=$(clean_ansi "$new_dns")
        
        # Validar formato IP
        if validate_ip "$new_dns"; then
            echo "$new_dns"
            break
        else
            validation_message="Invalid IP format. Please enter a valid IPv4 address.

"
            continue
        fi
    done
}

create_netplan_config() {
    local interface=$1
    local ip=$2
    local gateway=$3
    local dns1=$4
    local dns2=$5

    # Limpiar todas las variables de secuencias ANSI
    interface=$(clean_ansi "$interface")
    ip=$(clean_ansi "$ip")
    gateway=$(clean_ansi "$gateway")
    dns1=$(clean_ansi "$dns1")
    dns2=$(clean_ansi "$dns2")
    
    # Crear directorio si no existe
    mkdir -p /etc/netplan
    
    # Crear archivo de configuración con valores limpios
    cat > "/etc/netplan/01-netcfg.yaml" << EOF
# This file is generated by the Ceph installation script
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      addresses:
        - $ip
      gateway4: $gateway
      nameservers:
        addresses:
          - $dns1
          - $dns2
EOF

    # Verificar que el archivo se creó correctamente
    if ! netplan get &>/dev/null; then
        show_error "Invalid netplan configuration generated."
        cat "/etc/netplan/01-netcfg.yaml"
        crit_error
    fi
    
    # Aplicar configuración
    start_spinner "Applying network configuration..."
    if ! netplan try --timeout 10 &>/dev/null; then
        stop_spinner
        show_error "Failed to apply network configuration."
        cat "/etc/netplan/01-netcfg.yaml"
        crit_error
    fi
    
    if ! netplan apply &>/dev/null; then
        stop_spinner
        show_error "Failed to apply network configuration."
        cat "/etc/netplan/01-netcfg.yaml"
        crit_error
    fi
    stop_spinner
    show_ok "Network configuration applied successfully."
}

setup_network() {
    echo -e "${BOLD}## Setting up network configuration...${RESET}"
    
    start_spinner "Detecting network interfaces..."
    local interfaces
    interfaces=$(get_valid_interfaces)
    stop_spinner
    
    # Seleccionar interfaz
    show_ok "Network interfaces detected."
    local selected_interface
    selected_interface=$(select_interface "$interfaces")
    show_ok "Selected interface: ${ITALIC}'$selected_interface'${END_ITALIC}"
    
    # Configurar IP
    local ip_address
    ip_address=$(configure_ip "$selected_interface")
    show_ok "IP address: ${ITALIC}'$ip_address'${END_ITALIC}"
    
    # Configurar Gateway
    local gateway
    gateway=$(configure_gateway)
    show_ok "Gateway: ${ITALIC}'$gateway'${END_ITALIC}"
    
    # Configurar DNS primario
    local dns1
    dns1=$(configure_dns "1")
    show_ok "Primary DNS: ${ITALIC}'$dns1'${END_ITALIC}"
    
    # Configurar DNS secundario
    local dns2
    dns2=$(configure_dns "2")
    show_ok "Secondary DNS configured: ${ITALIC}'$dns2'${END_ITALIC}"
    
    # Crear y aplicar configuración de netplan
    create_netplan_config "$selected_interface" "$new_ip" "$gateway" "$dns1" "$dns2"
    
    echo
}

