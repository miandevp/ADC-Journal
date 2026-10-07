# Nivel 22 - La creación del Program Counter (Parte 1)

Hasta ahora nuestro pequeño procesador RISC-V ha recorrido un largo camino.

Primero dejamos de entregar números directamente a la ALU.

Después dejamos de entregar operandos manualmente y aprendimos a obtenerlos desde el Register File utilizando:

```text
rs1
rs2
rd
```

Más adelante descubrimos que tampoco era necesario escribir manualmente los operandos desde el testbench.

Bastaba con enviar una instrucción completa, ya que ella misma contenía la información necesaria para localizar los registros correctos.

Sin embargo, todavía seguíamos haciendo algo manual.

Nuestro testbench continuaba diciendo explícitamente qué instrucción debía ejecutarse:

```text
instr = 0x006283B3
```

Es decir, habíamos dejado de entregar operandos, pero seguíamos entregando instrucciones.

Y entonces aparece una nueva pregunta.

> Si conseguimos que el procesador obtenga por sí solo los operandos,
>
> ¿podremos conseguir también que obtenga por sí solo las instrucciones?

La respuesta es sí.

---

# Pensando como un programa real

Cuando escribimos un programa normalmente hacemos algo parecido a:

```c
x7 = x5 + x6;
x8 = x7 - x6;
x9 = x8 | x5;
```

Nosotros escribimos código.

Después, herramientas como el ensamblador convierten ese programa en instrucciones máquina:

```text
006283B3
40638433
005464B3
...
```

Y el procesador únicamente ve eso:

```text
una lista de instrucciones codificadas.
```

Sin embargo, si existe una lista de instrucciones, surge una nueva duda.

> ¿Cómo sabe el procesador cuál de todas debe ejecutar?

---

# Nace una nueva necesidad

Supongamos que tenemos una memoria de instrucciones:

```text
Línea 0 → 006283B3
Línea 1 → 40638433
Línea 2 → 005464B3
...
```

Alguien debe indicar qué línea debe leerse.

Necesitamos un pequeño componente capaz de recordar en qué parte del programa nos encontramos.

Un componente que diga:

```text
Estoy aquí.
```

Ese componente se llama:

```text
Program Counter (PC)
```

---

# Adaptando nuestro MiniDatapath

Para que el procesador pudiera obtener instrucciones desde memoria tuvimos que modificar nuestro módulo estructural.

Hasta este momento, nuestro MiniDatapath recibía directamente una instrucción desde el exterior:

```text
instr
↓
MiniDatapath
```

Ahora cambiamos sus conexiones para que su entrada dejara de ser la instrucción completa.

En su lugar, la nueva entrada pasó a ser:

```text
PC
```

A partir de ese valor, el propio MiniDatapath consulta una nueva memoria dedicada exclusivamente a almacenar instrucciones:

```text
PC
↓
Instruction Memory
↓
instr
↓
MiniDatapath
```

Para ello creamos un nuevo archivo:

```text
instructions.mem
```

encargado de guardar el programa que ejecutará nuestro procesador.

---

# El primer paso del Program Counter

En esta primera parte no construiremos todavía un contador que avance automáticamente.

Nuestro objetivo será mucho más sencillo.

Utilizaremos un Program Counter con el valor:

```text
PC = 0
```

para apuntar a la primera instrucción almacenada en memoria.

En nuestro caso, dicha memoria contiene únicamente:

```text
Línea 0 → 006283B3
```

que corresponde a:

```text
ADD x7, x5, x6
```

Como el Program Counter vale:

```text
00000000
```

solamente leerá esa primera línea.

Visualmente:

```text
PC = 0
↓
Instruction Memory
↓
Línea 0
↓
006283B3
↓
ADD x7, x5, x6
↓
MiniDatapath
```

Por lo tanto, aunque el procesador siga ejecutando una sola instrucción, ya no será el testbench quien la entregue directamente.

Será el propio procesador quien irá a buscarla.

---

# Probando que realmente funciona

El estado inicial de nuestro Register File era:

```text
x5 = 0x0000008A
x6 = 0x00000012
x7 = 0x00000000
```

Desde el testbench únicamente enviamos:

```text
PC = 0
```

El resto del trabajo fue realizado por el propio procesador:

```text
PC
↓
Instruction Memory
↓
instr
↓
MiniDatapath
↓
Register File
↓
ALU
↓
Register File
```

Para comprobarlo utilizamos:

```verilog
$display(...)
```

y observamos en consola:

```text
x5 = 0000008A
x6 = 00000012
x7 = 0000009C
```

confirmando que:

```text
138 + 18 = 156
```

y que el resultado fue almacenado correctamente en:

```text
x7 = 0x0000009C
```

De esta manera demostramos que, aun enviando únicamente:

```text
00000000
```

como valor del Program Counter, el procesador fue capaz de localizar la instrucción adecuada, ejecutarla y actualizar correctamente sus registros.

---

# Hacia dónde vamos

En esta etapa ha nacido el Program Counter.

Por el momento permanece apuntando únicamente a la primera instrucción del programa.

El siguiente paso será incorporar lógica secuencial para que pueda avanzar automáticamente:

```text
PC = PC + 4
```

permitiéndole recorrer el programa instrucción tras instrucción.

Una vez que ese recorrido funcione correctamente, habremos construido el camino natural que posteriormente dividiremos en etapas para dar origen a nuestro pipeline.

---

> Primero dejamos de entregar números.
>
> Después dejamos de entregar operandos.
>
> Luego dejamos de entregar instrucciones.
>
> Ahora hemos enseñado a nuestro procesador a encontrar por sí mismo la primera línea de su programa.
>
> Lo siguiente será enseñarle a avanzar, recorriendo el programa una instrucción a la vez.
