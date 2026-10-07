# Nivel 18 - Nacimiento de nuestro Main Controller: identificador del tipo de instrucción

Hasta ahora, nuestra pequeña construcción de procesador tenía dos protagonistas.

## ALU

La **ALU** es la encargada de realizar el trabajo matemático y lógico. Ella sabe hacer operaciones como:

```text
ADD  → suma
SUB  → resta
AND
OR
XOR
SLT
SLL
SRL
```

Sin embargo, la ALU no toma decisiones.

Ella no sabe cuándo debe sumar ni cuándo debe restar.

Simplemente obedece.

---

## ALU Decoder

Entonces apareció el **ALU Decoder**.

Su trabajo es traducir cierta información de la instrucción para decirle a la ALU qué operación exacta debe ejecutar.

Por ejemplo:

```text
funct3
funct7b5
opb5
↓
ALU Decoder
↓
ALUControl
↓
ALU
```

Gracias a él, la ALU dejó de recibir un selector manual desde el testbench y comenzó a comportarse más como parte de un procesador real.

Pero aquí surge una nueva pregunta:

> ¿Quién le dice al ALU Decoder cuándo debe decidir una operación exacta y cuándo simplemente debe ordenar una suma o una resta?

Necesitamos algo más grande.

Necesitamos un cerebro.

---

# Nacimiento de nuestro Main Controller

El **Main Controller** será el encargado de identificar qué tipo de instrucción estamos ejecutando.

Ya no piensa únicamente en operaciones de la ALU.

Piensa en toda la instrucción.

En un procesador RISC-V existen muchos tipos de instrucciones:

```text
R-type
I-type
S-type
B-type
U-type
J-type
```

Cada una tiene un propósito distinto.

Algunas escriben registros.

Otras leen memoria.

Otras almacenan datos.

Otras realizan saltos.

Y muchas utilizan la ALU de maneras diferentes.

Por eso necesitamos un módulo que, al observar la instrucción, pueda decir:

> "Esta es una suma entre registros."

> "Esta es una suma inmediata."

> "Esta instrucción es un branch."

> "Esta instrucción quiere escribir en memoria."

> "Esta instrucción es un salto."

Ese módulo será nuestro Main Controller.

---

# El opcode: la pista principal

Para tomar esas decisiones utilizaremos el:

```text
opcode
```

El opcode ocupa:

```text
7 bits
```

Es decir:

```text
opcode[6:0]
```

Siete bits permiten representar muchas combinaciones diferentes.

```text
2^7 = 128 posibilidades
```

Sin embargo, nuestro pequeño procesador no implementará las 128.

Solo reconocerá algunas de ellas.

---

# No implementaremos todo de una vez

Aunque conocemos opcodes como:

```text
lw
sw
beq
jal
...
```

todavía no tiene sentido utilizarlos.

Nuestro MiniDatapath aún no posee:

```text
Memoria
Register File
Immediate Generator
PC
Saltos
MUXes
```

Por lo tanto, seguimos siendo fieles a nuestra filosofía:

> No añadiremos funcionalidades que todavía no existen.

Por ahora, nuestro Main Controller únicamente reconocerá:

```text
R-type
I-type ALU
```

No porque sean las únicas instrucciones de RISC-V.

Sino porque son las únicas que nuestro pequeño procesador realmente puede ejecutar en este momento.

Esto nos permite demostrar que el Main Controller ya puede observar un opcode y clasificar el tipo de instrucción, aunque todavía no utilicemos todo el potencial del procesador.

Por ejemplo:

```text
opcode = 0110011 → R-type
opcode = 0010011 → I-type ALU
```

---

# Una nueva conexión: ALUOp deja de venir del testbench

Antes hacíamos algo parecido a esto:

```text
Testbench
↓
ALUOp
↓
ALU Decoder
↓
ALU
```

El testbench decidía manualmente:

```text
ALUOp = 10
```

Pero ahora eso cambia.

Creamos un cable dentro de nuestro módulo estructural:

```text
wire [1:0] ALUOp;
```

y conectamos:

```text
Main Controller
↓
ALUOp
↓
ALU Decoder
```

De la misma forma que anteriormente conectamos:

```text
ALU Decoder
↓
ALUControl
↓
ALU
```

Ahora aprendemos una nueva habilidad:

> conectar módulos funcionales mediante señales internas (`wire`).

---

# Nuestro MiniDatapath continúa creciendo

Nuestro MiniDatapath es un módulo estructural.

Su trabajo no es calcular ni decidir.

Su trabajo es conectar.

Y conforme avanzamos de nivel, irá expandiéndose poco a poco.

Hoy contiene:

```text
Main Controller
ALU Decoder
ALU
```

Más adelante podrá contener:

```text
Register File
Immediate Generator
MUXes
Memorias
PC
...
```

No construiremos todo desde el principio.

Iremos agregando únicamente aquello que realmente sea necesario.

Por eso es importante acostumbrarnos desde ahora a una habilidad fundamental del diseño digital:

> saber crear y conectar cables (`wire`) entre módulos funcionales.

Porque la estructura del procesador crecerá nivel tras nivel.

Y esos cables serán los que permitan que todos sus componentes trabajen juntos.

---

# Nuestra filosofía de construcción

```text
Nivel 13 → ALU
Nivel 14 → ALU Decoder
Nivel 15 → funct7
Nivel 16 → funct7b5
Nivel 17 → opb5 y RtypeSub
Nivel 18 → Main Controller
```

Primero aprendimos a hacer operaciones.

Luego aprendimos a decidir qué operación ejecutar.

Ahora aprendimos a reconocer qué tipo de instrucción estamos recibiendo.

Y más adelante ese mismo cerebro será capaz de generar señales como:

```text
ALUOp
RegWrite
MemWrite
ALUSrc
Branch
Jump
ResultSrc
ImmSrc
...
```

Hasta convertirse en el verdadero coordinador de nuestro procesador.

---

> La ALU es el trabajador.
>
> El ALU Decoder es el traductor de operaciones.
>
> El Main Controller es el cerebro que comienza a reconocer qué quiere hacer cada instrucción.
>
> Y el opcode es la primera pista que le permite identificarlas.

Este es el momento en que nuestro proyecto deja de parecer una simple calculadora programable y comienza a convertirse, poco a poco, en un verdadero procesador RISC-V.
