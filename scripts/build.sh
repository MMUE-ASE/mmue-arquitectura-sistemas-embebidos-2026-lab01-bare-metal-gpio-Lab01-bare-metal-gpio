#!/usr/bin/env bash
# build.sh — Compila y enlaza el firmware del Lab 1
set -euo pipefail

CC="arm-none-eabi-gcc"
OBJCOPY="arm-none-eabi-objcopy"
CPU_FLAGS="-mcpu=cortex-m4 -mthumb -mfloat-abi=soft"
EXTRA_CFLAGS="${EXTRA_CFLAGS:-}"
CFLAGS="${CPU_FLAGS} -O0 -g3 -ffreestanding -Wall -Wextra -Iinc ${EXTRA_CFLAGS}"

mkdir -p output

echo "[1/4] Compilando startup..."
${CC} ${CPU_FLAGS} -g3 -c startup/startup_stm32f412zg.s \
    -o output/startup.o

echo "[2/4] Compilando gpio.c..."
${CC} ${CFLAGS} -c src/gpio.c -o output/gpio.o

echo "[3/4] Compilando main.c..."
${CC} ${CFLAGS} -c src/main.c -o output/main.o

echo "[4/4] Enlazando..."
${CC} -nostdlib -T linker/stm32f412zg.ld ${CPU_FLAGS} \
    output/startup.o output/gpio.o output/main.o \
    -o output/lab1.elf

${OBJCOPY} -O binary output/lab1.elf output/lab1.bin
${OBJCOPY} -O ihex   output/lab1.elf output/lab1.hex

echo ""
arm-none-eabi-size output/lab1.elf
echo ""
echo "Listo: output/lab1.elf  |  output/lab1.bin  |  output/lab1.hex"
