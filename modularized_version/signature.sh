#!/usr/bin/env bash

# Función auxiliar para definir las variables ANSI
setup_ansi_variables() {
    # Variables ANSI básicas
    local -n r=$1  # Referencia al hash asociativo que se pasará

    # Reset
    r[RESET]="\e[0m"

    # Colores estándar para fondo
    r[BLUE_BG]="\e[44m"
    r[CYAN_BG]="\e[46m"
    r[RED_BG]="\e[41m"
    r[BLACK_BG]="\e[40m"
    r[WHITE_BG]="\e[47m"
    r[TRANSPARENT_BG]="\e[49m"
    r[YELLOW_BG]="\e[43m"

    # Estilos de texto
    r[BOLD]="\e[1m"
    r[UNDERLINE]="\e[4m"
    r[ITALIC]="\e[3m"
    r[END_BOLD]="\e[22m"
    r[END_UNDERLINE]="\e[24m"
    r[END_ITALIC]="\e[23m"

    # Colores estándar para texto
    r[BLUE_FG]="\e[34m"
    r[CYAN_FG]="\e[36m"
    r[RED_FG]="\e[31m"
    r[BLACK_FG]="\e[30m"
    r[WHITE_FG]="\e[37m"
    r[TRANSPARENT_FG]="\e[39m"
    r[YELLOW_FG]="\e[33m"

    # Verificar soporte de 256 colores
    if tput colors 2>/dev/null | grep -q '^256$'; then
        # TrueColor o 256 colores disponibles
        r[LIGHT_BLUE_BG]="\e[48;5;81m"       # Celeste estándar
        r[VERY_LIGHT_BLUE_BG]="\e[48;5;159m" # Celeste pastel
        r[DARK_BLUE_BG]="\e[48;5;17m"        # Azul oscuro
        r[ORANGE_BG]="\e[48;5;214m"          # Naranja

        r[LIGHT_BLUE_FG]="\e[38;5;81m"       # Celeste estándar
        r[VERY_LIGHT_BLUE_FG]="\e[38;5;159m" # Celeste pastel
        r[DARK_BLUE_FG]="\e[38;5;17m"        # Azul oscuro
        r[ORANGE_FG]="\e[38;5;214m"          # Naranja
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
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⣀⠤⠒⠒⠛⠒⠒⠢⠤⠐⠲⡄                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⣼⠁⠀⢀⣾⣦⡶⠀⠀⠀⠀⡼⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⢀⣽⠴⠓⠉⠁⠀⠀⠀⢠⠄⢰⠁⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⣠⠖⠉⠉⠀⠀⠀⠀⠀⠀⢠⡏⠀⡏⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⡠⡚⠁⠀⠀⠀⠀⠀⠀⠀⠀⢀⠟⢁⡾⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠛⠉⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⢀⣴⠺⠥⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠎⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⢀⡴⠖⠒⠖⠤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠾⠛⠳⣄⠀⠀⠀⠀⠀⠀⠀⠀${RED_FG}⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⡔⣡⣿⠿⠛⠿⣦⡌⢦⠀⠀⠀⠀⠀⠀⠀⣠⠎⢁${WHITE_FG}⡤⠒⢢⣄${colors[ORANGE_FG]}⠈⠳⡄⠀${RED_FG}⢀⣤⠀⣦⠖⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⣾⡀⢀⣼⣵⠟⠁⢀⣀⣀⣈⣿⠘⣆⠀⠀⠀⠀⣠⣴⡃⠀${WHITE_FG}⢸⡄${BLACK_FG}⣿⣿⠟${WHITE_FG}⡇${colors[ORANGE_FG]}⠀⢻⡆${RED_FG}⣤⡾⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠹⢿⡿⠟⠉⡴⠊⣁⣤⣀⡀⠉⠳⢬⣓⠒⢊⡉⠀⠉⠁⠀${WHITE_FG}⠈⠳⠼⠤⠞⠁${colors[ORANGE_FG]}⢀⠞⠛${RED_FG}⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⢀⠞⡰⠊⠀⢀⣀⣨⣷⣤⣄⣈⣉⣁⣀⠔⠀⠀⠀⠀⠀⠀⠀⣀⠴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠘⢷⣤⣴⣫⣿⣶⣾⡿⢿⠛⢛⣩⣿⣿⠿⠛⠋⠀⣠⡞⠀⡠⠀⣼⠗⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠈⢁⣿⠟⠉⣠⣴⣞⣿⣿⣿⡟⢁⡤⣶⣲⣯⣿⡇⠀⡇⠀⡇⠀⠀⠀⣀⡤⠤⠒⠒⠒⠲⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⢠⣏⠏⢀⣾⣿⡟⠋⠉⠁⠀⣇⠘⣶⣿⡿⢻⣿⣧⠀⠻⣄⠙⠒⠒⠋⣀⠤⠶⠛⠛⠛⠲⡄⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⣿⣿⠀⢸⣿⡇⠀⠀⠀⠀⣠⣾⣦⡘⢿⡀⠈⣿⣿⣷⣄⡈⠳⣖⡒⠉⠀⠀⠀⠀⠀⠀⣰⢻⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⢹⡿⡀⠀⣿⡇⠀⠀⢠⣾⣽⠟⠉⠑⢄⠱⡀⠙⣿⣿⡸⡏⠒⠤⠍⡑⠒⢄⠀⠀⠀⠀⣿⢻⡀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⣇⢳⡴⠿⠃⠀⠀⣿⣿⠁⠀⠀⠀⢸⢂⡇⠀⠈⣿⣷⣽⣄⠀⠀⠈⠱⡄⢱⡀⠀⠀⠈⠓⠛⠻⠿⠛⠟⠓⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠈⢦⠱⡄⠀⠀⠘⣿⣿⠀⠀⢀⡴⣫⠞⠁⠀⠀⠘⣇⢻⠫⡳⡀⠀⠀⡇⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠳⣜⣆⠀⠀⠈⢻⣧⠀⢺⣿⠁⠀⠀⠀⠀⣰⠟⢸⠀⠘⢯⣢⡀⣅⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⢻⡓⢤⣀⠀⠿⠀⠀⠉⠁⠀⠀⣠⢞⣣⠔⠋⠀⠀⠀⢻⣧⠘⢿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⡧⣾⣻⣦⠀⠀⠀⠀⠀⠀⣴⡿⠉⠀⠀⠀⠀⠀⠀⠀⢻⣧⠀⠈⠙⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⣇⢿⣿⣿⠀⠀⠀⠀⠀⠀⠹⣷⠄⠀⠀⠀⠀⠀⠀⠀⠈⣿⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⢹⣚⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣝⠻⢆⠀⠀⠀⠀⣠⣶⣿⣿⣟⣷⣶⠤⢤⣴⡾⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠀⠀⠀⢰⠧⠝⠛⠛⠻⠿⠴⠒⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  ${colors[RESET]}
${colors[BOLD]}${colors[DARK_BLUE_BG]}${colors[ORANGE_FG]}                                                                     ${colors[RESET]}
"
}

show_signature() {
    show_signature_part_1
    #sleep 1
    show_signature_part_2
    sleep 1
}