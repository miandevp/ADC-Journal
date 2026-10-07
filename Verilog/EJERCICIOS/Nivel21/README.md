# Nivel 21 - Rumbo a nuestra instrucción R (Parte 3)

En la Parte 2 conseguimos algo muy importante.

Por primera vez, completamos el recorrido básico de una instrucción RISC-V utilizando un verdadero banco de registros.

Ya no trabajábamos con registros inventados ni con valores escritos manualmente desde el testbench.

Ahora el procesador era capaz de leer cualquiera de sus 32 registros, ejecutar una operación en la ALU y devolver el resultado al Register File.

Visualmente, habíamos construido el siguiente recorrido:

```text
Register File
↓
a, b
↓
ALU
↓
y
↓
Register File
```

Además, comprobamos mediante la simulación que el estado interno del banco de registros sí cambiaba durante la ejecución.

Por ejemplo, partiendo del estado:

```text
x5 = 0000008A
x6 = 00000012
x7 = 00000000
```

ejecutamos la instrucción:

```text
ADD x7, x5, x6
```

cuya representación binaria era:

```text
0000000_00110_00101_000_00111_0110011
```

y en hexadecimal:

```text
0x006283B3
```

El procesador interpretó dicha instrucción como:

> Lee el valor almacenado en x5.
>
> Lee el valor almacenado en x6.
>
> Suma ambos valores.
>
> Guarda el resultado en x7.

Por lo tanto:

```text
138 + 18 = 156
```

y el estado final observado fue:

```text
x5 = 0000008A
x6 = 00000012
x7 = 0000009C
```

demostrando que el resultado producido por la ALU efectivamente regresó al banco de registros.

---

# Más allá de guardar un resultado

Hasta ahora nuestro procesador ya sabe:

```text
qué operación ejecutar,
qué registros leer,
qué resultado producir,
y dónde debe almacenarlo.
```

Sin embargo, todavía existe una pregunta importante.

> Si el procesador ya sabe qué valor guardar y en qué registro debe hacerlo,
>
> ¿cómo decide exactamente cuándo debe realizar esa actualización?

No todas las instrucciones deben modificar el Register File.

Por ejemplo:

```text
ADD
SUB
AND
OR
```

sí producen un resultado que debe almacenarse.

Pero otras instrucciones no deberían alterar el contenido de ningún registro.

Además, incluso cuando una escritura está permitida, es necesario definir el instante exacto en que esa actualización ocurrirá.

---

# Introduciendo nuevas señales de control

Para resolver este problema incorporaremos dos nuevas señales:

```text
clk
we
```

donde:

```text
clk → indicará el instante en que una actualización puede realizarse.

we → habilitará o bloqueará la escritura sobre el registro destino.
```

Gracias a ellas, el procesador no solamente sabrá:

```text
qué hacer,
y dónde hacerlo,
```

sino también:

```text
cuándo hacerlo,
y cuándo no hacerlo.
```

Estas señales no cambian el recorrido fundamental que ya hemos construido.

El resultado seguirá viajando desde la ALU hasta el Register File.

La diferencia es que ahora podremos controlar exactamente cuándo esa copia debe producirse.

---

# Hacia dónde vamos

En esta etapa ya hemos comprobado que una instrucción RISC-V puede modificar el estado interno del banco de registros.

El siguiente paso consiste en incorporar mecanismos de control que permitan decidir con precisión cuándo una actualización está autorizada y cuándo debe impedirse.

De esta manera, nuestro pequeño datapath comenzará a comportarse cada vez más como un procesador real.

---

> Antes entregábamos números.
>
> Después entregamos instrucciones.
>
> Luego construimos un verdadero banco de 32 registros.
>
> Conseguimos que el resultado generado por la ALU regresara al Register File y modificara el estado interno del procesador.
>
> Ahora aprenderemos que un procesador no solo debe saber qué hacer y dónde hacerlo.
>
> También debe saber exactamente cuándo está permitido hacerlo.
V