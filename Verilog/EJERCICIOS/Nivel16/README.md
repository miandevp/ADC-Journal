# Nivel 16 - El nacimiento de ALUOp

Ya descubrimos por qué apareció `funct7`.

Primero teníamos:

```text
funct3
↓
AluDecoder
↓
ALUControl
```

pero encontramos un problema:

```text
ADD → funct3 = 000
SUB → funct3 = 000
```

Una sola señal ya no alcanzaba.

Entonces expandimos nuestro decoder:

```text
funct3
+
funct7
↓
AluDecoder
↓
ALUControl
```

Ahora podíamos representar muchas más operaciones.

---

## Pero aparece un nuevo problema

Ahora nuestro decoder sabe distinguir muchísimas operaciones.

Sin embargo, al estudiar RISC-V descubrimos algo curioso.

Existen instrucciones como:

```text
lw
sw
beq
```

que no necesitan toda esa inteligencia.

Por ejemplo:

### lw

Para calcular una dirección hace:

```text
registro base + desplazamiento
```

es decir:

```text
SUMA
```

---

### sw

También necesita:

```text
registro base + desplazamiento
```

es decir:

```text
SUMA
```

---

### beq

Para comparar dos registros utiliza:

```text
registro1 - registro2
```

es decir:

```text
RESTA
```

---

## Entonces surge una pregunta

Si ya sabemos que:

```text
lw → SUMA
sw → SUMA
beq → RESTA
```

¿por qué obligar al decoder a consultar siempre?

```text
funct3
+
funct7
```

para descubrir algo que ya conocemos.

---

## Nace ALUOp

ALUOp es una señal enviada por el Main Decoder.

Su trabajo es decirle al ALU Decoder:

> "No hace falta pensar tanto."

Por ejemplo:

```text
ALUOp = 00
↓
Haz una SUMA directamente.
```

```text
ALUOp = 01
↓
Haz una RESTA directamente.
```

```text
ALUOp = 10
↓
Ahora sí consulta funct3 y funct7.
```

---

## Visualmente

Antes:

```text
funct3
funct7
↓
AluDecoder
↓
ALUControl
```

Todo pasaba por el decoder complejo.

---

Ahora:

```text
opcode
↓
Main Decoder
↓
ALUOp
        ↓
        ├─ 00 → SUMA
        │
        ├─ 01 → RESTA
        │
        └─ 10 → usar funct3 + funct7
                   ↓
              AluDecoder
                   ↓
              ALUControl
```

---

## ¿Por qué es importante?

No es porque el hardware "recorra" miles de casos uno por uno.

El problema es otro:

> Estamos utilizando lógica compleja para instrucciones cuya operación ya conocemos.

ALUOp actúa como un filtro.

Permite ir directamente a las operaciones más frecuentes y simples, como calcular direcciones de memoria o realizar comparaciones para branches.

Solo cuando realmente hace falta distinguir entre muchas operaciones diferentes, el ALU Decoder consulta `funct3` y `funct7`.

---

## La evolución de nuestro diseño

```text
sel
↓
ALU
```

↓

```text
funct3
↓
AluDecoder
↓
ALU
```

↓

```text
funct3 + funct7
↓
AluDecoder
↓
ALU
```

↓

```text
opcode
↓
Main Decoder
↓
ALUOp
↓
AluDecoder
↓
ALUControl
↓
ALU
```

Cada nueva señal apareció porque el diseño anterior encontró un límite.

No añadimos complejidad porque el libro la tenía.

La añadimos porque nuestro propio procesador la necesitó.
