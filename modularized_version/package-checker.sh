#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"
source "$(dirname "${BASH_SOURCE[0]}")/package-utils.sh"

# Lista de paquetes requeridos
declare -x REQUIRED_PACKAGES=("sed" "openssh-client" "openssh-server" "ca-certificates" "screen" "dialog" "python3" "curl" "wget" "ncurses-bin")

check_dependencies() {
  echo -e "${BOLD}## Checking dependencies...${RESET}"

  MISSING_PKGS=()

  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    case "$pkg" in
      "python3")
        start_spinner "Checking for 'python3' (<3.11)..."
        check_python_version
        stop_spinner
        show_ok "Package ${ITALIC}'python3'${END_ITALIC} (<3.11) is installed."
        ;;
      *)
        start_spinner "Checking for '$pkg'..."
        sleep 0.5
        if is_installed "$pkg"; then
          stop_spinner
          show_ok "Package ${ITALIC}'$pkg'${END_ITALIC} is installed."
        else
          stop_spinner
          show_error "Package ${ITALIC}'$pkg'${END_ITALIC} is missing."
          MISSING_PKGS+=("$pkg")
        fi
        ;;
    esac
  done

  if [ ${#MISSING_PKGS[@]} -eq 0 ]; then
    show_ok "${BOLD}Dependencies installed.${RESET}"
    echo
    return 0
  else
    show_warn "${BOLD}Some dependencies are missing.${RESET}"
    echo
    #echo "${MISSING_PKGS[@]}"
    return 1
  fi
}
