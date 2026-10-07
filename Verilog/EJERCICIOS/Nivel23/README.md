# Nivel 23 - La creación del Program Counter (Parte 2)

En los niveles anteriores nuestro pequeño procesador RISC-V ha recorrido un camino sorprendente.

Primero dejamos de entregar números directamente a la ALU.

Después dejamos de enviar operandos manualmente y aprendimos a obtenerlos desde el Register File utilizando:

```text
rs1
rs2
rd
```

Más adelante descubrimos que tampoco era necesario escribir esos registros desde el testbench.

Bastaba con enviar una instrucción completa, porque ella misma contenía toda la información necesaria para localizar los registros correctos.

Posteriormente dimos otro paso importante.

Dejamos incluso de entregar la instrucción desde el testbench.

Creamos una memoria de instrucciones y enseñamos a nuestro procesador a buscar por sí mismo la primera línea del programa utilizando:

```text
PC = 00000000
↓
Instruction Memory
↓
instr
↓
MiniDatapath
```

Y comprobamos que seguía funcionando correctamente.

Sin embargo, apareció una nueva pregunta.

> Muy bien.
>
> Ya sabemos encontrar la primera instrucción.
>
> ¿Pero cómo encontramos la segunda?
>
> ¿Y la tercera?
>
> ¿Y todas las demás?

---

# El problema de recordar dónde estamos

Hasta ese momento utilizábamos algo tan simple como:

```text
PC = 00000000
```

Pero ese valor seguía siendo entregado manualmente.

El problema es evidente.

Si queremos hacer:

```text
PC = PC + 4
```

debemos responder primero otra pregunta.

> ¿Dónde está guardado ese PC?

Si simplemente escribimos:

```text
00000000
```

no existe ningún lugar donde recordar ese valor.

Y si no recordamos cuánto valía antes, tampoco sabremos cuánto debemos sumarle.

Necesitamos un registro.

Necesitamos un verdadero Program Counter.

---

# Nace el verdadero Program Counter

A partir de este momento el Program Counter deja de ser un número escrito desde el testbench.

Ahora pasa a formar parte del propio procesador.

Creamos un módulo encargado de almacenar la dirección actual del programa.

Visualmente:

```text
Program Counter Register
↓
PC
↓
Instruction Memory
↓
instr
↓
MiniDatapath
```

Su función es muy sencilla.

Guardar el valor actual del PC y conservarlo hasta que llegue el momento de actualizarlo.

Por ejemplo:

```text
PC = 00000000
```

y mantenerlo disponible para el siguiente ciclo.

---

# Enseñando al procesador a avanzar

Una vez que existe un lugar donde guardar el PC, podemos calcular:

```text
PC + 4
```

Creamos entonces otro pequeño módulo encargado únicamente de realizar esta operación.

Por ejemplo:

```text
00000000 + 4 = 00000004
```

Después:

```text
00000004 + 4 = 00000008
```

Luego:

```text
00000008 + 4 = 0000000C
```

y así sucesivamente.

Visualmente:

```text
PC Register
↓
PC
↓
Instruction Memory
↓
MiniDatapath
↓
PCPlus4
↓
PCNext
↓
Program Counter Register
```

Por primera vez, nuestro pequeño RISC-V comenzó a recorrer automáticamente un programa.

---

# Modificando nuestro MiniDatapath

Para conseguirlo tuvimos que modificar nuestro módulo estructural.

Originalmente recibía directamente una instrucción:

```text
instr
↓
MiniDatapath
```

Ahora el MiniDatapath envuelve varios componentes:

```text
Program Counter
↓
Instruction Memory
↓
instr
↓
Main Decoder
↓
ALU Decoder
↓
Register File
↓
ALU
↓
Write Back
↓
PCPlus4
↓
Program Counter
```

De esta manera el procesador ya no depende del testbench para decidir qué instrucción ejecutar.

Es él mismo quien va recorriendo la memoria.

---

# Ejecutando un pequeño programa real

Para comprobar que todo funcionaba correctamente preparamos una memoria con cinco instrucciones R-Type.

Recordemos que una instrucción R-Type toma dos registros fuente y almacena el resultado en un tercer registro.

Visualmente:

```text
rd = rs1 OP rs2
```

Utilizamos registros previamente inicializados como:

```text
x5 = 0000008A
x6 = 00000012

x1 = 0000000A
x2 = 00000005

x3 = 7FFFFFFF
x4 = 00000001
```

Y ejecutamos una pequeña secuencia de instrucciones.

---

# Programa ejecutado

Primera instrucción:

```assembly
ADD x7, x5, x6
```

Equivalente a:

```text
138 + 18 = 156
```

Resultado esperado:

```text
x7 = 0000009C
```

---

Segunda instrucción:

```assembly
SUB x8, x1, x2
```

Equivalente a:

```text
10 - 5 = 5
```

Resultado esperado:

```text
x8 = 00000005
```

---

Tercera instrucción:

```assembly
SUB x5, x2, x2
```

Equivalente a:

```text
5 - 5 = 0
```

Resultado esperado:

```text
zero = 1
```

---

Cuarta instrucción:

```assembly
ADD x5, x3, x4
```

Equivalente a:

```text
7FFFFFFF + 00000001
```

Resultado esperado:

```text
overflow = 1
```

y:

```text
x5 = 80000000
```

---

Quinta instrucción:

```assembly
SUB x6, x3, x4
```

Equivalente a:

```text
7FFFFFFF - 00000001
```

Resultado esperado:

```text
x6 = 7FFFFFFE
```

---

# Comprobando los resultados

Al finalizar la simulación, el testbench mostró:

```text
x5 = 80000000
x6 = 7FFFFFFE
x7 = 0000009C
x8 = 00000005

PC = 00000014
```

exactamente los valores esperados.

Esto demuestra que el procesador fue capaz de:

```text
leer instrucciones,
decodificarlas,
leer registros,
ejecutar operaciones,
guardar resultados,
y avanzar automáticamente por el programa.
```

---

# Lo que mostraron nuestras Waveforms

Además de la consola, las formas de onda también validaron el comportamiento del procesador.

Pudimos observar cómo:

```text
zero = 1
```

cuando una operación produjo un resultado igual a cero.

Y también cómo:

```text
overflow = 1
```

cuando una suma excedió el rango representable.

Por primera vez vimos señales de estado generadas a partir de datos reales obtenidos desde registros del propio procesador.

---

# ¿Y cuándo se detiene?

Una pregunta muy natural es:

> Si el Program Counter seguirá haciendo:
>
> PC = PC + 4
>
> ¿cómo sabe el procesador cuándo debe detenerse?

Por el momento será el propio testbench quien finalice la simulación mediante:

```verilog
$finish;
```

Sin embargo, un procesador real normalmente no "se detiene".

Muchas veces simplemente continúa ejecutando instrucciones indefinidamente.

Por ejemplo:

```assembly
loop:
    j loop
```

Visualmente:

```text
...
↓
última instrucción útil
↓
j loop
↓
j loop
↓
j loop
↓
...
```

Desde fuera parece haberse detenido.

Pero en realidad continúa trabajando.

Más adelante implementaremos instrucciones de salto y comprenderemos cómo un procesador modifica el flujo normal del Program Counter.

---

# Lo que hemos construido

Puede parecer pequeño.

Pero en realidad acabamos de construir el comportamiento esencial de un procesador RISC-V monociclo capaz de ejecutar instrucciones R-Type.

Nuestro procesador ya sabe:

```text
buscar instrucciones,
decodificarlas,
leer registros,
ejecutar operaciones,
actualizar registros,
detectar zero,
detectar overflow,
recordar dónde está,
y avanzar automáticamente por un programa.
```

Incluso hemos comprobado que no importa si existen cinco instrucciones o muchas más.

El comportamiento es el mismo.

Un programa escrito por un programador puede convertirse en instrucciones máquina almacenadas en memoria.

Y el procesador simplemente las recorrerá una tras otra.

---

# Hacia dónde vamos

Durante mucho tiempo nuestro objetivo fue construir correctamente una instrucción R-Type.

Hoy podemos decir que hemos completado ese recorrido básico.

Tenemos un pequeño RISC-V funcional.

Y precisamente porque ahora entendemos el flujo completo:

```text
PC
↓
Instruction Memory
↓
Decode
↓
Register File
↓
ALU
↓
Write Back
↓
PC + 4
```

ya estamos preparados para el siguiente gran paso.

Dividir este recorrido en etapas.

Y comenzar finalmente nuestro camino hacia el pipeline.

---

> Primero dejamos de entregar números.
>
> Después dejamos de entregar operandos.
>
> Luego dejamos de entregar instrucciones.
>
> Enseñamos a nuestro procesador a encontrar su programa.
>
> Después le enseñamos a recordar dónde estaba y a avanzar por sí mismo.
>
> Y tras validar todo el recorrido mediante registros reales, señales de estado y programas completos, finalmente tenemos la base necesaria para comenzar a pensar como un verdadero procesador segmentado.
>
> El siguiente paso ya no será preguntarnos qué hace una instrucción R-Type.
>
> Sino cómo lograr que muchas instrucciones avancen al mismo tiempo.
