# Laboratorio 1 — GPIO bare-metal en STM32 NUCLEO-F412ZG

[![Hardware](https://img.shields.io/badge/Hardware-STM32_NUCLEO--F412ZG-03234B.svg?logo=stmicroelectronics&logoColor=white)](https://www.st.com/en/evaluation-tools/nucleo-f412zg.html)
[![Toolchain](https://img.shields.io/badge/Toolchain-arm--none--eabi--gcc-A8B9CC.svg?logo=arm&logoColor=white)](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
[![GitHub Classroom](https://img.shields.io/badge/GitHub-Classroom-181717.svg?logo=github)](https://classroom.github.com/classrooms/274591709-mmue-arquitectura-sistemas-embebidos-2026)

---

## Tabla de contenidos

- [Contexto](#contexto)
- [Objetivos](#objetivos)
- [Resultado esperado](#resultado-esperado)
- [Hardware](#hardware)
- [Documentación a consultar](#documentación-a-consultar)
- [Flujo con GitHub Classroom](#flujo-con-github-classroom)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Tareas del alumnado](#tareas-del-alumnado)
- [Hitos sugeridos](#hitos-sugeridos)
- [Entorno de desarrollo](#entorno-de-desarrollo)
- [Secuencia técnica de referencia](#secuencia-técnica-de-referencia)
- [Errores frecuentes](#errores-frecuentes)
- [Rúbrica](#rúbrica)

---

## Contexto

Esta práctica introduce el flujo mínimo de desarrollo de firmware para sistemas embebidos usando una placa STM32 NUCLEO-F412ZG y desarrollo **bare-metal**, sin HAL, sin CubeMX y sin build system complejo. La placa integra un programador y depurador ST-LINK, por lo que puede programarse directamente sin hardware externo adicional.

La práctica está pensada como base del resto de laboratorios de la asignatura. El mismo repositorio evolucionará en prácticas sucesivas: arquitectura de software, pruebas, análisis estático, debug y variantes del producto.

---

## Objetivos

Al finalizar esta práctica, el alumnado deberá ser capaz de:

- Consultar el manual de usuario de la NUCLEO y el Reference Manual del microcontrolador para extraer información de hardware y registros.
- Compilar firmware con el toolchain de Arm desde línea de comandos.
- Flashear y ejecutar un binario en la placa.
- Implementar un driver básico de GPIO para leer un botón con polling y controlar un LED.
- Trabajar sobre un repositorio GitHub con commits frecuentes y mensajes claros.

---

## Resultado esperado

El programa final lee el botón de usuario B1 y enciende o apaga el LED de usuario LD2 mediante polling:

- **B1** → PC13 (botón con pull-up: nivel alto en reposo, bajo al pulsar)
- **LD2** → PB7 (LED azul: nivel alto = encendido)

---

## Hardware

- STM32 NUCLEO-F412ZG
- Cable USB-A a Mini-B para alimentación y ST-LINK
- Jumpers CN4 en ON (configuración por defecto para programar el micro de la propia placa)

---

## Documentación a consultar

Esta práctica obliga a usar documentación real. Descarga los documentos desde el campus virtual de la asignatura antes de empezar:

| Documento | Uso en esta práctica |
| --- | --- |
| **UM1974** — Manual de usuario Nucleo-144 | Localizar LED, botón, jumpers y ST-LINK |
| **Datasheet STM32F412ZG** | Identificar encapsulado y pines |
| **RM0402** — Reference Manual STM32F412 | Mapa de memoria, RCC y GPIO |

---

## Flujo con GitHub Classroom

La asignatura usa **GitHub Classroom** para la gestión y entrega de prácticas. Cada alumno recibe una copia individual del repositorio plantilla en el momento de aceptar la tarea.

### Cómo empezar

1. Accede al enlace de la tarea publicado por el profesor en el campus virtual.
2. Acepta el *assignment* en GitHub Classroom — se crea automáticamente un repositorio privado a tu nombre.
3. Clona tu repositorio en local:

   ```bash
   git clone https://github.com/<org>/<repo-asignado>.git
   cd <repo-asignado>
   ```

4. Trabaja sobre ese repositorio. Cada hito funcional debe ser un commit.

### Feedback automático

El repositorio incluye dos flujos de GitHub Actions que se ejecutan en cada `push`:

| Workflow | Qué comprueba |
| --- | --- |
| **Lab 1 — Corrección preguntas guiadas** | Respuestas en `respuestas.env` |
| **Lab 1 — Verificación de compilación** | Que el código compila sin errores |

Consulta los resultados en la pestaña **Actions** de tu repositorio. Puedes hacer tantos `push` como necesites — cada uno actualiza el feedback.

### Convenciones de commits

- Un commit por hito funcional (LED parpadea, botón detectado, driver completo…).
- Mensajes breves y técnicos, en minúsculas:

  ```text
  feat: implementar gpio_config_output
  fix: corregir mascara MODER para PB7
  docs: completar respuestas preguntas guiadas
  ```

- No subas archivos binarios (`*.elf`, `*.bin`, `*.o`) — están en `.gitignore`.

### Entrega

La entrega se realiza automáticamente: el profesor accede al repositorio de cada alumno en la organización de GitHub Classroom. No es necesario crear una pull request ni enviar nada por correo. Asegúrate de que tu último commit de entrega esté subido antes de la fecha límite.

---

## Estructura del repositorio

```text
Raíz del repositorio/
├── README.md
├── respuestas.env              ← rellena con tus respuestas a las preguntas guiadas
├── .gitignore
├── docs/
│   └── preguntas_guiadas.md   ← preguntas de documentación (lee antes de codificar)
├── inc/
│   ├── board.h                ← TODO: asignación de pines y puertos
│   ├── rcc.h                  ← TODO: máscaras de reloj (RCC_AHB1ENR)
│   └── gpio.h                 ← completo — direcciones y declaraciones del driver
├── src/
│   ├── gpio.c                 ← TODO: implementación del driver GPIO
│   └── main.c                 ← TODO: inicialización y bucle de polling
├── startup/
│   └── startup_stm32f412zg.s  ← completo — tabla de vectores y Reset_Handler
├── linker/
│   └── stm32f412zg.ld         ← completo — script de enlazado
└── scripts/
    ├── build.sh               ← compila y genera ELF/BIN/HEX
    ├── flash.sh               ← programa la placa via ST-LINK
    └── check_answers.sh       ← corrector local de respuestas (uso del CI)
```

Los archivos marcados como **completo** son parte de la plantilla y no deben modificarse. Los marcados con **TODO** son los que debes implementar.

---

## Tareas del alumnado

### Parte 1 — Preguntas guiadas de documentación

Antes de escribir código, lee [`docs/preguntas_guiadas.md`](docs/preguntas_guiadas.md) y rellena [`respuestas.env`](respuestas.env) con los valores que encuentres en la documentación técnica.

El corrector automático comprueba tus respuestas en cada `push` y te indica qué está bien, qué está mal y dónde buscar.

### Parte 2 — `inc/board.h`

Rellena las macros con los pines y puertos correctos de B1 y LD2 según el UM1974 y tus respuestas del Bloque 1:

```c
#define B1_PIN    /* número de pin */
#define B1_PORT   /* GPIOX_BASE */
#define LD2_PIN   /* número de pin */
#define LD2_PORT  /* GPIOX_BASE */
```

### Parte 3 — `inc/rcc.h`

Rellena las máscaras de habilitación de reloj según el RM0402 y tus respuestas del Bloque 3:

```c
#define RCC_AHB1ENR_GPIOBEN   /* (1U << ?) */
#define RCC_AHB1ENR_GPIOCEN   /* (1U << ?) */
```

### Parte 4 — `src/gpio.c`

Implementa las cinco funciones del driver. Cada función tiene un comentario `TODO` con los pasos y las referencias al bloque de preguntas guiadas correspondiente:

| Función | Bloque de referencia |
| --- | --- |
| `gpio_enable_clock` | Bloque 3 — RCC_AHB1ENR |
| `gpio_config_input` | Bloque 4 — GPIOx_MODER |
| `gpio_config_output` | Bloque 4 — GPIOx_MODER |
| `gpio_read` | Bloque 5 — IDR |
| `gpio_write` | Bloque 5 — BSRR |

### Parte 5 — `src/main.c`

Completa los cuatro `TODO` del `main`:

1. Habilitar el reloj de los puertos usados.
2. Configurar LD2 como salida.
3. Configurar B1 como entrada.
4. Bucle de polling: leer B1 y controlar LD2 directamente.

### Parte 6 — Verificación en placa

#### Flashear (línea de comandos)

```bash
bash scripts/build.sh   # compila → output/lab1.elf
bash scripts/flash.sh   # programa la placa
```

#### Flashear (VS Code)

**Ctrl+Shift+P** → *Tasks: Run Task* → **flash** — compila y flashea en un solo paso.

#### Depurar (VS Code)

Pulsa **F5** — compila, flashea y abre una sesión de debug que se detiene al inicio de `main()`.

| Tecla | Acción |
| --- | --- |
| **F10** | Paso a paso (sin entrar en funciones) |
| **F11** | Paso a paso (entrando en funciones) |
| **F5** | Continuar hasta el siguiente breakpoint |
| **Shift+F5** | Detener |

Consulta [`debug/README.md`](debug/README.md) para más detalles sobre qué puedes inspeccionar durante el debug.

Comprueba que el LED LD2 (azul) se enciende al pulsar B1 y se apaga al soltarlo.

---

## Hitos sugeridos

Trabaja de forma incremental — un commit por hito:

| Hito | Criterio de éxito en placa |
| --- | --- |
| H1 — LED fijo | LD2 enciende al arrancar (escribe en ODR provisionalmente desde `main`; H2 lo reemplaza con `gpio_write`) |
| H2 — Driver GPIO completo | Las funciones del driver funcionan correctamente |
| H3 — Botón controla LED | B1 enciende y apaga LD2 por polling |

---

## Entorno de desarrollo

- Editor: VS Code (recomendado) o cualquier editor de texto.
- Sistema operativo: WSL en Windows, o Linux nativo.
- Toolchain: `arm-none-eabi-gcc` — instala con `sudo apt install gcc-arm-none-eabi`.
- Programador / depurador: OpenOCD — `sudo apt install openocd` (Linux/WSL) o [gnutoolchains.com/arm-eabi/openocd](https://gnutoolchains.com/arm-eabi/openocd/) (Windows; preinstalado en equipos del laboratorio).
- Control de versiones: Git + GitHub Classroom.

---

## Secuencia técnica de referencia

1. Leer UM1974 → identificar pines de B1 y LD2.
2. Leer RM0402 → mapa de memoria → obtener direcciones base de RCC, GPIOB, GPIOC.
3. Leer RM0402 → RCC_AHB1ENR → calcular máscaras de habilitación.
4. Leer RM0402 → GPIOx_MODER → calcular campo y máscara de cada pin.
5. Leer RM0402 → IDR / BSRR → implementar lectura y escritura.
6. Compilar → flashear → verificar en placa.

---

## Errores frecuentes

- No habilitar el reloj del GPIO antes de acceder a sus registros.
- Confundir el número de pin con el número de bit en MODER (son distintos: MODER usa 2 bits por pin).
- Confundir el nivel activo del botón al leer el IDR.
- Usar documentación de otra familia de STM32.
- Subir archivos binarios al repositorio (usa `.gitignore`).

---

## Rúbrica

| Criterio | Peso |
| --- | ---: |
| Respuestas correctas en `respuestas.env` | 40 % |
| Compilación sin errores | 20 % |
| Funcionamiento en placa | 20 % |
| Implementación correcta del driver GPIO | 10 % |
| Calidad de commits y entrega | 10 % |
