#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

cleanup() {
    stop_spinner
    echo
    show_error "Disk selection cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

get_disk_info() {
    local disk=$1
    local info=""
    local states=()
    local size
    
    # Obtener tamaño
    size=$(lsblk -b -n -o SIZE "$disk" | head -n1)
    if [[ $size -lt 1099511627776 ]]; then  # < 1TB
        size=$(echo "scale=1; $size/1073741824" | bc)
        size="${size}GiB"
    else
        size=$(echo "scale=1; $size/1099511627776" | bc)
        size="${size}TiB"
    fi
    
    info="$size"
    
    # Verificar si está montado
    if lsblk -n -o MOUNTPOINT "$disk" | grep -q "[[:print:]]"; then
        states+=("mounted")
    fi
    
    # Verificar si es miembro de RAID
    if [[ -f /proc/mdstat ]] && grep -q "$(basename "$disk")" /proc/mdstat; then
        states+=("raid member")
    fi
    
    # Verificar si es miembro de ZFS
    if command -v zpool >/dev/null 2>&1; then
        if zpool status 2>/dev/null | grep -q "$(basename "$disk")"; then
            states+=("zpool member")
        fi
    fi
    
    # Verificar si es parte de un LVM
    if pvs --noheadings 2>/dev/null | grep -q "$(basename "$disk")"; then
        states+=("lvm member")
    fi
    
    # Verificar si está particionado
    if lsblk -n -o TYPE "$disk" | grep -q "part"; then
        states+=("partitioned")
    fi
    
    # Agregar los estados si existen
    if [ ${#states[@]} -gt 0 ]; then
        info+=" ($(IFS=', '; echo "${states[*]}"))"
    fi
    
    echo "$info"
}

get_os_disks() {
    local os_disks=()
    local root_mount
    root_mount=$(findmnt -n -o SOURCE /)
    
    # Caso LVM
    if [[ $root_mount == "/dev/mapper/"* ]]; then
        local vg_name
        vg_name=$(lvs --noheadings -o vg_name "$root_mount" 2>/dev/null | tr -d ' ')
        if [[ -n "$vg_name" ]]; then
            while read -r pv; do
                local disk
                disk=$(echo "$pv" | sed 's/[0-9]*$//')
                os_disks+=("$disk")
            done < <(pvs --noheadings -o pv_name 2>/dev/null | tr -d ' ')
        fi
    fi
    
    # Caso RAID
    if [[ -f /proc/mdstat ]]; then
        while read -r line; do
            if echo "$line" | grep -q "^md.*active"; then
                local md_name
                md_name=$(echo "$line" | awk '{print $1}')
                if mountpoint -q / && [[ $(findmnt -n -o SOURCE /) == *"$md_name"* ]]; then
                    while read -r disk; do
                        os_disks+=("/dev/$disk")
                    done < <(awk '/^md/ {
                        for (i=5; i<=NF; i++) {
                            if ($i ~ /^sd|^nvme|^mmc/) {
                                sub(/\[[0-9]+\]/, "", $i)
                                print $i
                            }
                        }
                    }' /proc/mdstat)
                fi
            fi
        done < /proc/mdstat
    fi
    
    # Caso partición normal
    if [[ $root_mount == "/dev/"* ]]; then
        local disk
        disk=$(echo "$root_mount" | sed 's/[0-9]*$//')
        os_disks+=("$disk")
    fi
    
    # Disco que contiene /boot
    local boot_mount
    boot_mount=$(findmnt -n -o SOURCE /boot 2>/dev/null)
    if [[ -n "$boot_mount" ]]; then
        local boot_disk
        boot_disk=$(echo "$boot_mount" | sed 's/[0-9]*$//')
        os_disks+=("$boot_disk")
    fi
    
    # Eliminar duplicados y retornar
    printf '%s
' "${os_disks[@]}" | sort -u
}

# Variable global
CEPH_DISKS=""

select_ceph_disks() {
    echo -e "${BOLD}## Selecting disks for Ceph cluster...${RESET}"

    local os_disks
    mapfile -t os_disks < <(get_os_disks)
    
    # Obtener discos disponibles (excluyendo los del OS)
    local available_disks=()
    while read -r disk; do
        local is_os_disk=0
        for os_disk in "${os_disks[@]}"; do
            if [[ "$disk" == "$os_disk" ]]; then
                is_os_disk=1
                break
            fi
        done
        if [[ $is_os_disk -eq 0 ]]; then
            available_disks+=("$disk")
        fi
    done < <(lsblk -d -n -o NAME,TYPE | awk '$2 == "disk" {print "/dev/"$1}')
    
    # Verificar si hay discos disponibles
    if [ ${#available_disks[@]} -eq 0 ]; then
        show_error "No available disk drives found for Ceph cluster."
        crit_error
    fi

    # Crear lista de opciones para dialog
    local dialog_options=()
    local disk_count=0
    for disk in "${available_disks[@]}"; do
        local info
        info=$(get_disk_info "$disk")
        dialog_options+=("$disk" "$info" "off")
        ((disk_count++))
    done

    # Crear archivos temporales
    TEMP_SCREEN_SCRIPT=$(mktemp /tmp/screen_script.XXXXXX)
    DIALOG_OUTPUT=$(mktemp /tmp/dialog_output.XXXXXX)

    # Crear script para dialog
    cat << EOF > "$TEMP_SCREEN_SCRIPT"
#!/usr/bin/env bash
dialog --title "Ceph Disk Selection" \
    --ok-label "Select" \
    --cancel-label "Cancel" \
    --checklist "Select disks to use for Ceph cluster (Space to select, Enter to confirm):\nOS disks have been automatically excluded from this list." \
    20 70 $disk_count \
EOF

    # Agregar cada opción de disco al script
    for ((i=0; i<${#dialog_options[@]}; i+=3)); do
        echo -n "    \"${dialog_options[i]}\" \"${dialog_options[i+1]}\" ${dialog_options[i+2]} \" >> "$TEMP_SCREEN_SCRIPT"
        echo >> "$TEMP_SCREEN_SCRIPT"
    done

    # Agregar redirección de salida
    echo "    2>\"$DIALOG_OUTPUT\"" >> "$TEMP_SCREEN_SCRIPT"
    
    chmod +x "$TEMP_SCREEN_SCRIPT"
    
    # Ejecutar dialog en screen
    screen -q -dmS disk_session bash "$TEMP_SCREEN_SCRIPT"
    screen -q -r disk_session
    DIALOG_EXIT_CODE=$?
    
    printf "[1A[K"

    # Si el usuario cancela
    if [ $DIALOG_EXIT_CODE -eq 1 ]; then
        rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
        show_error "Disk selection cancelled."
        return 1
    fi
    
    # Leer discos seleccionados
    local selected_disks
    selected_disks=$(<"$DIALOG_OUTPUT")
    rm -f "$DIALOG_OUTPUT" "$TEMP_SCREEN_SCRIPT"
    
    # Validar que al menos se seleccionó un disco
    if [[ -z "$selected_disks" ]]; then
        show_error "At least one disk must be selected for Ceph cluster."
        return 1
    fi

    # Mostrar discos seleccionados
    show_ok "Selected disks for Ceph cluster: $selected_disks"
    # Guardar los discos seleccionados en la variable global
    CEPH_DISKS=($selected_disks)

    echo
    return 0
}
