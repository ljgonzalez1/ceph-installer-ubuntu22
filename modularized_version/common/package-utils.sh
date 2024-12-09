#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"
source "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"

is_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

check_python_version() {
  pyver=$(apt-cache madison python3 | grep -oP '3\.\d+' | sort -V | head -n 1)
  if [ -z "$pyver" ]; then
    show_error "Python3 is not installed. Please install python3 < 3.11."
    crit_error
  fi
  ver_comp=$(echo -e "$pyver
3.11" | sort -V | head -n 1)
  if [ "$ver_comp" = "3.11" ]; then
    show_error "Python3 version $pyver does not meet requirements (<3.11)."
    crit_error
  fi
}
