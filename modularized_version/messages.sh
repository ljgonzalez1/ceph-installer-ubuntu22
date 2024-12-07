#!/usr/bin/env bash

# Colores y estilos
declare -x RESET="\033[0m"
declare -x BOLD="\033[1m"
declare -x FG_WHITE="\033[1;37m"
declare -x BG_BLACK="\033[40m"
declare -x COLOR_OK="\033[1;32m"
declare -x COLOR_ERROR="\033[1;31m"
declare -x COLOR_WARN="\033[1;33m"
declare -x COLOR_BLUE="\033[1;34m"
declare -x ITALIC="\033[3m"
declare -x END_ITALIC="\033[23m"

print_status() {
  local prefix="$1"
  local color="$2"
  local message="$3"
  printf "\r${BOLD}[${color}${prefix}${RESET}${BOLD}]${RESET} ${message}\n"
}

show_ok() {
  print_status "✓" "$COLOR_OK" "$1"
}

show_error() {
  print_status "✗" "$COLOR_ERROR" "$1"
}

show_warn() {
  print_status "!" "$COLOR_WARN" "$1"
}

crit_error() {
  echo
  echo -e "\033[47m\033[1;30m[\033[1;31m✗\033[1;30m]\033[0m \033[47m\033[1;30mError crítico: el script ha fallado.\033[0m"
  echo
  exit 1
}
