# README – Nivel 26: Incorporación de `lw` a un Procesador RISC-V Monociclo

## Introducción

En las etapas anteriores, el procesador era capaz de ejecutar instrucciones aritméticas simples como:

* `add`
* `addi`

Estas instrucciones permitían operar sobre registros utilizando la ALU y escribir el resultado nuevamente en el Register File. Sin embargo, un procesador real también necesita interactuar con memoria de datos. Por ello, el siguiente paso consistió en implementar la instrucción:

```assembly
lw rd, imm(rs1)
```

Con esta incorporación, el procesador dejó de ser únicamente una "calculadora de registros" para convertirse en un procesador capaz de cargar información desde memoria.

---

# Estado previo del procesador

Antes de implementar `lw`, el datapath era:

```text
PC
↓
Instruction Memory
↓
Register File
↓
Immediate Extend
↓
MUX (ALUSrc)
↓
ALU
↓
Register File
```

Se soportaban dos tipos de instrucciones.

## R-Type (`add`)

Ejemplo:

```assembly
add x11, x9, x10
```

Operación:

```text
x11 = x9 + x10
```

Flujo:

```text
Register File
↓
ALU
↓
Register File
```

---

## I-Type (`addi`)

Ejemplo:

```assembly
addi x10, x1, 20
```

Operación:

```text
x10 = x1 + 20
```

Flujo:

```text
Register File
↓
Immediate Extend
↓
MUX (ALUSrc)
↓
ALU
↓
Register File
```

---

# Problema: ¿Cómo implementar `lw`?

La instrucción:

```assembly
lw x5, 8(x1)
```

NO significa:

```text
x5 = x1 + 8
```

Sino:

```text
dirección = x1 + 8
x5 = MEM[dirección]
```

Es decir, la ALU ya no produce el dato final.

Ahora produce una dirección de memoria.

---

# Comprendiendo `lw`

Supongamos:

```text
x1 = 10000
```

y ejecutamos:

```assembly
lw x5, 8(x1)
```

## Paso 1: Leer rs1

El Register File recibe:

```text
A1 = rs1
```

y devuelve:

```text
RD1 = RF[x1]
```

Resultado:

```text
RD1 = 10000
```

---

## Paso 2: Extender el inmediato

El Extend recibe:

```text
imm = 8
```

y produce:

```text
ImmExt = 8
```

---

## Paso 3: Calcular la dirección

La ALU realiza:

```text
10000 + 8
```

obteniendo:

```text
AluResult = 10008
```

Este valor NO es el resultado final.

Ahora representa:

```text
Address = 10008
```

---

## Paso 4: Acceder a Data Memory

La nueva memoria recibe:

```text
A = 10008
```

y busca:

```text
RAM[10008 >> 2]
```

Si en dicha posición existe:

```text
RAM[...] = 999
```

entonces:

```text
ReadData = 999
```

---

## Paso 5: Escribir en Register File

Finalmente:

```text
rd = x5
WD3 = 999
RegWrite = 1
```

Resultado:

```text
x5 = 999
```

---

# ¿Por qué Data Memory va después de la ALU?

Porque la memoria necesita conocer la dirección exacta a la cual acceder.

Dicha dirección se calcula mediante:

```text
Dirección = Registro Base + Offset
```

Por ello:

```text
Register File
↓
ALU
↓
Data Memory
```

y no al revés.

---

# Data Memory implementada

Se creó un nuevo módulo:

```verilog
module DataMemory(
    input [31:0] a,
    output [31:0] rd
);

reg [31:0] RAM[63:0];

initial
    $readmemh("data.mem", RAM);

assign rd = RAM[a[31:2]];

endmodule
```

---

# ¿Por qué `a[31:2]`?

Las palabras ocupan 4 bytes.

Las direcciones válidas son:

```text
0
4
8
12
16
20
...
```

Por ello:

```text
Dirección 12
↓
12 >> 2
↓
RAM[3]
```

---

# Primera duda importante

## ¿Por qué no conectar?

```text
ALU
↓
Data Memory
↓
Register File
```

para TODAS las instrucciones.

Porque destruiríamos `add` y `addi`.

Ejemplo:

```assembly
add x11,x9,x10
```

ALU:

```text
42
```

Si siempre pasara por memoria:

```text
RAM[42]
```

el Register File recibiría:

```text
RAM[42]
```

en vez de:

```text
42
```

---

# Nacimiento de ResultSrc

Para resolver este problema se añadió un nuevo multiplexor.

```text
           ALUResult
               │
               │0
               ▼
          ┌────────┐
ReadData ─►  MUX   ├──► Result
          └────────┘
               ▲
               │1
          ResultSrc
```

---

# ¿Qué es Result?

Result representa:

> El valor final que será escrito en el Register File.

El Register File ya no sabe de dónde proviene dicho valor.

Sólo recibe:

```text
WD3 = Result
```

---

# ¿Qué es ReadData?

ReadData es únicamente:

> La salida de Data Memory.

Cuando no se ejecuta `lw`, ReadData existe pero es ignorado.

No desaparece.

Simplemente el multiplexor no lo selecciona.

---

# Nueva señal de control: ResultSrc

Se incorporó:

```text
ResultSrc
```

al Controller.

Su función es decidir:

```text
¿Qué vuelve al Register File?
```

---

# Señales de control

## add

```text
RegWrite  = 1
ALUSrc    = 0
ResultSrc = 0
```

Resultado:

```text
RF ← ALUResult
```

---

## addi

```text
RegWrite  = 1
ALUSrc    = 1
ResultSrc = 0
```

Resultado:

```text
RF ← ALUResult
```

---

## lw

```text
RegWrite  = 1
ALUSrc    = 1
ResultSrc = 1
```

Resultado:

```text
RF ← ReadData
```

---

# Cambios realizados

## MainDecoder

Se añadió:

```text
ResultSrc
```

y el opcode:

```text
0000011
```

para reconocer `lw`.

---

## Controller

Se propagó:

```text
ResultSrc
```

hacia el exterior.

---

## Pipeline

Se creó el cable:

```verilog
wire ResultSrc;
```

y se conectó entre:

```text
Controller
↓
Datapath
```

---

## Datapath

Se añadieron:

```text
Data Memory
ResultMux
Result
ReadData
```

---

# Verificación funcional

Se utilizó:

```text
data.mem
```

con:

```text
11111111
22222222
33333333
44444444
AAAAAAAA
BBBBBBBB
CCCCCCCC
DDDDDDDD
```

y se ejecutaron instrucciones `lw`.

Resultados obtenidos:

```text
x9  = 11111111
x10 = 44444444
x11 = BBBBBBBB
```

coincidiendo exactamente con los valores esperados.

---

# Estado actual del procesador

El procesador monociclo implementa correctamente:

```assembly
add
addi
lw
```

Incluyendo:

* Program Counter
* Instruction Memory
* Register File
* Immediate Extend
* ALUSrc MUX
* ALU
* Data Memory
* ResultSrc MUX
* Controller

---

# Conclusión

La incorporación de `lw` representó un cambio conceptual importante.

La ALU dejó de producir siempre el resultado final y pasó a utilizarse también como generadora de direcciones de memoria.

Esto obligó a introducir:

```text
Data Memory
ResultSrc
ResultMux
```

para distinguir entre resultados provenientes de la ALU y resultados provenientes de memoria.

Gracias a ello, el procesador evolucionó desde un sistema capaz de realizar únicamente operaciones aritméticas hacia un procesador capaz de interactuar con memoria real.

---

# Próximo paso

Estamos literalmente a un paso de transformar este diseño en un procesador mucho más completo.

Los siguientes hitos naturales son:

```assembly
sw
beq
```

y, posteriormente,

> **transformar este procesador monociclo en un procesador segmentado (pipeline), incorporando registros IF/ID, ID/EX, EX/MEM y MEM/WB para ejecutar múltiples instrucciones simultáneamente.**

El camino hacia un pipeline funcional ya está preparado.
