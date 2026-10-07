# README - Evolución de la ALU y siguiente actualización

## Estado actual

La ALU ya es capaz de realizar:

* ADD
* SUB
* AND
* OR
* SLT
* Detectar ZERO
* Detectar OVERFLOW

y utiliza un único sumador para las operaciones aritméticas.

---

# Evolución de la ALU

## Nivel 1: Suma

Comenzamos con:

```verilog
y = a + b;
```

La ALU únicamente sumaba.

---

## Nivel 2: Resta

Agregamos:

```verilog
y = a - b;
```

Todavía usando operadores de Verilog.

---

## Nivel 3: Operaciones lógicas

Se añadieron:

```verilog
y = a & b;
y = a | b;
```

La ALU comenzó a soportar múltiples operaciones.

---

## Nivel 4: Uso de case

Se reemplazó la cadena de if por:

```verilog
case(sel)
    ...
endcase
```

haciendo la selección de operaciones más clara.

---

## Nivel 5: Un único sumador

Se descubrió que:

```text
A - B = A + (~B + 1)
```

Por lo tanto, no era necesario un restador independiente.

Se introdujeron:

```verilog
condinvb
sum
```

para reutilizar el mismo sumador.

---

## Nivel 6: Señal Zero

Se añadió:

```verilog
assign zero = (y == 0);
```

permitiendo detectar resultados iguales a cero.

Esto es útil para instrucciones como BEQ.

---

## Nivel 7: Primer SLT

Se implementó:

```verilog
if(a < b)
    y = 1;
else
    y = 0;
```

Funcionaba correctamente, pero Verilog estaba ocultando el hardware real.

---

## Nivel 8: SLT usando la resta

Se eliminó el operador "<".

Se utilizó:

```text
A < B
↓
A - B
↓
Si el resultado es negativo
↓
A < B
```

implementando:

```verilog
if(sum[31])
    y = 1;
else
    y = 0;
```

---

## Nivel 9: Descubrimiento del problema

Se probó:

```text
2147483647 < -1
```

y la ALU respondió incorrectamente.

Se descubrió que:

```text
sum[31]
```

puede mentir cuando ocurre overflow.

---

## Nivel 10: Overflow explícito

Se implementaron dos señales.

### Overflow para suma

```verilog
assign v_add =
    ((a[31]==0)&&(b[31]==0)&&(sum[31]==1)) ||
    ((a[31]==1)&&(b[31]==1)&&(sum[31]==0));
```

Interpretación:

```text
positivo + positivo = negativo
o
negativo + negativo = positivo
```

---

### Overflow para resta

```verilog
assign v_sub =
    ((a[31]==0)&&(b[31]==1)&&(sum[31]==1)) ||
    ((a[31]==1)&&(b[31]==0)&&(sum[31]==0));
```

Interpretación:

```text
positivo - negativo = negativo
o
negativo - positivo = positivo
```

---

## Nivel 11: Selección del overflow

Se introdujo:

```verilog
assign v =
    (sel==ADD) ? v_add :
    (sel==SUB || sel==SLT) ? v_sub :
    1'b0;
```

Interpretación:

```text
ADD → usar overflow de suma
SUB → usar overflow de resta
SLT → usar overflow de resta
otros → overflow = 0
```

---

# Estado actual del diseño

Actualmente tenemos:

```verilog
v_add
v_sub
v
```

Lo importante es que esta versión es extremadamente entendible.

Cada condición puede leerse casi como español.

La ALU funciona correctamente.

---

# README - De `v_add` y `v_sub` a una única señal `v`

## Estado actual

Actualmente tenemos:

```verilog
assign v_add =
    (a[31] == b[31]) &&
    (sum[31] != a[31]);

assign v_sub =
    (a[31] != b[31]) &&
    (sum[31] != a[31]);

assign v =
    (sel == 3'b000) ? v_add :
    (sel == 3'b001 || sel == 3'b100) ? v_sub :
    1'b0;
```

Esta versión funciona correctamente.

---

# ¿Qué significa cada una?

## v_add

```verilog
(a[31] == b[31]) &&
(sum[31] != a[31])
```

Se lee como:

```text
Los operandos tienen el mismo signo
Y
el resultado cambió de signo.
```

Ejemplos:

```text
+ + → -
- - → +
```

Eso es overflow en suma.

---

## v_sub

```verilog
(a[31] != b[31]) &&
(sum[31] != a[31])
```

Se lee como:

```text
Los operandos tienen signos distintos
Y
el resultado cambió de signo respecto a A.
```

Ejemplos:

```text
+ - → -
- + → +
```

Eso es overflow en resta.

---

# Primer paso: introducir XOR

Recordemos:

## XOR

```text
A ^ B = 0 → A y B son iguales
A ^ B = 1 → A y B son distintos
```

Tabla:

```text
A B | A^B
0 0 | 0
0 1 | 1
1 0 | 1
1 1 | 0
```

---

# Aplicándolo a v_add

Tenemos:

```verilog
(a[31] == b[31])
```

Como XOR vale 0 cuando son iguales:

```verilog
~(a[31] ^ b[31])
```

representa exactamente lo mismo.

---

También tenemos:

```verilog
(sum[31] != a[31])
```

Como XOR vale 1 cuando son distintos:

```verilog
(a[31] ^ sum[31])
```

representa exactamente lo mismo.

---

Entonces:

Antes:

```verilog
assign v_add =
    (a[31] == b[31]) &&
    (sum[31] != a[31]);
```

Después:

```verilog
assign v_add =
    ~(a[31] ^ b[31]) &
    (a[31] ^ sum[31]);
```

No cambió el comportamiento.

Solo cambiamos la forma de escribirlo.

---

# Aplicándolo a v_sub

Tenemos:

```verilog
(a[31] != b[31])
```

Como XOR vale 1 cuando son distintos:

```verilog
(a[31] ^ b[31])
```

representa exactamente lo mismo.

---

Y nuevamente:

```verilog
(sum[31] != a[31])
```

se convierte en:

```verilog
(a[31] ^ sum[31])
```

---

Entonces:

Antes:

```verilog
assign v_sub =
    (a[31] != b[31]) &&
    (sum[31] != a[31]);
```

Después:

```verilog
assign v_sub =
    (a[31] ^ b[31]) &
    (a[31] ^ sum[31]);
```

Tampoco cambió el comportamiento.

---

# Observación importante

Ahora tenemos:

Suma:

```verilog
~(a[31] ^ b[31]) &
(a[31] ^ sum[31]);
```

Resta:

```verilog
(a[31] ^ b[31]) &
(a[31] ^ sum[31]);
```

Observa que:

```text
La segunda parte es idéntica.
```

Solo cambia la primera.

---

# ¿Qué es lo único que cambia?

Suma:

```verilog
~(a[31] ^ b[31])
```

Resta:

```verilog
(a[31] ^ b[31])
```

Es decir:

```text
La diferencia es solamente un NOT.
```

---

# Haciendo desaparecer v_add y v_sub

Ya tenemos:

```verilog
assign isSub =
    (sel == 3'b001 || sel == 3'b100);
```

Entonces:

```text
isSub = 0 → suma
isSub = 1 → resta
```

La idea es usar `isSub` para decidir automáticamente si necesitamos el NOT.

---

## Si isSub = 0

Queremos:

```verilog
~(a[31] ^ b[31])
```

Veamos:

```verilog
~(0 ^ a[31] ^ b[31])
```

Como:

```text
0 ^ X = X
```

obtenemos:

```verilog
~(a[31] ^ b[31])
```

que corresponde a suma.

---

## Si isSub = 1

Queremos:

```verilog
(a[31] ^ b[31])
```

Veamos:

```verilog
~(1 ^ a[31] ^ b[31])
```

Si llamamos:

```text
X = a[31] ^ b[31]
```

entonces:

```verilog
~(1 ^ X)
```

equivale a:

```verilog
X
```

porque:

```text
1 XOR X = NOT(X)
NOT(NOT(X)) = X
```

Por lo tanto obtenemos:

```verilog
(a[31] ^ b[31])
```

que corresponde a resta.

---

# Resultado final

Podemos eliminar completamente:

```verilog
wire v_add;
wire v_sub;

assign v_add = ...;
assign v_sub = ...;

assign v =
    (sel == ...) ? ... ;
```

y reemplazar todo por:

```verilog
assign v =
    ~(isSub ^ a[31] ^ b[31]) &
    (a[31] ^ sum[31]);
```

---

# Idea principal

No inventamos una fórmula nueva.

Lo que realmente hicimos fue:

```text
v_add
↓
escribirlo con XOR

v_sub
↓
escribirlo con XOR

observar que solo diferían en un NOT
↓
usar isSub para controlar ese NOT
↓
desaparecer v_add y v_sub
↓
obtener una única señal v
```

La fórmula final es simplemente una compresión de la lógica que ya entendíamos.

# README - Actualización de SLT usando Overflow

## Estado anterior

Nuestro `slt` se implementaba utilizando la resta:

```verilog
3'b100:
    if(sum[31])
        y = 32'd1;
    else
        y = 32'd0;
```

La idea era simple:

```text
A < B
↓
A - B
↓
Si el resultado es negativo
↓
A es menor que B
```

Es decir, utilizábamos el bit de signo de la resta:

```text
sum[31]
```

como respuesta del `slt`.

---

## Problema descubierto

Probamos el siguiente caso:

```text
2147483647 < -1
```

Matemáticamente:

```text
FALSO
```

Sin embargo, la ALU hace internamente:

```text
2147483647 - (-1)
=
2147483648
```

Este número no puede representarse en 32 bits con signo.

Entonces ocurre:

```text
overflow = 1
```

y el hardware almacena:

```text
80000000
```

que parece representar:

```text
-2147483648
```

Por lo tanto:

```text
sum[31] = 1
```

y nuestro SLT antiguo concluía:

```text
2147483647 < -1
↓
verdadero
```

lo cual es incorrecto.

---

## Conclusión importante

Descubrimos que:

```text
sum[31]
```

no siempre representa el signo real del resultado.

Cuando ocurre overflow:

```text
sum[31]
```

puede mentir.

---

## Segundo caso extremo

Probamos:

```text
-2147483648 < 1
```

Matemáticamente:

```text
VERDADERO
```

La ALU realiza:

```text
-2147483648 - 1
=
-2147483649
```

Este número tampoco cabe en 32 bits.

Entonces:

```text
overflow = 1
```

y el hardware almacena:

```text
7FFFFFFF
```

que parece positivo.

Por lo tanto:

```text
sum[31] = 0
```

y el SLT antiguo concluía:

```text
-2147483648 < 1
↓
falso
```

lo cual también es incorrecto.

---

## Solución

Observamos que:

### Si no hay overflow

Podemos confiar en:

```text
sum[31]
```

---

### Si hay overflow

El signo quedó invertido.

Por lo tanto, debemos cambiarlo.

---

## Implementación

Antes:

```verilog
3'b100:
    if(sum[31])
        y = 32'd1;
    else
        y = 32'd0;
```

Ahora:

```verilog
3'b100:
    if(sum[31] ^ overflow)
        y = 32'd1;
    else
        y = 32'd0;
```

o de forma más compacta:

```verilog
3'b100:
    y = {31'd0, sum[31] ^ overflow};
```

---

## Interpretación del XOR

Tabla de verdad:

| sum[31] | overflow | Resultado |
| ------- | -------- | --------- |
| 0       | 0        | 0         |
| 1       | 0        | 1         |
| 0       | 1        | 1         |
| 1       | 1        | 0         |

Esto significa:

```text
Si no hubo overflow,
    usa sum[31].

Si hubo overflow,
    invierte sum[31].
```

---

## Idea principal

El SLT realmente funciona así:

```text
A < B
↓
A - B
↓
Tomar el signo de la resta
↓
Si overflow dice que ese signo está invertido,
corregirlo
↓
Obtener la respuesta correcta.
```

Por lo tanto:

```text
sum[31] ^ overflow
```

no es una fórmula mágica.

Simplemente significa:

```text
"Usa el signo de la resta, excepto cuando overflow te avise que está mintiendo."
```
