#!/usr/bin/env bash
# Corrección automática de preguntas guiadas — Lab 1
#
# Uso:
#   bash check_answers.sh <respuestas_alumno.env> <clave_respuestas.env>
#
# La clave de respuestas viene de un secret de organización en GitHub Actions
# y nunca está almacenada en el repositorio.

set -euo pipefail

STUDENT_FILE="${1:-respuestas.env}"
KEY_FILE="${2:-}"

# ---------------------------------------------------------------------------
# Helpers de parseo
# ---------------------------------------------------------------------------

get_from() {
    local file="$1" key="$2"
    grep -E "^${key}=" "$file" 2>/dev/null \
        | head -1 | cut -d'=' -f2- | tr -d ' \r\t' || true
}

to_dec() {
    local val="${1,,}"; val="${val#\"}" ; val="${val%\"}"
    val="${val%%[ul]*}"
    if   [[ "$val" =~ ^0x([0-9a-f]+)$ ]]; then printf "%d" "$val" 2>/dev/null || echo ""
    elif [[ "$val" =~ ^0b([01]+)$      ]]; then echo "$((2#${val#0b}))"
    elif [[ "$val" =~ ^[0-9]+$         ]]; then echo "$((10#$val))"
    else echo ""; fi
}

norm_hex() {
    local val="${1,,}"; val="${val#0x}"; val="${val#\"}"; val="${val%\"}"
    val="${val%%[ul]*}"
    [[ "$val" =~ ^[0-9a-f]+$ ]] && printf "%08x" "0x${val}" 2>/dev/null || echo ""
}

# Rellena con puntos hasta la columna fija
dots() {
    local label="$1" width=36
    local n=$(( width - ${#label} ))
    [[ $n -lt 2 ]] && n=2
    printf '%*s' "$n" '' | tr ' ' '.'
}

# ---------------------------------------------------------------------------
# Tipos de comparación por clave
# ---------------------------------------------------------------------------

declare -A KEY_TYPE
KEY_TYPE[B1_PIN]="pin";            KEY_TYPE[LD2_PIN]="pin"
KEY_TYPE[B1_IDLE_LEVEL]="int";     KEY_TYPE[B1_PRESSED_LEVEL]="int"
KEY_TYPE[RCC_BASE]="hex";          KEY_TYPE[GPIOB_BASE]="hex";       KEY_TYPE[GPIOC_BASE]="hex"
KEY_TYPE[GPIOBEN_BIT]="int";       KEY_TYPE[GPIOCEN_BIT]="int";      KEY_TYPE[AHB1ENR_MASK]="hex"
KEY_TYPE[MODER_BITS_PER_PIN]="int"; KEY_TYPE[MODER_INPUT_VAL]="int"; KEY_TYPE[MODER_OUTPUT_VAL]="int"
KEY_TYPE[PB7_MODER_BIT]="int";     KEY_TYPE[PC13_MODER_BIT]="int"
KEY_TYPE[IDR_OFFSET]="hex";        KEY_TYPE[ODR_OFFSET]="hex"
KEY_TYPE[PC13_IDR_BIT]="int";      KEY_TYPE[PB7_ODR_BIT]="int"

# ---------------------------------------------------------------------------
# Pistas por clave (sin revelar la respuesta)
# ---------------------------------------------------------------------------

declare -A HINT
HINT[B1_PIN]="UM1974 → sección 'Push-button'"
HINT[LD2_PIN]="UM1974 → sección 'LEDs'"
HINT[B1_IDLE_LEVEL]="fíjate en la resistencia pull-up del esquema eléctrico"
HINT[B1_PRESSED_LEVEL]="¿a qué tensión conecta el pin el botón al cerrarse?"
HINT[RCC_BASE]="RM0402 → Memory map → AHB1 peripherals"
HINT[GPIOB_BASE]="RM0402 → Memory map → AHB1 peripherals"
HINT[GPIOC_BASE]="RM0402 → Memory map → AHB1 peripherals"
HINT[GPIOBEN_BIT]="RM0402 → RCC_AHB1ENR → campo GPIOBEN"
HINT[GPIOCEN_BIT]="RM0402 → RCC_AHB1ENR → campo GPIOCEN"
HINT[AHB1ENR_MASK]="OR de los dos bits anteriores"
HINT[MODER_BITS_PER_PIN]="RM0402 → GPIOx_MODER → ancho de cada campo MODERy"
HINT[MODER_INPUT_VAL]="RM0402 → GPIOx_MODER → valor '00'"
HINT[MODER_OUTPUT_VAL]="RM0402 → GPIOx_MODER → valor '01'"
HINT[PB7_MODER_BIT]="fórmula: número_pin × bits_por_pin"
HINT[PC13_MODER_BIT]="fórmula: número_pin × bits_por_pin"
HINT[IDR_OFFSET]="RM0402 → tabla de registros GPIO → GPIOx_IDR"
HINT[ODR_OFFSET]="RM0402 → tabla de registros GPIO → GPIOx_ODR"
HINT[PC13_IDR_BIT]="el bit N del IDR corresponde al pin N"
HINT[PB7_ODR_BIT]="el bit N del ODR corresponde al pin N"

# ---------------------------------------------------------------------------
# Orden de presentación con marcadores de sección (prefijo ##)
# ---------------------------------------------------------------------------

ORDERED_KEYS=(
    "##Bloque 1 . Hardware de la placa"
    B1_PIN LD2_PIN B1_IDLE_LEVEL B1_PRESSED_LEVEL
    "##Bloque 2 . Mapa de memoria"
    RCC_BASE GPIOB_BASE GPIOC_BASE
    "##Bloque 3 . Reloj de perifericos (RCC_AHB1ENR)"
    GPIOBEN_BIT GPIOCEN_BIT AHB1ENR_MASK
    "##Bloque 4 . Modo de pin (GPIOx_MODER)"
    MODER_BITS_PER_PIN MODER_INPUT_VAL MODER_OUTPUT_VAL PB7_MODER_BIT PC13_MODER_BIT
    "##Bloque 5 . Lectura y escritura (IDR / ODR)"
    IDR_OFFSET ODR_OFFSET PC13_IDR_BIT PB7_ODR_BIT
)

# ---------------------------------------------------------------------------
# Guardas de entrada
# ---------------------------------------------------------------------------

if [[ ! -f "$STUDENT_FILE" ]]; then
    echo "ERROR: No se encuentra el fichero del alumno: $STUDENT_FILE"
    exit 1
fi

if [[ -z "$KEY_FILE" || ! -f "$KEY_FILE" ]]; then
    echo "ERROR: Se requiere la clave de respuestas como segundo argumento."
    echo "       Local: bash check_answers.sh respuestas.env clave.env"
    echo "       CI:    el workflow la genera desde el secret LAB1_ANSWER_KEY"
    exit 1
fi

# ---------------------------------------------------------------------------
# Cabecera
# ---------------------------------------------------------------------------

echo ""
echo ".------------------------------------------------."
echo "|  Lab 1  .  Corrector de preguntas guiadas      |"
echo "|  STM32F412ZG  .  NUCLEO-144                    |"
echo "'------------------------------------------------'"

PASSED=0; FAILED=0; SKIPPED=0

# ---------------------------------------------------------------------------
# Bucle de corrección
# ---------------------------------------------------------------------------

for item in "${ORDERED_KEYS[@]}"; do

    # Marcador de sección
    if [[ "$item" == "##"* ]]; then
        echo ""
        echo "  -- ${item#"##"} --"
        echo ""
        continue
    fi

    key="$item"
    student_raw=$(get_from "$STUDENT_FILE" "$key")
    expected_raw=$(get_from "$KEY_FILE" "$key")
    type="${KEY_TYPE[$key]}"

    if [[ -z "$student_raw" ]]; then
        printf "  ⬜  %s %s sin respuesta\n" "$key" "$(dots "$key")"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    case "$type" in
        hex) got=$(norm_hex "$student_raw"); exp=$(norm_hex "$expected_raw") ;;
        pin) got="${student_raw^^}";         exp="${expected_raw^^}"          ;;
        int) got=$(to_dec "$student_raw");   exp=$(to_dec "$expected_raw")   ;;
    esac

    if [[ -z "$got" ]]; then
        printf "  ❌  %s %s formato no reconocido ('%s')\n" "$key" "$(dots "$key")" "$student_raw"
        printf "       → %s\n" "${HINT[$key]:-consulta el Reference Manual}"
        FAILED=$((FAILED + 1))
    elif [[ "$got" == "$exp" ]]; then
        printf "  ✅  %s %s ok\n" "$key" "$(dots "$key")"
        PASSED=$((PASSED + 1))
    else
        printf "  ❌  %s %s incorrecto\n" "$key" "$(dots "$key")"
        printf "       → %s\n" "${HINT[$key]:-consulta el Reference Manual}"
        FAILED=$((FAILED + 1))
    fi

done

# ---------------------------------------------------------------------------
# Resumen final
# ---------------------------------------------------------------------------

TOTAL=$(( PASSED + FAILED + SKIPPED ))

# Nota sobre 10 (división entera por defecto en bash)
if [[ $TOTAL -gt 0 ]]; then
    SCORE=$(( PASSED * 10 / TOTAL ))
    filled=$(( PASSED * 20 / TOTAL ))
    bar=""
    for (( i=0; i<20; i++ )); do
        [[ $i -lt $filled ]] && bar+="█" || bar+="░"
    done
    pct=$(( PASSED * 100 / TOTAL ))
else
    SCORE=0; bar="░░░░░░░░░░░░░░░░░░░░"; pct=0
fi

# ---------------------------------------------------------------------------
# Arte ASCII según nota — LD2 más o menos encendido
# ---------------------------------------------------------------------------

echo ""

if [[ $SCORE -eq 10 ]]; then
    echo "          . . . . . . . ."
    echo "        .                 ."
    echo "      .    * . * . * . *    ."
    echo "     .   *               *   ."
    echo "      .    * . * . * . *    ."
    echo "        .                 ."
    echo "          . . . . . . . ."
    echo "        [ LD2  a plena potencia ]"
elif [[ $SCORE -ge 7 ]]; then
    echo "          . . . . . ."
    echo "        .     * *     ."
    echo "       .    *     *    ."
    echo "        .     * *     ."
    echo "          . . . . . ."
    echo "          [ LD2  encendido ]"
elif [[ $SCORE -ge 5 ]]; then
    echo "          . . . . ."
    echo "        .    . .    ."
    echo "       .             ."
    echo "        .    . .    ."
    echo "          . . . . ."
    echo "          [ LD2  tenue ]"
else
    echo "          . . . . ."
    echo "        .           ."
    echo "       .             ."
    echo "        .           ."
    echo "          . . . . ."
    echo "          [ LD2  apagado ]"
fi

# ---------------------------------------------------------------------------
# Caja de puntuación
# ---------------------------------------------------------------------------

echo ""
echo ".------------------------------------------------."
printf "|  Correctas: %2d / %2d  .  Nota: %2d / 10%-10s|\n" \
    "$PASSED" "$TOTAL" "$SCORE" ""
printf "|  [%s]  %3d%%%-18s|\n" "$bar" "$pct" ""
echo "|                                                |"

if [[ $SCORE -eq 10 ]]; then
    echo "|  Registro perfecto. El chip te obedece.        |"
    echo "|  Ya puedes escribir el driver. 🚀              |"
elif [[ $SCORE -ge 7 ]]; then
    echo "|  Buen trabajo. Dominas los registros.          |"
    echo "|  Revisa los fallos y llega al 10. 💪           |"
elif [[ $SCORE -ge 5 ]]; then
    echo "|  Aprobado, pero el micro merece más y tú puedes.  |"
    echo "|  Vuelve al Reference Manual. 📖                 |"
else
    echo "|  El LED sigue apagado... por ahora.            |"
    echo "|  Cada registro que leas te acerca al 10. 🔍   |"
fi

echo "'------------------------------------------------'"
echo ""

[[ $FAILED -eq 0 && $SKIPPED -eq 0 ]] && exit 0 || exit 1
