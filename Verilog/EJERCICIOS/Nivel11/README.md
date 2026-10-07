# Simplificando la detección de Overflow

## 1. Versión inicial: pensar en español

Primero pensamos qué significa overflow.

---

## Overflow en suma (`v_add`)

Ocurre cuando:

- positivo + positivo = negativo
- negativo + negativo = positivo

Es decir:

### Caso 1

```text
A[31] = 0
B[31] = 0
SUM[31] = 1
```

### Caso 2

```text
A[31] = 1
B[31] = 1
SUM[31] = 0
```

Por lo tanto:

```verilog
assign v_add =
    ((a[31] == 0) && (b[31] == 0) && (sum[31] == 1)) ||
    ((a[31] == 1) && (b[31] == 1) && (sum[31] == 0));
```

---

## Overflow en resta (`v_sub`)

Ocurre cuando:

- positivo - negativo = negativo
- negativo - positivo = positivo

Es decir:

### Caso 1

```text
A[31] = 0
B[31] = 1
SUM[31] = 1
```

### Caso 2

```text
A[31] = 1
B[31] = 0
SUM[31] = 0
```

Por lo tanto:

```verilog
assign v_sub =
    ((a[31] == 0) && (b[31] == 1) && (sum[31] == 1)) ||
    ((a[31] == 1) && (b[31] == 0) && (sum[31] == 0));
```

---

## Elegir cuál usar

Usamos:

```verilog
assign v =
    (sel == 3'b000) ? v_add :
    (sel == 3'b001 || sel == 3'b100) ? v_sub :
    1'b0;
```

Es decir:

```text
ADD  → usar v_add
SUB  → usar v_sub
SLT  → usar v_sub
otros → 0
```

---

# 2. Primera simplificación

## Simplificando v_add

Observamos que en ambos casos de suma:

```text
A y B tienen el mismo signo
```

es decir:

```text
A == B
```

y además:

```text
SUM tiene signo distinto a A
```

es decir:

```text
SUM != A
```

Entonces:

```verilog
assign v_add =
    (a[31] == b[31]) &&
    (sum[31] != a[31]);
```

---

## Simplificando v_sub

Observamos que en ambos casos de resta:

```text
A y B tienen signos distintos
```

es decir:

```text
A != B
```

y además:

```text
SUM tiene signo distinto a A
```

es decir:

```text
SUM != A
```

Entonces:

```verilog
assign v_sub =
    (a[31] != b[31]) &&
    (sum[31] != a[31]);
```

---

# 3. Introduciendo XOR

Recordemos la tabla XOR:

| A | B | A ^ B |
|---|---|--------|
| 0 | 0 |   0    |
| 0 | 1 |   1    |
| 1 | 0 |   1    |
| 1 | 1 |   0    |

---

## Igualdad

```text
A == B
```

equivale a:

```verilog
~(A ^ B)
```

porque XOR vale 0 cuando son iguales.

---

## Diferencia

```text
A != B
```

equivale a:

```verilog
A ^ B
```

porque XOR vale 1 cuando son distintos.

---

## SUM distinto de A

```text
SUM != A
```

equivale a:

```verilog
A ^ SUM
```

---

Entonces obtenemos:

## v_add

Antes:

```verilog
(a == b) && (sum != a)
```

Después:

```verilog
assign v_add =
    ~(a[31] ^ b[31]) &
    (a[31] ^ sum[31]);
```

---

## v_sub

Antes:

```verilog
(a != b) && (sum != a)
```

Después:

```verilog
assign v_sub =
    (a[31] ^ b[31]) &
    (a[31] ^ sum[31]);
```

---

# 4. Unificando suma y resta

Observemos:

Suma:

```verilog
~(a ^ b) & (a ^ sum)
```

Resta:

```verilog
 (a ^ b) & (a ^ sum)
```

La única diferencia es el NOT.

---

Definimos:

```verilog
wire isSub;
```

donde:

```text
isSub = 0 → ADD
isSub = 1 → SUB o SLT
```

---

## Si isSub = 0

```verilog
~(0 ^ a ^ b)
=
~(a ^ b)
```

Obtenemos la fórmula de suma.

---

## Si isSub = 1

```verilog
~(1 ^ a ^ b)
=
(a ^ b)
```

Obtenemos la fórmula de resta.

---

# Fórmula final del libro

Finalmente obtenemos:

```verilog
assign v =
    ~(isSub ^ a[31] ^ b[31]) &
    (a[31] ^ sum[31]);
```

---

# Idea principal

La fórmula del libro NO aparece por arte de magia.

Realmente fue:

```text
Casos escritos en español
↓
v_add y v_sub explícitos
↓
Agrupar condiciones
↓
Cambiar == y != por XOR
↓
Notar que suma y resta solo difieren en un NOT
↓
Usar isSub para controlar ese NOT
↓
Fórmula final compacta
```

La fórmula del profesor es simplemente una versión comprimida del razonamiento que construimos paso a paso.