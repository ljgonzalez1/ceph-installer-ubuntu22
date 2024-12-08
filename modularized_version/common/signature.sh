#!/usr/bin/env bash

# Función auxiliar para definir las variables ANSI
setup_ansi_variables() {
    # Variables ANSI básicas
    local -n r=$1  # Referencia al hash asociativo que se pasará

    # Reset
    r[RESET]="[0m"

    # Colores estándar para fondo
    r[BLUE_BG]="[44m"
    r[CYAN_BG]="[46m"
    r[RED_BG]="[41m"
    r[BLACK_BG]="[40m"
    r[WHITE_BG]="[47m"
    r[TRANSPARENT_BG]="[49m"
    r[YELLOW_BG]="[43m"

    # Estilos de texto
    r[BOLD]="[1m"
    r[UNDERLINE]="[4m"
    r[ITALIC]="[3m"
    r[END_BOLD]="[22m"
    r[END_UNDERLINE]="[24m"
    r[END_ITALIC]="[23m"

    # Colores estándar para texto
    r[BLUE_FG]="[34m"
    r[CYAN_FG]="[36m"
    r[RED_FG]="[31m"
    r[BLACK_FG]="[30m"
    r[WHITE_FG]="[37m"
    r[TRANSPARENT_FG]="[39m"
    r[YELLOW_FG]="[33m"

    # Verificar soporte de 256 colores
    if tput colors 2>/dev/null | grep -q '^256$'; then
        # TrueColor o 256 colores disponibles
        r[LIGHT_BLUE_BG]="[48;5;81m"       # Celeste estándar
        r[VERY_LIGHT_BLUE_BG]="[48;5;159m" # Celeste pastel
        r[DARK_BLUE_BG]="[48;5;17m"        # Azul oscuro
        r[ORANGE_BG]="[48;5;214m"          # Naranja

        r[LIGHT_BLUE_FG]="[38;5;81m"       # Celeste estándar
        r[VERY_LIGHT_BLUE_FG]="[38;5;159m" # Celeste pastel
        r[DARK_BLUE_FG]="[38;5;17m"        # Azul oscuro
        r[ORANGE_FG]="[38;5;214m"          # Naranja
    else
        # Solo 16 colores disponibles
        r[LIGHT_BLUE_BG]="${r[CYAN_BG]}"          # Usar cyan como degradado
        r[VERY_LIGHT_BLUE_BG]="${r[CYAN_BG]}"     # Usar cyan como degradado
        r[DARK_BLUE_BG]="${r[BLUE_BG]}"           # Usar azul estándar como degradado
        r[ORANGE_BG]="${r[YELLOW_BG]}"            # Usar amarillo como degradado

        r[LIGHT_BLUE_FG]="${r[CYAN_FG]}"          # Usar cyan como degradado
        r[VERY_LIGHT_BLUE_FG]="${r[CYAN_FG]}"     # Usar cyan como degradado
        r[DARK_BLUE_FG]="${r[BLUE_FG]}"           # Usar azul estándar como degradado
        r[ORANGE_FG]="${r[YELLOW_FG]}"            # Usar amarillo como degradado
    fi
}

show_signature_part_1() {
    declare -A colors
    setup_ansi_variables colors

    echo -e "
${colors[TRANSPARENT_BG]}${colors[WHITE_FG]}▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄${colors[RESET]}
${colors[VERY_LIGHT_BLUE_BG]}${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[WHITE_FG]}▀${colors[LIGHT_BLUE_FG]}▄${colors[RESET]}
${colors[LIGHT_BLUE_BG]}${colors[WHITE_FG]}                        ▗▄▄▖▗▄▄▄▖▗▄▄▖ ▗▖ ▗▖                          ${colors[RESET]}
${colors[LIGHT_BLUE_BG]}${colors[WHITE_FG]}${colors[ITALIC]}                       ▐▌   ▐▌   ▐▌ ▐▌▐▌ ▐▌                          ${colors[RESET]}
${colors[LIGHT_BLUE_BG]}${colors[WHITE_FG]}                       ▐▌   ▐▛▀▀▘▐▛▀▘ ▐▛▀▜▌                          ${colors[RESET]}
${colors[LIGHT_BLUE_BG]}${colors[WHITE_FG]}${colors[ITALIC]}                       ▝▚▄▄▖▐▙▄▄▖▐▌   ▐▌ ▐▌                          ${colors[RESET]}
${colors[LIGHT_BLUE_BG]}${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[BLUE_FG]}▄${colors[LIGHT_BLUE_FG]}▄${colors[RESET]}
${colors[BLUE_BG]}${colors[LIGHT_BLUE_FG]}▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄${colors[RESET]}
${colors[BLUE_BG]}${colors[WHITE_FG]}${colors[ITALIC]}             ▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖▗▄▄▄▖ ▗▄▖ ▗▖   ▗▖   ▗▄▄▄▖▗▄▄▖           ${colors[RESET]}
${colors[BLUE_BG]}${colors[WHITE_FG]}               █  ▐▛▚▖▐▌▐▌     █  ▐▌ ▐▌▐▌   ▐▌   ▐▌   ▐▌ ▐▌          ${colors[RESET]}
${colors[BLUE_BG]}${colors[WHITE_FG]}${colors[ITALIC]}               █  ▐▌ ▝▜▌ ▝▀▚▖  █  ▐▛▀▜▌▐▌   ▐▌   ▐▛▀▀▘▐▛▀▚▖          ${colors[RESET]}
${colors[BLUE_BG]}${colors[WHITE_FG]}             ▗▄█▄▖▐▌  ▐▌▗▄▄▞▘  █  ▐▌ ▐▌▐▙▄▄▖▐▙▄▄▖▐▙▄▄▖▐▌ ▐▌          ${colors[RESET]}
${colors[BLUE_BG]}${colors[DARK_BLUE_FG]}${colors[ITALIC]} ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ▄ ${colors[RESET]}"
}

show_signature_part_2() {
    declare -A colors
    setup_ansi_variables colors

    echo -e "${colors[DARK_BLUE_BG]}${colors[BLUE_FG]}${colors[ITALIC]}▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                        ${colors[RED_FG]}⣀⠤⠒⠒⠛⠒⠒⠢⠤⠐⠲⡄                 ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                       ${colors[RED_FG]}⣼⠁ ⢀⣾⣦⡶    ⡼                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                      ${colors[RED_FG]}⢀⣽⠴⠓⠉⠁   ⢠⠄⢰⠁                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                    ${colors[RED_FG]}⣠⠖⠉⠉      ⢠⡏ ⡏                   ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                  ${colors[RED_FG]}⡠⡚⠁        ⢀⠟⢁⡾                    ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                ${colors[RED_FG]}⣠⠞⠁         ⢀⡾⠛⠉                     ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                             ${colors[RED_FG]}⢀⣴⠺⠥⠄         ⣠⠎                        ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}         ⢀⡴⠖⠒⠖⠤⡀          ⣀⡤⠾⠛⠳⣄         ${colors[RED_FG]}⢀⠔⠁                         ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}        ⡔⣡⣿⠿⠛⠿⣦⡌⢦       ⣠⠎⢁${colors[WHITE_FG]}⡤⠒⢢⣄${colors[ORANGE_FG]}⠈⠳⡄  ${colors[RED_FG]}⢀⣤ ⣦⠖⠁                           ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}    ⣾⡀⢀⣼⣵⠟⠁⢀⣀⣀⣈⣿⠘⣆    ⣠⣴⡃ ${colors[WHITE_FG]}⢸⡄${colors[BLACK_FG]}⣿⣿⠟${colors[WHITE_FG]}⡇${colors[ORANGE_FG]} ⢻⡆ ${colors[RED_FG]}⣤⡾⠋⠁                             ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}    ⠹⢿⡿⠟⠉⡴⠊⣁⣤⣀⡀⠉⠳⢬⣓⠒⢊⡉ ⠉⠁ ${colors[WHITE_FG]}⠈⠳⠼⠤⠞⠁${colors[ORANGE_FG]}⢀⠞⠛ ${colors[RED_FG]}⠁                                ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}       ⢀⠞⡰⠊ ⢀⣀⣨⣷⣤⣄⣈⣉⣁⣀⠔       ⣀⠴⠋                                    ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠘⢷⣤⣴⣫⣿⣶⣾⡿⢿⠛⢛⣩⣿⣿⠿⠛⠋ ⣠⡞ ⡠ ⣼⠗⠉                                       ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}     ⠈⢁⣿⠟⠉⣠⣴⣞⣿⣿⣿⡟⢁⡤⣶⣲⣯⣿⡇ ⡇ ⡇   ⣀⡤⠤⠒⠒⠒⠲⢤⡀                             ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}     ⢠⣏⠏⢀⣾⣿⡟⠋⠉⠁ ⣇⠘⣶⣿⡿⢻⣿⣧ ⠻⣄⠙⠒⠒⠋⣀⠤⠶⠛⠛⠛⠲⡄⢹                             ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}     ⣿⣿ ⢸⣿⡇    ⣠⣾⣦⡘⢿⡀⠈⣿⣿⣷⣄⡈⠳⣖⡒⠉      ⣰⢻⠟                             ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}     ⢹⡿⡀ ⣿⡇  ⢠⣾⣽⠟⠉⠑⢄⠱⡀⠙⣿⣿⡸⡏⠒⠤⠍⡑⠒⢄    ⣿⢻⡀  ⣀⣀                         ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}      ⣇⢳⡴⠿⠃  ⣿⣿⠁   ⢸⢂⡇ ⠈⣿⣷⣽⣄  ⠈⠱⡄⢱⡀  ⠈⠓⠛⠻⠿⠛⠟⠓                        ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}      ⠈⢦⠱⡄  ⠘⣿⣿  ⢀⡴⣫⠞⠁  ⠘⣇⢻⠫⡳⡀  ⡇⢸⠇                                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}        ⠳⣜⣆  ⠈⢻⣧ ⢺⣿⠁    ⣰⠟⢸ ⠘⢯⣢⡀⣅⡄                                   ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}          ⢻⡓⢤⣀ ⠿  ⠉⠁  ⣠⢞⣣⠔⠋   ⢻⣧⠘⢿⣦⣄                                 ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}           ⡧⣾⣻⣦      ⣴⡿⠉       ⢻⣧ ⠈⠙⣷⡀                               ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}           ⣇⢿⣿⣿      ⠹⣷⠄       ⠈⣿   ⠈                                ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}           ⢹⣚⣿⣿                ⡰⡿                                    ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}            ⠻⣝⠻⢆    ⣠⣶⣿⣿⣟⣷⣶⠤⢤⣴⡾⠛⠁                                    ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}             ⠈⠉⠉   ⢰⠧⠝⠛⠛⠻⠿⠴⠒⠋⠁                                       ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                                                     ${colors[RESET]}
"
}

show_signature() {    
    if [ "$SPECIAL_CHARACTER_SUPPORT" = true ]; then
        show_signature_part_1
        #sleep 1
        show_signature_part_2
        sleep 1

    fi
}
