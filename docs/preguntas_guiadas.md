# Lab 1 — Preguntas guiadas de documentación

Antes de escribir código debes completar el archivo [`respuestas.env`](../respuestas.env) con las respuestas a estas preguntas. Cada respuesta tiene una clave fija que el sistema de corrección comprueba automáticamente.

**Documentos que necesitas:**

- **UM1974** — Manual de usuario STM32 Nucleo-144 (hardware de placa)
- **Datasheet STM32F412ZG** — Encapsulado y pines
- **Reference Manual STM32F412 (RM0402)** — Mapa de memoria, RCC y GPIO

---

## Bloque 1 — Hardware de la placa

> Fuente: UM1974

**P1.1** ¿A qué pin del microcontrolador está conectado el botón de usuario B1?
→ Clave: `B1_PIN` (formato: letra de puerto + número, ej. `PA5`)

**P1.2** ¿A qué pin del microcontrolador está conectado el LED de usuario LD2?
→ Clave: `LD2_PIN`

**P1.3** ¿Qué nivel lógico tiene el pin del botón cuando **no** está pulsado? ¿Y cuando **sí** está pulsado?
→ Claves: `B1_IDLE_LEVEL` y `B1_PRESSED_LEVEL` (valores: `0` o `1`)

---

## Bloque 2 — Mapa de memoria

> Fuente: RM0402, sección "Memory map"

**P2.1** ¿Cuál es la dirección base de RCC?
→ Clave: `RCC_BASE` (formato hex con prefijo `0x`, ej. `0x40000000`)

**P2.2** ¿Cuál es la dirección base de GPIOB?
→ Clave: `GPIOB_BASE`

**P2.3** ¿Cuál es la dirección base de GPIOC?
→ Clave: `GPIOC_BASE`

---

## Bloque 3 — Habilitación del reloj (RCC_AHB1ENR)

> Fuente: RM0402, sección RCC → registro RCC_AHB1ENR

**P3.1** ¿Cuál es el número del bit que habilita el reloj de GPIOB en RCC_AHB1ENR?
→ Clave: `GPIOBEN_BIT` (número entero, ej. `0`)

**P3.2** ¿Cuál es el número del bit que habilita el reloj de GPIOC?
→ Clave: `GPIOCEN_BIT`

**P3.3** ¿Cuál es la máscara hexadecimal para habilitar ambos puertos a la vez?
→ Clave: `AHB1ENR_MASK` (hex con prefijo `0x`)

---

## Bloque 4 — Modo de pin (GPIOx_MODER)

> Fuente: RM0402, sección GPIO → GPIOx_MODER

**P4.1** ¿Cuántos bits ocupa la configuración de modo de cada pin en MODER?
→ Clave: `MODER_BITS_PER_PIN` (número entero)

**P4.2** ¿Qué valor (decimal) configura un pin como **entrada**?
→ Clave: `MODER_INPUT_VAL`

**P4.3** ¿Qué valor (decimal) configura un pin como **salida de propósito general**?
→ Clave: `MODER_OUTPUT_VAL`

**P4.4** ¿En qué posición de bit (la menos significativa del par) empieza el campo de modo de PB7 dentro de GPIOB_MODER?
→ Clave: `PB7_MODER_BIT` (número entero)

**P4.5** ¿En qué posición de bit empieza el campo de modo de PC13 dentro de GPIOC_MODER?
→ Clave: `PC13_MODER_BIT`

---

## Bloque 5 — Lectura y escritura (IDR / ODR)

> Fuente: RM0402, registros GPIOx_IDR y GPIOx_ODR

**P5.1** ¿Cuál es el offset de IDR dentro del bloque de registros de un GPIO?
→ Clave: `IDR_OFFSET` (hex con prefijo `0x`)

**P5.2** ¿Cuál es el offset de ODR?
→ Clave: `ODR_OFFSET`

**P5.3** ¿Qué número de bit del GPIOC_IDR corresponde a PC13?
→ Clave: `PC13_IDR_BIT`

**P5.4** ¿Qué número de bit del GPIOB_ODR corresponde a PB7?
→ Clave: `PB7_ODR_BIT`

---

## Instrucciones de entrega

1. Rellena [`respuestas.env`](../respuestas.env) con todos los valores.
2. Haz commit con un mensaje claro, por ejemplo:

   ```text
   docs: completar respuestas preguntas guiadas lab1
   ```

3. Haz push. El corrector se ejecutará automáticamente.
4. Consulta el resultado en la pestaña **Actions** de tu repositorio → workflow **Lab 1 — Corrección preguntas guiadas**.

Si algo falla verás una pista debajo de cada respuesta incorrecta. Corrígela, haz otro commit y vuelve a hacer push — puedes intentarlo tantas veces como necesites.
