# Nivel 27: Del Single-Cycle al Pipeline – El Nacimiento del Pipeline

## Introducción

Hasta este punto hemos construido un procesador RISC-V monociclo capaz de ejecutar correctamente las instrucciones:

```assembly
add
addi
lw
```

Nuestro procesador ya posee:

* Program Counter.
* Instruction Memory.
* Register File.
* Immediate Extend.
* ALU.
* Data Memory.
* Multiplexores de control.
* Controller completo para las instrucciones implementadas.

Sin embargo, aunque funcional, existe una característica importante en este diseño:

> Todo ocurre dentro de un único ciclo de reloj.

Es decir, hemos estado trabajando con un procesador **Single-Cycle**.

Pero, ¿qué significa realmente "Single-Cycle"? ¿Por qué existe el diseño Multi-Cycle? ¿Y qué cambia cuando aparece el Pipeline?

Este nivel busca responder esas preguntas y preparar el camino hacia la siguiente gran transformación de nuestro procesador.

---

# ¿Qué significa Single-Cycle?

En un procesador Single-Cycle, cada instrucción realiza absolutamente todo su trabajo entre dos flancos consecutivos del reloj.

Por ejemplo, una instrucción `lw` realiza:

```text
PC
↓
Instruction Memory
↓
Register File
↓
Immediate Extend
↓
ALU
↓
Data Memory
↓
Write Back
```

Todo esto ocurre dentro de un único ciclo.

Visualmente:

Ciclo 1:

```text
Instr1:
IF → ID → EX → MEM → WB
```

Ciclo 2:

```text
Instr2:
IF → ID → EX → MEM → WB
```

Ciclo 3:

```text
Instr3:
IF → ID → EX → MEM → WB
```

Cada ciclo termina una instrucción completa.

Por ello, solemos resumirlo con la frase:

> **Single-Cycle: una instrucción por ciclo largo.**

---

# Entonces, ¿qué es realmente un ciclo?

Una de las ideas más importantes que descubrimos es que:

> Un ciclo no representa el tiempo que tarda una instrucción.

Un ciclo representa:

> El tiempo entre dos flancos consecutivos del reloj.

Por ejemplo:

```text
clk:

___|‾‾‾|___|‾‾‾|___|‾‾‾|___
      ↑       ↑
   Ciclo 1  Ciclo 2
```

Los registros del procesador sólo cambian en esos instantes.

---

# ¿Cómo se determina la duración del ciclo?

Cada bloque posee un tiempo de propagación.

Por ejemplo:

```text
Instruction Memory : 2 ns
Register File      : 1 ns
ALU                : 2 ns
Data Memory        : 4 ns
MUX                : 1 ns
```

Una instrucción `lw` podría tardar:

```text
2 + 1 + 2 + 4 + 1 = 10 ns
```

Entonces el reloj del Single-Cycle debe cumplir:

```text
Clock ≥ 10 ns
```

Es decir:

> El ciclo del reloj debe ser lo suficientemente largo para permitir que la instrucción más lenta termine completamente.

---

# El problema del Single-Cycle

No todas las instrucciones necesitan el mismo trabajo.

Por ejemplo:

```assembly
add
```

no utiliza Data Memory.

Sin embargo:

```assembly
lw
```

sí la utiliza.

A pesar de ello, ambas deben esperar el mismo ciclo largo.

Por ejemplo:

```text
add  → necesita 6 ns
lw   → necesita 10 ns

Clock = 10 ns
```

Por lo tanto:

> Las instrucciones simples pagan el costo de las más complejas.

---

# Nace el Multi-Cycle

La siguiente idea fue preguntarse:

> ¿Por qué todas las instrucciones deben terminar en un solo ciclo?

Entonces dividimos el trabajo en etapas.

```text
IF
ID
EX
MEM
WB
```

Ahora una instrucción avanza paso a paso.

Por ejemplo:

```text
Ciclo 1 : IF
Ciclo 2 : ID
Ciclo 3 : EX
Ciclo 4 : MEM
Ciclo 5 : WB
```

Y recién después comienza la siguiente instrucción.

Visualmente:

```text
Instr1:

IF → ID → EX → MEM → WB

Instr2:

IF → ID → EX → MEM → WB
```

La frase para recordarlo es:

> **Multi-Cycle: una instrucción ocupa varios ciclos pequeños.**

---

# Entonces, ¿el Multi-Cycle es peor?

No.

Porque ahora el reloj ya no está determinado por toda la instrucción.

Está determinado por la etapa más lenta.

Por ejemplo:

```text
IF  = 2 ns
ID  = 3 ns
EX  = 2 ns
MEM = 4 ns
WB  = 1 ns
```

El nuevo reloj será:

```text
Clock = 4 ns
```

Es decir:

> Los ciclos son mucho más pequeños.

---

# El nacimiento del Pipeline

Una nueva pregunta apareció:

> Si una instrucción está en Execute, ¿por qué Fetch está esperando sin hacer nada?

Entonces surgió la idea más poderosa:

> Ejecutar varias instrucciones al mismo tiempo.

No realizando la misma etapa.

Sino realizando etapas distintas.

---

# ¿Cómo funcionará nuestro Pipeline?

Separaremos nuestro procesador en cinco etapas:

```text
IF  : Instruction Fetch
ID  : Instruction Decode
EX  : Execute
MEM : Memory Access
WB  : Write Back
```

Y colocaremos registros entre ellas.

```text
PC
↓
IF
↓
IF/ID
↓
ID
↓
ID/EX
↓
EX
↓
EX/MEM
↓
MEM
↓
MEM/WB
↓
WB
```

---

# ¿Por qué necesitamos registros?

Porque varias instrucciones convivirán simultáneamente.

Por ejemplo:

Ciclo 1:

```text
IF : Instr1
```

Ciclo 2:

```text
ID : Instr1
IF : Instr2
```

Ciclo 3:

```text
EX : Instr1
ID : Instr2
IF : Instr3
```

Cada registro actúa como una fotografía del trabajo realizado por la etapa anterior.

Por ello, aunque nuevas instrucciones lleguen, la información de las anteriores no se pierde.

---

# Una observación importante

Todos los registros del pipeline utilizan el mismo reloj.

No existen relojes distintos para cada etapa.

Por ello:

> Aunque una etapa termine antes, debe esperar al siguiente flanco del reloj.

---

# ¿Quién determina el reloj del Pipeline?

La etapa más lenta.

Por ejemplo:

```text
IF  = 2 ns
ID  = 3 ns
EX  = 10 ns
MEM = 4 ns
WB  = 1 ns
```

Entonces:

```text
Clock = 10 ns
```

Aunque Fetch termine rápidamente, deberá esperar a Execute.

Por ello:

> La frecuencia máxima del pipeline está limitada por la etapa más lenta.

---

# Comparación final

Single-Cycle:

> Una instrucción por ciclo largo.

Multi-Cycle:

> Una instrucción ocupa varios ciclos pequeños.

Pipeline:

> Después de llenarse, completa aproximadamente una instrucción por ciclo.

---

# Estado actual del proyecto

Actualmente nuestro procesador monociclo soporta:

```assembly
add
addi
lw
```

y posee todos los bloques necesarios para comenzar la segmentación.

---

# Próximo paso

En el siguiente nivel comenzaremos la transformación real hacia Pipeline.

Introduciremos nuestros primeros registros:

```text
IF/ID
ID/EX
EX/MEM
MEM/WB
```

permitiendo que múltiples instrucciones avancen simultáneamente a través del procesador.

Ya no estaremos agregando únicamente instrucciones nuevas.

Estaremos cambiando la manera en que el procesador entiende el tiempo.
