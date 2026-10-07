# README - Nacimiento del MiniDatapath

## ¿Qué teníamos antes?

Hasta ahora habíamos construido una ALU completa.

La ALU era un módulo funcional capaz de realizar:

* ADD
* SUB
* AND
* OR
* SLT (corregido con overflow)
* XOR
* SLL
* SRL

Además generaba:

* `y`
* `zero`
* `overflow`

La interfaz de la ALU era:

```text
Entradas:
- a
- b
- sel

Salidas:
- y
- zero
- overflow
```

Visualmente:

```text
              sel
               │
               ▼
          ┌────────┐
a ───────►│        │────► y
b ───────►│  ALU   │────► zero
          │        │────► overflow
          └────────┘
```

En el testbench hacíamos cosas como:

```verilog
sel = 3'b000; // ADD
sel = 3'b001; // SUB
sel = 3'b100; // SLT
```

Es decir:

> Nosotros decidíamos manualmente qué operación debía ejecutar la ALU.

---

# El siguiente problema

En un procesador real nadie escribe:

```verilog
sel = 3'b100;
```

El procesador recibe instrucciones, por ejemplo:

```text
add
sub
and
or
slt
```

y debe descubrir por sí mismo qué operación debe ejecutar la ALU.

Necesitamos un traductor.

---

# Aparece el AluDecoder

Creamos un nuevo módulo funcional:

```text
AluDecoder
```

Su trabajo es:

> Traducir información de la instrucción en señales para la ALU.

Inicialmente comenzaremos solamente con:

```text
funct3
```

Visualmente:

```text
          funct3
             │
             ▼
      ┌────────────┐
      │ AluDecoder │
      └────────────┘
             │
             ▼
      ALUControl[2:0]
```

La salida del decoder será:

```text
ALUControl[2:0]
```

que reemplazará al antiguo:

```text
sel
```

Todavía no utilizaremos:

```text
funct7
ALUOp
```

Esas señales aparecerán más adelante cuando descubramos que `funct3` por sí solo no basta para distinguir todas las instrucciones.

---

# Nace el MiniDatapath

Ahora tenemos dos módulos separados:

```text
ALU
AluDecoder
```

Necesitamos que hablen entre sí.

Para eso construiremos un módulo estructural:

```text
MiniDatapath
```

Su trabajo no es realizar cálculos.

Su trabajo es:

> Conectar módulos funcionales.

Internamente hará algo equivalente a:

```verilog
wire [2:0] ALUControl;

AluDecoder dec(...);

Alu alu(...);
```

Visualmente:

```text
                    MiniDatapath
      ┌─────────────────────────────────┐
      │                                 │
funct3│ ──► AluDecoder                  │
      │         │                       │
      │         ▼                       │
      │   ALUControl[2:0]              │
      │         │                       │
a     │ ────────────────►              │
      │                    ALU         │──► y
b     │ ────────────────►              │──► zero
      │                                │──► overflow
      │                                 │
      └─────────────────────────────────┘
```

---

# ¿Cuál es el objetivo?

Antes necesitábamos proporcionar:

```text
a
b
sel
```

Ahora solamente necesitaremos proporcionar:

```text
funct3
a
b
```

y el sistema hará automáticamente:

```text
funct3
↓
AluDecoder
↓
ALUControl
↓
ALU
↓
resultado
```

Es decir:

> Dejamos de decidir manualmente la operación de la ALU.

---

# La interfaz del MiniDatapath

El MiniDatapath también tiene entradas y salidas propias.

Entradas:

```text
funct3
a
b
```

Salidas:

```text
y
zero
overflow
```

Por lo tanto, el MiniDatapath puede verse como una "caja negra":

```text
           ┌─────────────────┐
funct3 ───►│                 │──► y
a ────────►│ MiniDatapath    │──► zero
b ────────►│                 │──► overflow
           └─────────────────┘
```

El MiniDatapath no necesita saber todavía de dónde vienen `a`, `b` o `funct3`.

Simplemente asume:

> "Si me das estas entradas, yo me encargo del resto."

---

# Evolución del Testbench

Este cambio modifica qué módulo estamos probando.

## Antes

El DUT (Device Under Test) era la ALU.

El testbench apuntaba directamente a ella:

```text
           Testbench
               │
               ▼
              ALU
         ┌────────┐
a ──────►│        │────► y
b ──────►│        │────► zero
sel ────►│        │────► overflow
         └────────┘
```

Verificábamos:

> "¿Funciona la ALU?"

---

## Ahora

El DUT pasa a ser el MiniDatapath.

El testbench ya no hablará directamente con la ALU.

Ahora hablará con el módulo estructural:

```text
                 Testbench
                     │
                     ▼
             ┌─────────────────┐
             │ MiniDatapath    │
             │                 │
funct3 ─────►│ AluDecoder       │
a ──────────►│              ALU │────► y
b ──────────►│                  │────► zero
             │                  │────► overflow
             └─────────────────┘
```

Ahora verificaremos:

> "¿Funciona correctamente la cooperación entre el AluDecoder y la ALU?"

---

# ¿Qué aprendimos hoy?

Existen dos tipos de módulos.

## Módulos funcionales

Realizan lógica.

Ejemplos:

* ALU
* AluDecoder
* Register File
* Main Decoder
* Immediate Extend

Contienen cosas como:

```verilog
always @(*)
case(...)
assign ...
```

Su responsabilidad es:

> Transformar entradas en salidas mediante lógica.

---

## Módulos estructurales

No realizan cálculos complejos.

Su trabajo es conectar otros módulos.

Ejemplos:

* MiniDatapath
* Datapath
* Controller
* Processor

Contienen principalmente:

```verilog
wire ...
ModuloA ...
ModuloB ...
```

Su responsabilidad es:

> Organizar la comunicación entre bloques funcionales.

---

# ¿Por qué es importante este paso?

Porque es la primera vez que dejamos de pensar en módulos aislados y comenzamos a pensar como arquitectos de computadores.

Antes construíamos herramientas:

```text
ALU
```

Ahora empezamos a construir cómo esas herramientas cooperan:

```text
AluDecoder
↓
ALUControl
↓
ALU
```

Y dimos el primer paso hacia un procesador real.

El siguiente gran paso será preguntarnos:

> ¿De dónde salen realmente `funct3`, `a` y `b`?

La respuesta a esa pregunta nos llevará al `Register File` y a la `Instruction Memory`, haciendo que este MiniDatapath crezca poco a poco hasta convertirse en el Datapath completo del procesador.
