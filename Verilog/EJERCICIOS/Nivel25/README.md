# Nivel 25 - Nuestro primer I-Type: cuando los registros dejaron de ser suficientes

Hasta este punto nuestro pequeño RISC-V solamente sabía hacer una cosa.

Tomar datos desde registros.

Todas las instrucciones que habíamos construido seguían exactamente la misma idea:

```text
registro + registro
```

Por ejemplo:

```assembly
add x7, x5, x6
sub x8, x1, x2
```

Visualmente, nuestro Datapath era muy sencillo.

```text
Register File
↓       ↓
a       b
 \     /
  \   /
   ALU
    ↓
    y
```

La ALU siempre recibía dos operandos provenientes del Register File.

Y durante muchos niveles eso fue suficiente.

Gracias a ello comprendimos cómo funcionan las instrucciones R-Type.

Construimos un Register File.

Aprendimos a leer registros.

Aprendimos a escribir resultados.

Construimos un Program Counter.

Y finalmente fuimos capaces de ejecutar programas reales formados por varias instrucciones.

Sin embargo, hay algo muy importante que quizá pasó desapercibido.

---

# La ALU nunca recibió rs1 ni rs2

Cuando observábamos una instrucción R-Type como:

```assembly
add x7, x5, x6
```

podríamos pensar que la ALU recibía directamente:

```text
rs1
rs2
```

o incluso:

```text
rs1 = 00101
rs2 = 00110
```

Pero eso nunca ocurrió.

De hecho, esos campos tienen solamente:

```text
5 bits
```

porque su único trabajo consiste en identificar cuál de los 32 registros queremos utilizar.

Con 5 bits podemos representar:

```text
2⁵ = 32
```

es decir:

```text
x0
x1
x2
...
x31
```

Los 5 bits no eran operandos.

Eran direcciones.

Eran índices.

Eran referencias para localizar un registro concreto dentro del Register File.

Por ejemplo:

```assembly
add x7, x5, x6
```

hacía algo parecido a esto:

```text
rs1 = 00101
↓
buscar x5
↓
obtener 32 bits

rs2 = 00110
↓
buscar x6
↓
obtener 32 bits
```

Y solamente después de esa lectura la ALU recibía:

```text
a : 32 bits
b : 32 bits
```

Es decir:

> Incluso en R-Type la ALU siempre trabajó con operandos de 32 bits.

Nunca sumó números de 5 bits.

---

# Pero ahora queremos hacer algo distinto

Los programas reales hacen algo mucho más interesante.

Muchas veces no queremos sumar dos registros.

Queremos sumar un registro con un número.

Por ejemplo:

```assembly
addi x5, x5, 10
```

que significa:

> Toma el valor almacenado en x5, súmale 10 y guarda el resultado nuevamente en x5.

Y aquí ocurre algo completamente nuevo.

Por primera vez uno de los operandos ya no proviene del Register File.

Proviene de la propia instrucción.

---

# El nacimiento del formato I

RISC-V utiliza para ello un nuevo formato.

El formato I.

Visualmente:

```text
31          20 19   15 14  12 11    7 6      0
┌────────────┬───────┬──────┬────────┬────────┐
│ imm[11:0]  │  rs1  │funct3│   rd   │ opcode │
└────────────┴───────┴──────┴────────┴────────┘
```

Mientras que R-Type funcionaba como:

```text
rs1 + rs2 → rd
```

I-Type funcionará como:

```text
rs1 + inmediato → rd
```

Ahora surge una pregunta natural.

---

# ¿Por qué solamente 12 bits?

Si observamos el formato I descubrimos algo curioso.

El número inmediato ocupa únicamente:

```text
12 bits
```

Porque el espacio dentro de una instrucción es limitado.

Dentro de los 32 bits debemos almacenar:

```text
opcode
rd
funct3
rs1
inmediato
```

Y después de acomodar todos esos campos solamente quedan disponibles:

```text
12 bits
```

para representar un número.

Y aunque pueda parecer poco, resulta suficiente para muchísimas operaciones cotidianas.

Pero entonces aparece un problema.

---

# Nuestra ALU habla otro idioma

Nuestra ALU fue diseñada para trabajar con:

```text
32 bits
```

Hasta ahora eso no suponía ningún inconveniente.

El Register File convertía direcciones de 5 bits en valores reales de 32 bits.

```text
rs1 (5 bits)
↓
Register File
↓
a (32 bits)

rs2 (5 bits)
↓
Register File
↓
b (32 bits)
```

Sin embargo, el inmediato que acabamos de obtener desde la instrucción tiene solamente:

```text
12 bits
```

Entonces surge una pregunta inevitable.

> ¿Cómo sumamos un operando de 32 bits con otro de solamente 12 bits?

Necesitamos traducir ese número al idioma que entiende el resto del procesador.

---

# Immediate Generator

Para resolver este problema construiremos un nuevo bloque.

```text
Instruction
↓
Immediate Generator
↓
ImmExt
```

Su trabajo será muy sencillo.

Tomará el inmediato almacenado en:

```text
instr[31:20]
```

y lo convertirá en un verdadero operando de 32 bits.

Visualmente:

```text
12 bits
↓
Sign Extend
↓
32 bits
```

Ahora la ALU podrá operar normalmente.

---

# El Sign Extend

Pero aún queda una pregunta.

¿Qué hacemos con los 20 bits que faltan?

La respuesta es copiar el bit de signo.

Si el inmediato es positivo:

```text
000000001100
```

obtendremos:

```text
00000000000000000000000000001100
```

Pero si el inmediato representa un número negativo:

```text
111111111111
```

obtendremos:

```text
11111111111111111111111111111111
```

De esta manera el significado matemático del número se conserva.

El procesador sigue viendo exactamente el mismo valor.

Simplemente expresado utilizando 32 bits.

---

# Pero acabamos de crear un nuevo problema

Hasta este momento la entrada B de la ALU siempre provenía del Register File.

```text
b ← rs2
```

Sin embargo, ahora tenemos dos posibilidades.

```text
b ← rs2

o

b ← ImmExt
```

Entonces surge una nueva pregunta.

> ¿Quién decide cuál de los dos operandos debemos utilizar?

Y aquí aparece una nueva pieza.

---

# Un multiplexor para elegir

Agregaremos un MUX antes de la entrada B de la ALU.

```text
                 rs2
                  │
                  ▼
               ┌─────┐
ImmExt ───────►│ MUX │────► ALU
               └─────┘
```

Ahora la ALU seguirá recibiendo dos operandos de 32 bits.

Pero uno de ellos podrá provenir de distintas fuentes.

Por primera vez nuestro Datapath deberá elegir un camino.

---

# El Controller aprende una nueva decisión

Nuestro Controller ya sabía responder preguntas como:

```text
¿Debemos escribir en un registro?

¿Qué operación realizará la ALU?
```

Ahora aprenderá algo más.

```text
¿De dónde debe provenir el segundo operando?
```

Para ello introduciremos una nueva señal:

```text
ALUSrc
```

que significa:

```text
ALUSrc = 0 → usar rs2
ALUSrc = 1 → usar ImmExt
```

Por primera vez el cerebro del procesador no solamente decidirá qué operación realizar.

También decidirá cuál será el origen de uno de los operandos.

---

# Un pequeño paquete de control

Hasta este momento nuestro Main Decoder generaba señales individuales.

Por ejemplo:

```text
RegWrite
AluOp
```

Sin embargo, conforme el procesador comienza a crecer, resulta más cómodo agruparlas.

Después de todo, el Controller está tomando varias decisiones al mismo tiempo.

Ahora nuestro pequeño paquete de control será:

```text
{RegWrite, ALUSrc, AluOp}
```

Cada instrucción activará una combinación distinta.

Por ejemplo, para una instrucción R-Type:

```text
{RegWrite, ALUSrc, AluOp}

1          0        10
```

lo que significa:

```text
escribir registro
usar rs2
dejar que ALU Decoder decida ADD o SUB
```

Mientras que para:

```assembly
addi
```

obtendremos:

```text
{RegWrite, ALUSrc, AluOp}

1          1        10
```

que significa:

```text
escribir registro
usar ImmExt
dejar que ALU Decoder genere la operación adecuada
```

Puede parecer un cambio pequeño.

Pero representa el nacimiento de algo muy importante.

El Controller deja de generar señales aisladas.

Y comienza a enviar verdaderos paquetes de decisiones al Datapath.

Una idea que seguirá creciendo conforme aparezcan nuevas instrucciones.

---

# De `a`, `b` y `y` a `SrcA`, `SrcB` y `AluResult`

Hasta este momento habíamos utilizado nombres muy sencillos.

```text
a
b
y
```

Y tenían mucho sentido.

Sin embargo, acabamos de modificar nuestro procesador.

El segundo operando ya no siempre proviene del mismo lugar.

Por ello cambiaremos nuestra nomenclatura.

```text
a → SrcA
b → SrcB
y → AluResult
```

Porque ya no estamos hablando de simples cables.

Estamos hablando de recursos que pueden provenir de distintas fuentes.

Actualmente:

```text
SrcA ← Register File

SrcB ← Register File
      o
      Immediate Generator
```

Y en el futuro podrán provenir de muchos otros lugares.

Por ejemplo:

```text
Register File
Immediate Generator
Program Counter
Forwarding Unit
Memoria
```

Lo importante dejará de ser dónde nacieron originalmente los datos.

Lo importante será:

> ¿Cuál fue finalmente el recurso seleccionado para llegar a la ALU?

---

# Hacia dónde vamos

Hoy nuestro pequeño RISC-V dejará de vivir únicamente en el mundo de:

```text
registro + registro
```

para descubrir un nuevo universo.

```text
registro + número
```

Construiremos nuestro primer formato I.

Crearemos nuestro Immediate Generator.

Aprenderemos el funcionamiento del Sign Extend.

Incorporaremos un multiplexor para seleccionar el origen de los operandos.

Permitiremos que el Controller envíe pequeños paquetes de decisiones hacia el Datapath.

Y comenzaremos a pensar en recursos seleccionados dinámicamente en lugar de simples cables fijos.

Porque antes de utilizar inmediatos para calcular direcciones de memoria con instrucciones como `lw`, primero debemos aprender a convertirlos en verdaderos operandos del procesador.

Y ese será precisamente el objetivo de este nivel.

Enseñarle a nuestro pequeño RISC-V que no todos los datos nacen en un registro.
