# README - Implementación de XOR, SLL y SRL

## Estado anterior

La ALU ya soportaba:

* ADD
* SUB
* AND
* OR
* SLT corregido mediante overflow
* ZERO
* OVERFLOW

Por lo tanto, la lógica compleja de la ALU ya estaba terminada.

---

## Objetivo de esta actualización

Completar las operaciones restantes para llegar a una ALU prácticamente final.

Las instrucciones agregadas fueron:

* XOR
* SLL (Shift Left Logical)
* SRL (Shift Right Logical)

---

## XOR

Se agregó:

```verilog
3'b101: y = a ^ b;
```

La operación XOR devuelve 1 cuando los bits son distintos.

Ejemplo:

```text
0101
0011
----
0110
```

Por lo tanto:

```text
5 ^ 3 = 6
```

---

## SLL (Shift Left Logical)

Se agregó:

```verilog
3'b110: y = a << b[4:0];
```

Desplaza los bits hacia la izquierda.

Se utilizan únicamente los 5 bits menos significativos de `b` porque en una ALU de 32 bits solo es posible desplazar entre 0 y 31 posiciones.

Ejemplo:

```text
3 << 2

0011
↓
1100

= 12
```

---

## SRL (Shift Right Logical)

Se agregó:

```verilog
3'b111: y = a >> b[4:0];
```

Desplaza los bits hacia la derecha rellenando con ceros.

Ejemplo:

```text
12 >> 2

1100
↓
0011

= 3
```

---

## Estado actual de la ALU

La ALU ahora soporta:

```text
000 → ADD
001 → SUB
010 → AND
011 → OR
100 → SLT
101 → XOR
110 → SLL
111 → SRL
```

---

## Conclusión

Con esta actualización la ALU quedó prácticamente completa.

Las operaciones nuevas no requirieron nuevo hardware complejo ni nuevas señales de control especiales, ya que Verilog proporciona operadores directos para implementarlas.

La parte más difícil del diseño fue la reutilización del sumador, la detección de overflow y la corrección del SLT. Estas nuevas operaciones representan simplemente la finalización del conjunto funcional de la ALU.
