#!/usr/bin/env bash
# flash.sh — Programa el firmware en la NUCLEO-F412ZG via OpenOCD + ST-LINK
set -euo pipefail

ELF="output/lab1.elf"

if [[ ! -f "$ELF" ]]; then
    echo "ERROR: No se encuentra $ELF — ejecuta build.sh primero."
    exit 1
fi

if ! command -v openocd &>/dev/null; then
    echo "ERROR: openocd no está en el PATH."
    echo "       Linux/WSL: sudo apt install openocd"
    echo "       Windows:   descarga desde gnutoolchains.com/arm-eabi/openocd/"
    exit 1
fi

echo "Programando ${ELF} via ST-LINK (OpenOCD)..."
openocd \
    -f interface/stlink.cfg \
    -c "transport select swd" \
    -f target/stm32f4x.cfg \
    -c "program ${ELF} verify reset exit"
echo "Listo."
