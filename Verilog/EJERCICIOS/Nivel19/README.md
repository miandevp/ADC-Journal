# Nivel 19 - Rumbo a mi instrucción R (Parte 1)

Hasta ahora hemos construido gran parte del camino que recorrerán nuestras instrucciones.

Nuestro pequeño procesador ya posee:

```text
Main Controller
↓
ALU Decoder
↓
ALU
```

Sabemos que una instrucción entra al sistema.

El Main Controller identifica su tipo.

El ALU Decoder decide qué operación exacta debe ejecutar.

Y finalmente la ALU realiza el trabajo.

Sin embargo, hasta este momento habíamos estado entregando piezas sueltas desde el testbench:

```text
opcode
funct3
funct7b5
a
b
```

Es decir, nosotros mismos le decíamos al procesador:

> "Este es el opcode."

> "Esta es la operación."

> "Estos son los operandos."

Pero en un procesador real las cosas no funcionan así.

---

# Una instrucción real

Todas esas señales provienen de una única línea de 32 bits llamada:

```text
instr[31:0]
```

Es decir, el procesador no recibe:

```text
opcode
funct3
a
b
```

por separado.

Recibe un único paquete:

```text
instr[31:0]
```

Y es el propio procesador quien debe separar y entender qué significa cada parte.

Por eso, antes de seguir agregando componentes, es necesario conocer nuestra primera instrucción real.

---

# Nuestra primera instrucción: Tipo R

La primera instrucción completa que estudiaremos será la **R-type**.

¿Por qué comenzar con ella?

Porque las operaciones que ya implementamos pertenecen a este formato:

```text
ADD
SUB
AND
OR
XOR
SLT
SLL
SRL
```

Sin darnos cuenta, llevábamos varios niveles trabajando con fragmentos de una instrucción RISC-V real.

Ahora veremos cómo se unen todas esas piezas.

---

# Estructura de una instrucción R-type

Una instrucción RISC-V ocupa:

```text
32 bits
```

Y se divide así:

```text
31          25 24    20 19    15 14   12 11     7 6      0
┌────────────┬────────┬────────┬────────┬────────┬────────┐
│  funct7    │  rs2   │  rs1   │ funct3 │   rd   │ opcode │
└────────────┴────────┴────────┴────────┴────────┴────────┘
   7 bits      5 bits   5 bits   3 bits   5 bits   7 bits
```

Y muchos de estos campos ya los conocemos.

---

## opcode

```text
opcode[6:0]
```

Le dice al Main Controller:

> "¿Qué tipo de instrucción soy?"

Por ejemplo:

```text
0110011
```

significa:

> "Soy una instrucción R-type."

Y justamente ese fue el primer opcode que nuestro Main Controller aprendió a reconocer.

---

## funct3

```text
funct3[14:12]
```

Ayuda a distinguir operaciones.

Por ejemplo:

```text
000 → ADD / SUB
111 → AND
011 → OR
100 → XOR
001 → SLL
101 → SRL
010 → SLT
```

Este campo ya llevaba tiempo trabajando dentro del ALU Decoder.

---

## funct7

```text
funct7[31:25]
```

Permite diferenciar operaciones que comparten el mismo funct3.

Por ejemplo:

```text
funct3 = 000

funct7 = 0000000 → ADD
funct7 = 0100000 → SUB
```

Y precisamente por eso descubrimos anteriormente que observar:

```text
funct7[5]
```

era suficiente para distinguir entre ambas.

---

# Los registros: algo muy importante

Ahora aparece una idea completamente nueva.

Hasta este momento nosotros escribíamos directamente:

```text
a = 5
b = 6
```

desde el testbench.

Pero una instrucción RISC-V no funciona así.

Una instrucción no trae dos valores para sumar.

No dice:

```text
5 + 6
```

Lo que realmente dice es algo parecido a esto:

```text
ADD x5, x1, x2
```

Y eso significa:

> Toma el valor almacenado en x1.

> Toma el valor almacenado en x2.

> Súmalos.

> Y más adelante guarda el resultado en x5.

Es decir:

```text
La instrucción no trae los valores.

La instrucción trae los registros donde están esos valores.
```

Este es probablemente uno de los conceptos más importantes de este nivel.

---

## rs1

```text
rs1[19:15]
```

Representa el primer registro fuente.

Es decir:

> "¿De qué registro debo obtener mi primer operando?"

---

## rs2

```text
rs2[24:20]
```

Representa el segundo registro fuente.

Es decir:

> "¿De qué registro debo obtener mi segundo operando?"

---

## rd

```text
rd[11:7]
```

Representa el registro destino.

Es decir:

> "¿Dónde debería guardarse el resultado?"

Todavía no escribiremos en él.

Pero comenzaremos a familiarizarnos con su existencia.

---

# Nace nuestro primer Register File

Para poder dejar de escribir manualmente:

```text
a = 5
b = 6
```

hemos creado un nuevo módulo:

```text
Register File
```

Sin embargo, todavía es una versión muy limitada.

Por ahora solamente posee dos registros creados por nosotros:

```text
x1 = 5
x2 = 6
```

No es el Register File definitivo de RISC-V.

Es una pequeña versión educativa.

Su trabajo consiste en recibir:

```text
rs1
rs2
```

y devolver:

```text
a
b
```

para la ALU.

Visualmente:

```text
instr
↓
rs1 ───────► Register File ─────► a
rs2 ───────► Register File ─────► b
                                       ↓
                                      ALU
```

Por ejemplo, si llega:

```text
ADD x5, x1, x2
```

la instrucción realmente está diciendo:

```text
rs1 = x1
rs2 = x2
```

Entonces el Register File hace:

```text
x1 → 5
x2 → 6
```

y entrega:

```text
a = 5
b = 6
```

Finalmente, la ALU ejecuta:

```text
5 + 6 = 11
```

Observa que la instrucción nunca trajo el número 5 ni el número 6.

Trajo los nombres de los registros donde estaban guardados.

---

# Nuestro MiniDatapath también evolucionó

Antes:

```text
Testbench
├─ opcode
├─ funct3
├─ funct7b5
├─ a
└─ b
```

Ahora:

```text
Testbench
└─ instr[31:0]
        ↓
     MiniDatapath
        │
        ├─ opcode ─────► Main Controller
        │
        ├─ funct3
        ├─ funct7b5
        ├─ opb5 ───────► ALU Decoder
        │
        ├─ rs1
        └─ rs2 ───────► Register File
                           │
                           ├─ a
                           └─ b
                                   ↓
                                  ALU
                                   ↓
                                   y
```

Aunque internamente aparecieron más conexiones, desde afuera el procesador se volvió más simple.

Ya no enviamos muchos cables.

Enviamos una sola instrucción.

---

# También aprenderemos a leer instrucciones reales

A partir de este punto comenzaremos a trabajar con instrucciones completas.

Por ello será necesario acostumbrarnos a tres representaciones distintas:

```text
Ensamblador
↓
Binario
↓
Hexadecimal
```

Por ejemplo:

```text
ADD x5, x1, x2
↓
0000000_00010_00001_000_00101_0110011
↓
0x002082B3
```

Y necesitaremos ser capaces de responder preguntas como:

> "¿Qué instrucción representa?"

> "¿Qué registros utiliza?"

> "¿Qué operación ejecutará?"

Porque más adelante nuestros programas reales estarán escritos utilizando estas representaciones.

---

# Hacia dónde vamos

En esta primera parte hemos aprendido a leer registros.

Hemos dejado de introducir operandos manualmente.

Y hemos comenzado a recibir instrucciones reales de 32 bits.

Sin embargo, todavía nos falta completar el ciclo.

Actualmente podemos hacer:

```text
leer registros
↓
operar
↓
obtener resultado
```

Pero aún no podemos hacer:

```text
guardar resultado
```

Porque todavía no hemos implementado la escritura sobre el Register File utilizando:

```text
rd
```

Ese será nuestro siguiente paso.

Más adelante ampliaremos nuestro pequeño Register File hasta convertirlo en un verdadero banco de registros RISC-V, capaz de trabajar con cualquier registro y almacenar nuevos resultados.

---

> Antes entregábamos números.
>
> Ahora entregamos instrucciones.
>
> Antes la ALU recibía operandos directamente.
>
> Ahora los obtiene a partir de registros.
>
> Y aunque nuestro Register File todavía es pequeño, ya hemos dado el primer paso para comprender cómo un procesador transforma una instrucción de 32 bits en una operación real.
