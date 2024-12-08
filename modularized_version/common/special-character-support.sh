#!/bin/bash

declare -x SPECIAL_CHARACTER_SUPPORT=false

test_special_character_support() {
    # Verificar si el terminal soporta al menos 256 colores
    # Los terminales modernos que soportan 256 colores generalmente también soportan UTF-8
    if [ "$(tput colors 2>/dev/null || echo 0)" -ge 256 ]; then
        # Verificación adicional del locale
        if locale charmap | grep -q "UTF-8"; then
            SPECIAL_CHARACTER_SUPPORT=true
            return 0
        fi
    fi
    
    SPECIAL_CHARACTER_SUPPORT=false
    return 1
}
