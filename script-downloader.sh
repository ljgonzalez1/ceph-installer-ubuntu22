#!/bin/bash


# Verifica si git está instalado
if command -v git &> /dev/null; then
    echo "git ya está instalado."
else
    echo "git no está instalado. Instalando..."
    sudo apt-get update && sudo apt-get install git -y
    if [ $? -eq 0 ]; then
        echo "git se instaló correctamente."
    else
        echo "Hubo un error al instalar git."
        exit 1
    fi
fi

TMP_DIR=$(mktemp -d /tmp/mi_carpeta_XXXXXX)

trap "rm -rf $TEMP_DIR" EXIT


cd ${TMP_DIR}
git clone https://github.com/ljgonzalez1/ceph-installer-ubuntu22
cd ceph-installer-ubuntu22/modularized_version
git pull
chmod a+x ./install-ceph.sh
bash  ./install-ceph.sh
