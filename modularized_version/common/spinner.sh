#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/messages.sh"

declare -x BRAILLE_SPINNER
if [ "$SPECIAL_CHARACTER_SUPPORT" = true ]; then
    BRAILLE_SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

else
    BRAILLE_SPINNER=("|" "/" "-" "\")
fi

declare -x FRAME_DURATION=0.1
declare -x SPINNER_PID=""

cleanup() {
    stop_spinner
    echo
    show_error "Installation cancelled by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

show_spinner() {
    printf "
${BOLD}[${COLOR_BLUE}%s${RESET}${BOLD}]${RESET} %s" "$1" "$2"
}

start_spinner() {
    local message="$1"
    (
        local i=0
        while [ -e "/proc/$PPID" ]; do
            show_spinner "${BRAILLE_SPINNER[i]}" "$message"
            i=$(( (i + 1) % ${#BRAILLE_SPINNER[@]} ))
            sleep "$FRAME_DURATION"
        done
    ) &
    SPINNER_PID=$!
    disown
}

stop_spinner() {
    if [ -n "$SPINNER_PID" ]; then
        kill -9 "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null
        unset SPINNER_PID
    fi
    printf "
\033[K"
}
