#!/usr/bin/env bash

# Colores y estilos
declare -x RESET="[0m"
declare -x BOLD="[1m"
declare -x FG_WHITE="[1;37m"
declare -x BG_BLACK="[40m"
declare -x COLOR_OK="[1;32m"
declare -x COLOR_ERROR="[1;31m"
declare -x COLOR_WARN="[1;33m"
declare -x COLOR_BLUE="[1;34m"
declare -x ITALIC="[3m"
declare -x END_ITALIC="[23m"

declare -x CHECK
declare -x CROSS

if [ "$SPECIAL_CHARACTER_SUPPORT" = true ]; then
  CHECK="✓"
  CROSS="✗"

else
  CHECK="●"
  CROSS="●"
fi


print_status() {
  local prefix="$1"
  local color="$2"
  local message="$3"
  printf "
${BOLD}[${color}${prefix}${RESET}${BOLD}]${RESET} ${message}
"
}

show_ok() {
  print_status "$CHECK" "$COLOR_OK" "$1"
}

show_error() {
  print_status "$CROSS" "$COLOR_ERROR" "$1"
}

show_warn() {
  print_status "!" "$COLOR_WARN" "$1"
}

crit_error() {
  echo
  echo -e "[47m[1;30m[[1;31m✗[1;30m][0m [47m[1;30mError crítico: el script ha fallado.[0m"
  echo
  exit 1
}

```


NOMBRE DEL ARCHIVO: `./common/package-utils.sh` (21 Líneas)
```sh
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
