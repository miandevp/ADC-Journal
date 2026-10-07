# Nivel 20 - Rumbo a nuestra instrucción R (Parte 2)

En la Parte 1 descubrimos algo muy importante.

Una instrucción RISC-V no trae los valores que deben operarse.

Por ejemplo:

```text
ADD x5, x1, x2
```

no significa:

```text
5 + 6
```

Significa:

> Toma el valor almacenado en x1.
>
> Toma el valor almacenado en x2.
>
> Realiza la operación indicada.
>
> Y el resultado está destinado a x5.

Para comprender esta idea construimos un pequeño Register File educativo formado únicamente por dos registros creados manualmente:

```text
x1 = 5
x2 = 6
```

El Register File recibía:

```text
rs1
rs2
```

y devolvía:

```text
a
b
```

permitiendo que la ALU trabajara con operandos obtenidos desde registros reales en lugar de valores escritos directamente desde el testbench.

Sin embargo, aquella solución tenía una gran limitación.

Solamente conocía:

```text
x1
x2
```

y RISC-V posee:

```text
x0
x1
x2
...
x31
```

Es decir:

```text
32 registros.
```

---

# Dejando atrás nuestra memoria educativa

A partir de este nivel abandonamos nuestro pequeño Register File inventado.

Construimos un verdadero banco de registros capaz de trabajar con los 32 registros de RISC-V:

```verilog
reg [31:0] rf[31:0];
```

Visualmente:

```text
rf[0]  → x0
rf[1]  → x1
rf[2]  → x2
...
rf[31] → x31
```

Ahora el procesador ya no depende únicamente de dos registros definidos por nosotros.

Puede acceder a cualquiera de los registros indicados por la instrucción.

---

# Pensando el Register File como un archivo

Una forma muy útil de imaginar este banco de registros es como si fuera un pequeño archivo compuesto por 32 líneas.

Por ejemplo:

```text
Línea 0  → x0
Línea 1  → x1
Línea 2  → x2
...
Línea 31 → x31
```

Si el archivo contiene:

```text
Línea 5 → 0000008A
Línea 6 → 00000012
Línea 7 → 00000000
```

podemos interpretarlo como:

```text
x5 = 138
x6 = 18
x7 = 0
```

Cada línea representa el valor almacenado en un registro.

---

# Leyendo registros reales

Cuando llega una instrucción:

```text
instr[31:0]
```

el procesador extrae:

```text
rs1 = instr[19:15]
rs2 = instr[24:20]
rd  = instr[11:7]
```

Por ejemplo:

```text
rs1 = 00101
rs2 = 00110
rd  = 00111
```

significa:

```text
leer x5
leer x6
destino: x7
```

El Register File utiliza:

```text
rs1
rs2
```

para devolver:

```text
a
b
```

que posteriormente serán enviados a la ALU.

Visualmente:

```text
rs1
↓
Register File
↓
a

rs2
↓
Register File
↓
b
```

y después:

```text
a
b
↓
ALU
```

---

# Probando una instrucción real

Supongamos que nuestro Register File contiene:

```text
x5 = 138
x6 = 18
x7 = 0
```

Ejecutaremos la instrucción:

```text
ADD x7, x5, x6
```

Su representación binaria es:

```text
0000000_00110_00101_000_00111_0110011
```

Y en hexadecimal:

```text
0x006283B3
```

La instrucción realmente está diciendo:

> Toma el valor almacenado en x5.
>
> Toma el valor almacenado en x6.
>
> Súmalos.
>
> El resultado debería terminar en x7.

Por lo tanto:

```text
leer línea 5 → 138
leer línea 6 → 18
```

La ALU calcula:

```text
138 + 18 = 156
```

Y esperaríamos obtener:

```text
x7 = 156
```

o equivalentemente:

```text
x7 = 0x0000009C
```

---

# Intentando completar el ciclo

Hasta este punto nuestro procesador ya es capaz de hacer:

```text
leer registros
↓
operar
↓
obtener resultado
```

Por ello completamos el recorrido haciendo que el resultado generado por la ALU regresara nuevamente al Register File.

La idea parecía sencilla.

Ya conocíamos:

```text
rd → dónde guardar
y  → qué guardar
```

Visualmente:

```text
Register File
↓
ALU
↓
Register File
```

Parecía exactamente lo que necesitábamos.

En nuestro ejemplo:

```text
ADD x7, x5, x6
```

el procesador realiza:

```text
leer x5 → 138
leer x6 → 18
```

La ALU calcula:

```text
138 + 18 = 156
```

y el resultado termina almacenado en:

```text
x7 = 0x0000009C
```

---

# ¿Por qué no vemos cambiar el archivo?

Los valores iniciales del banco de registros fueron cargados desde:

```text
registers.mem
```

Sin embargo, durante la simulación el procesador trabaja sobre una copia interna del Register File.

Por esta razón, el archivo utilizado para inicializar la prueba permanece sin cambios, mientras que el estado real del procesador sí se actualiza.

Para comprobarlo, el testbench muestra el contenido del banco de registros al finalizar la ejecución:

```text
x5 = 0000008A
x6 = 00000012
x7 = 0000009C
```

Esto nos permite verificar que la instrucción efectivamente modificó el registro destino y que el resultado quedó almacenado correctamente durante la simulación.

---

# Lo que aún nos falta

Hasta ahora nuestro procesador ya sabe:

```text
qué operación ejecutar,
qué registros leer,
y cuál será el destino del resultado.
```

Más adelante incorporaremos dos nuevas señales que nos permitirán controlar este proceso con mayor precisión:

```text
clk
we
```

donde:

```text
clk → indicará el instante en que una escritura puede realizarse.

we → habilitará o bloqueará la actualización del registro destino.
```

Gracias a ellas podremos decidir exactamente cuándo un resultado debe almacenarse y cuándo no.

---

# Hacia dónde vamos

En esta etapa hemos construido un verdadero banco de registros RISC-V.

Hemos dejado atrás nuestros registros inventados.

Hemos aprendido a leer cualquiera de los 32 registros.

También comprobamos que el resultado producido por la ALU puede regresar al Register File y modificar el estado interno del procesador durante la simulación.

Actualmente podemos hacer:

```text
leer registros
↓
operar
↓
obtener resultado
↓
almacenar resultado
```

Y más adelante incorporaremos mecanismos que nos permitirán controlar exactamente cuándo esas actualizaciones deben producirse.

---

> Antes entregábamos números.
>
> Después entregamos instrucciones.
>
> Después construimos un verdadero banco de 32 registros.
>
> Descubrimos que una instrucción ya sabe qué registros leer y cuál será el destino del resultado.
>
> Finalmente comprobamos que el resultado generado por la ALU puede regresar al Register File y modificar el estado interno del procesador.
>
> Aunque el archivo utilizado para inicializar la simulación permanezca intacto, el banco de registros sí cambia durante la ejecución.
>
> Más adelante incorporaremos mecanismos que nos permitirán controlar exactamente cuándo esas actualizaciones deben producirse.
