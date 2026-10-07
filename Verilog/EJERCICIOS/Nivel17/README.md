# Nivel 17 - El nacimiento de `opb5` y la optimización de `funct7`

Hasta ahora nuestro decoder había evolucionado así:

```text
funct3
↓
AluDecoder
↓
ALUControl
```

↓

```text
funct3 + funct7
↓
AluDecoder
↓
ALUControl
```

Añadimos `funct7` porque descubrimos que `funct3` ya no era suficiente.

Por ejemplo:

```text
ADD → funct3 = 000
SUB → funct3 = 000
```

La diferencia estaba en:

```text
ADD → funct7 = 0000000
SUB → funct7 = 0100000
```

---

## El primer descubrimiento

Después de hacer funcionar el decoder con los 7 bits de `funct7`, nos dimos cuenta de algo curioso.

Si comparamos:

```text
ADD : 0000000
SUB : 0100000
```

vemos que:

```text
0000000
0100000
 ↑
```

solamente cambia un bit.

Ese bit es:

```text
funct7[5]
```

Entonces surge una pregunta:

> Si solo necesitamos un bit para distinguir ADD de SUB, ¿por qué seguir enviando los 7?

---

## Primera optimización

No eliminamos `funct7`.

RISC-V sigue teniendo:

```text
funct7[6:0]
```

dentro de la instrucción.

Lo que hacemos es una optimización:

```text
funct7[6:0]
↓
extraer funct7[5]
↓
AluDecoder
```

Ya no enviamos información que el decoder no utiliza.

No porque no exista.

Sino porque demostramos que no la necesitamos.

---

## Pero aparece un nuevo problema

Ahora pensemos en estas instrucciones:

```text
ADD
SUB
ADDI
```

Todas pertenecen a la familia:

```text
funct3 = 000
```

Sin embargo:

```text
ADD   → tipo R
SUB   → tipo R
ADDI  → tipo I
```

Entonces aparece una nueva pregunta:

> ¿Cómo sabe el decoder cuándo ese bit de SUB debe tomarse en serio?

Porque si utilizáramos solamente:

```text
funct7[5]
```

podríamos interpretar incorrectamente una instrucción tipo I como si fuera una SUB.

---

## Nace `opb5`

El opcode completo sigue existiendo:

```text
opcode[6:0]
```

Pero observamos algo interesante.

Para las instrucciones que nos importan:

```text
ADD   → opcode = 0110011
SUB   → opcode = 0110011
ADDI  → opcode = 0010011
```

Si miramos solamente el bit 5:

```text
ADD/SUB

0110011
  ↑
  1
```

```text
ADDI

0010011
  ↑
  0
```

ya podemos diferenciarlas.

Entonces hacemos otra optimización.

En lugar de enviar el opcode completo al ALU Decoder:

```text
opcode[6:0]
↓
ALU Decoder
```

enviamos solamente:

```text
opcode[5]
↓
opb5
↓
ALU Decoder
```

---

## El nacimiento de `RtypeSub`

Ahora el decoder tiene dos pistas:

```text
funct7[5]
```

dice:

> "Parece una SUB."

mientras que:

```text
opb5
```

dice:

> "Esta instrucción es de tipo R."

Entonces las combinamos:

```verilog
RtypeSub = funct7b5 & opb5;
```

que puede leerse como:

> "Solo será SUB si parece SUB y además pertenece a una instrucción R."

---

## ¿Por qué es necesario?

Veamos qué ocurre:

### ADD

```text
funct7b5 = 0
opb5     = 1

RtypeSub = 0
```

Resultado:

```text
ADD
```

---

### SUB

```text
funct7b5 = 1
opb5     = 1

RtypeSub = 1
```

Resultado:

```text
SUB
```

---

### ADDI

```text
funct7b5 = X
opb5     = 0

RtypeSub = 0
```

Resultado:

```text
ADDI se comporta como una suma.
Nunca será confundida con SUB.
```

---

## Algo curioso

Podría parecer extraño introducir una señal nueva solamente para un caso tan específico.

Sin embargo:

> En esta versión reducida del decoder, `opb5` existe prácticamente para resolver un único conflicto.

El conflicto entre:

```text
ADD
SUB
ADDI
```

Todas comparten:

```text
ALUOp = 10
funct3 = 000
```

pero no significan lo mismo.

---

## La evolución del decoder

Primero:

```text
funct3
↓
AluDecoder
```

Después:

```text
funct3 + funct7
↓
AluDecoder
```

Luego:

```text
funct3 + funct7[5]
↓
AluDecoder
```

Y finalmente:

```text
ALUOp
funct3
funct7[5]
opb5
↓
AluDecoder
↓
ALUControl
```

---

## La lección

Al principio preferimos enviar toda la información para comprender el problema.

Después empezamos a optimizar.

Primero descubrimos que siete bits podían reducirse a uno.

Después descubrimos que un único bit adicional del opcode resolvía un conflicto muy específico.

No quitamos bits porque "sobren".

Los quitamos porque demostramos que ciertas decisiones podían tomarse utilizando mucha menos lógica.

Primero aprendimos a resolver el problema.

Luego aprendimos a resolverlo de manera elegante.
