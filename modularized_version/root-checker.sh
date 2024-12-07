#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

check_root_user() {
  echo -e "${BOLD}## Checking for root user...${RESET}"
  
  start_spinner "Checking root user..."
  sleep 1
  
  if [ "$(id -u)" -ne 0 ]; then
    stop_spinner
    show_error "This script must be run as root."
    crit_error
  fi

  # if [ -n "$SUDO_COMMAND" ]; then
  #   stop_spinner
  #   show_error "This script must be run directly as root, not using 'sudo'."
  #   crit_error
  # fi

  stop_spinner
  show_ok "Running as 'root'"
  echo
}
