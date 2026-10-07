# Nivel 15 - El nacimiento de `funct7`

Hasta ahora nuestro decoder funcionaba así:

```text
funct3
↓
AluDecoder
↓
ALUControl
↓
ALU
```

y asumíamos que:

```text
funct3 = operación exacta
```

Por ejemplo:

```text
000 → ADD
001 → SUB
010 → AND
...
```

Esto funcionaba porque nuestro objetivo inicial era aprender a conectar módulos y controlar la ALU.

---

## El problema

Al mirar una ISA real como RISC-V descubrimos algo inesperado:

```text
ADD → funct3 = 000
SUB → funct3 = 000
```

Dos instrucciones distintas compartían el mismo `funct3`.

Entonces apareció una pregunta:

> ¿Cómo puede el decoder saber si debe sumar o restar?

La respuesta fue:

> No puede.

`funct3` dejó de ser suficiente.

Nuestro primer diseño encontró su límite.

---

## Una posible solución

Podríamos haber rediseñado completamente la codificación.

Por ejemplo:

```text
funct3 = familia
funct7 = detalle
```

donde:

```text
000 = aritmética
001 = booleana
010 = comparaciones
011 = desplazamientos
...
```

y luego:

```text
funct7
↓
ADD
SUB
MUL
DIV
POTENCIA
RAÍZ
...
```

o:

```text
funct7
↓
AND
OR
XOR
NAND
NOR
...
```

Esta idea es muy poderosa porque permite crecer muchísimo.

Con solo:

```text
3 bits
```

podemos representar:

```text
2³ = 8 posibilidades
```

Pero con:

```text
3 bits + 7 bits
```

podemos representar:

```text
2¹⁰ = 1024 combinaciones
```

Es decir:

> Muy pocas familias, pero muchísimas operaciones dentro de cada familia.

---

## Entonces, ¿por qué `funct7` tiene 7 bits?

A primera vista puede parecer exagerado.

Podríamos pensar:

> ¿Por qué no usar `funct1`, `funct2` o `funct3`?

Sin embargo, los diseñadores de una ISA siempre piensan en el futuro.

Los bits son un recurso valioso.

Si algún día una familia necesita crecer, esos bits adicionales ya están disponibles.

Por eso, aunque hoy solo necesitemos distinguir:

```text
ADD
SUB
```

mañana podrían aparecer:

```text
MUL
DIV
REM
SRA
extensiones futuras
...
```

sin tener que rediseñar toda la ISA.

Por eso:

> `funct7` no representa complejidad innecesaria.

Representa capacidad de crecimiento.

Es espacio reservado para que una familia de instrucciones pueda evolucionar.

---

## Sin embargo...

Ese no es nuestro objetivo principal.

Nuestro objetivo no es diseñar una ISA nueva ni explotar las 1024 combinaciones posibles.

Nuestro objetivo es:

> Construir un procesador lo más cercano posible a RISC-V.

Por eso seguiremos la lógica de RISC-V actual.

---

## La solución que adoptaremos

No convertiremos `funct3` en una gran clasificación teórica.

En cambio, haremos una extensión mínima de nuestro diseño actual:

```text
funct3
+
funct7
↓
AluDecoder
↓
ALUControl
```

solo para resolver los casos en los que `funct3` ya no alcanza.

Por ejemplo:

```text
funct3 = 000
funct7 = 0000000
↓
ADD
```

mientras que:

```text
funct3 = 000
funct7 = 0100000
↓
SUB
```

Por primera vez veremos cómo una señal adicional cambia el comportamiento de la ALU utilizando la codificación real de RISC-V.

---

## Algo curioso

Aunque recibiremos los 7 bits completos de `funct7`, descubriremos que para las operaciones implementadas hasta ahora solamente necesitaremos observar uno de ellos.

Es decir:

> Tendremos 7 bits disponibles.

pero inicialmente utilizaremos muy pocos.

Esto nos permitirá entender posteriormente por qué muchos libros optimizan el decoder usando solamente:

```text
funct7b5
```

sin que parezca un bit mágico sacado de la nada.

---

## Nuestra meta cercana

Todavía no construiremos este decoder completo:

```text
opcode
↓
ALUOp
↓
funct3
↓
funct7
↓
ALUControl
```

Ese es prácticamente el decoder real de RISC-V y representa una meta futura.

---

## Nuestro siguiente paso

El siguiente paso será mucho más pequeño:

> Mantener nuestro decoder simple, pero introducir `funct7` para descubrir por primera vez por qué una sola señal dejó de ser suficiente.

No añadiremos complejidad porque sí.

Añadiremos una nueva señal porque nuestro diseño original encontró su primer límite.

Y así seguiremos construyendo el procesador:

No agregando cosas porque el libro las tiene.

Sino porque nuestro diseño anterior ya no puede resolver el siguiente problema.
