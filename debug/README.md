# Depuración con VS Code — Cortex-Debug + OpenOCD

## Cómo funciona

Cuando pulsas **F5** en VS Code ocurre lo siguiente:

```text
VS Code
  └── Cortex-Debug (extensión)
        ├── lanza  →  OpenOCD  ──SWD──►  ST-LINK  ──SWD──►  STM32F412ZG
        │              (servidor GDB)        (hardware en la placa NUCLEO)
        └── lanza  →  arm-none-eabi-gdb
                       (cliente GDB, se conecta a OpenOCD por TCP)
```

1. **OpenOCD** abre una conexión SWD con el microcontrolador a través del ST-LINK integrado en la placa NUCLEO. Actúa como servidor GDB en el puerto 50000.
2. **arm-none-eabi-gdb** se conecta a ese servidor, carga el binario `.elf` en la flash del micro y para la ejecución al inicio de `main()`.
3. Desde ese punto controlas la ejecución línea a línea desde el editor.

No se necesita STM32CubeIDE ni STM32CubeProgrammer para depurar.

---

## Inicio rápido

1. Conecta la placa NUCLEO-F412ZG por USB.
2. Abre la carpeta `Lab1_Bare_Metal_GPIO/` en VS Code.
3. Pulsa **F5** — VS Code compilará el proyecto, lo flasheará y arrancará la sesión de debug.
4. La ejecución se detiene automáticamente al inicio de `main()`.

### Teclas durante la sesión

| Tecla | Acción |
| --- | --- |
| **F5** | Continuar hasta el siguiente breakpoint |
| **F10** | Paso a paso — ejecuta la línea actual sin entrar en funciones |
| **F11** | Paso a paso — entra dentro de la función llamada |
| **Shift+F11** | Sale de la función actual |
| **Shift+F5** | Detener la sesión de debug |

### Breakpoints

Haz clic en el margen izquierdo de cualquier línea de código (aparece un punto rojo) para añadir un breakpoint. La ejecución se detendrá al llegar a esa línea.

---

## Qué puedes inspeccionar

### Variables locales y globales

En el panel **Variables** (izquierda) puedes ver el valor de todas las variables en el ámbito actual mientras vas paso a paso.

### Registros del procesador

En el panel **Cortex Registers** puedes ver R0–R15, PC, SP y los registros de estado del Cortex-M4 en tiempo real.

### Registros de periféricos (SVD)

El panel **Cortex Peripherals** muestra el valor actual de todos los registros del microcontrolador: `RCC_AHB1ENR`, `GPIOB_MODER`, `GPIOB_IDR`, `GPIOC_BSRR`… Es especialmente útil para verificar que tus funciones del driver GPIO escriben los valores correctos en los registros hardware.

Para activarlo necesitas el fichero SVD del STM32F412. El fichero ya está referenciado en `.vscode/launch.json` — no necesitas cambiar nada más.

---

## Solución de problemas habituales

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| `spawn openocd.exe ENOENT` | VS Code no encuentra el ejecutable | Comprobar `cortex-debug.openocdPath` en `.vscode/settings.json` |
| `Examination failed` | El MCU está en sleep o HardFault | Ya resuelto con `debug/openocd-connect.cfg` — si persiste, desconecta y reconecta el USB |
| `No ST-LINK device found` | Driver ST-LINK no instalado o placa no conectada | Instalar STM32CubeProgrammer para los drivers; reconectar USB |
| GDB no carga el `.elf` | No se ha compilado aún | Ejecutar `bash scripts/build.sh` antes de F5, o dejar que el `preLaunchTask` lo haga |
