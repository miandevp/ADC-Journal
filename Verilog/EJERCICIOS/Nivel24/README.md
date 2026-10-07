# Nivel 24 - Controller vs Datapath

Hasta ahora nuestro pequeño procesador RISC-V ha evolucionado muchísimo.

Primero dejamos de entregar números directamente a la ALU.

Después descubrimos que las instrucciones no contienen los operandos con los que operan, sino referencias a registros mediante:

```text
rs1
rs2
rd
```

Entonces construimos un verdadero Register File.

Aprendimos a leer registros.

Aprendimos a escribir resultados.

Después dejamos de entregar operandos desde el testbench.

Más adelante dejamos incluso de entregar instrucciones.

Creamos una memoria de instrucciones.

Construimos un Program Counter.

Le enseñamos a recordar dónde estaba.

Y finalmente le enseñamos a avanzar automáticamente mediante:

```text
PC = PC + 4
```

hasta conseguir que nuestro pequeño RISC-V ejecutara por sí solo una secuencia completa de instrucciones R-Type.

Sin embargo, antes de entrar al mundo del pipeline, debemos hacer una pequeña pausa.

Porque hasta este momento hemos estado pensando nuestro procesador como un único gran módulo estructural.

---

# Nuestro MiniDatapath hasta ahora

Actualmente nuestro diseño podría representarse aproximadamente así:

```text
MiniDatapath
├─ Program Counter
├─ Instruction Memory
├─ Main Decoder
├─ ALU Decoder
├─ Register File
├─ ALU
└─ PCPlus4
```

Y funciona.

De hecho, funciona muy bien.

Ya hemos comprobado mediante simulación que es capaz de ejecutar programas reales formados por varias instrucciones.

Entonces aparece una pregunta natural.

> Si funciona...
>
> ¿Por qué modificarlo?

La respuesta es sencilla.

Porque queremos prepararnos para comprender arquitecturas más grandes y cercanas a las utilizadas en la práctica.

---

# El cuerpo y el cerebro

Cuando observamos diagramas clásicos de procesadores, descubrimos que normalmente existe una separación muy clara.

Por un lado encontramos:

```text
Datapath
```

Y por otro lado:

```text
Controller
```

---

# ¿Qué hace el Datapath?

El Datapath es el encargado de mover y transformar los datos.

Por ejemplo:

```text
PC
↓
Instruction Memory
↓
Register File
↓
ALU
↓
Write Back
```

Es decir, contiene los elementos que realmente trabajan con la información.

Por ejemplo:

```text
Program Counter
Instruction Memory
Register File
ALU
Multiplexores
Registros
PC+4
```

Su trabajo consiste en transportar datos desde un lugar hacia otro y producir resultados.

Podríamos decir que representa el cuerpo del procesador.

---

# ¿Qué hace el Controller?

El Controller no mueve datos.

Toma decisiones.

Responde preguntas como:

```text
¿Qué operación debe realizar la ALU?

¿Debemos escribir en un registro?

¿Debemos leer memoria?

¿Debemos realizar un salto?

¿Qué señales deben activarse?
```

Por ejemplo, nuestros módulos:

```text
Main Decoder
ALU Decoder
```

ya forman parte de esta lógica de control.

Podríamos decir que representan el cerebro del procesador.

---

# El verdadero truco

La separación entre Controller y Datapath no consiste simplemente en mover módulos de un archivo a otro.

El verdadero truco consiste en hacerse una pregunta muy sencilla:

> ¿Esta señal transporta datos?

o

> ¿Esta señal toma decisiones?

Dependiendo de la respuesta sabremos automáticamente dónde pertenece.

---

# Imaginemos que partimos el procesador por la mitad

Supongamos que dibujamos una línea en medio del MiniDatapath.

Algo así:

```text
                ┌──────────────┐
                │ Controller   │
                └──────┬───────┘
                       │
──────────────────────┼────────────────────
                       │
                ┌──────┴───────┐
                │ Datapath     │
                └──────────────┘
```

Y ahora hacemos un ejercicio mental.

Tapamos el Controller.

Solamente observamos el Datapath.

Entonces nos preguntamos:

> ¿Qué información necesita salir del Datapath para que alguien pueda decidir qué hacer?

La respuesta es:

```text
opcode
funct3
funct7b5
opb5
```

Porque esas señales describen qué instrucción estamos ejecutando.

Visualmente:

```text
Datapath
    ↓
opcode
funct3
funct7b5
opb5
    ↓
Controller
```

---

# ¿Qué devuelve el Controller?

Ahora hacemos lo contrario.

Tapamos el Datapath.

Y preguntamos:

> ¿Qué decisiones necesita enviar el Controller para que el Datapath funcione?

La respuesta es:

```text
RegWrite
ALUControl
```

Visualmente:

```text
Controller
    ↓
RegWrite
ALUControl
    ↓
Datapath
```

Y listo.

Acabamos de descubrir automáticamente cuáles son las entradas y salidas entre ambos módulos.

---

# Una regla muy útil

Cuando no sepamos dónde colocar algo, podemos utilizar esta regla.

## Pregunta 1

¿Transporta datos?

Por ejemplo:

```text
PC
instr
rs1
rs2
rd
a
b
y
pcnext
```

Si la respuesta es sí:

```text
→ Datapath
```

---

## Pregunta 2

¿Toma decisiones?

Por ejemplo:

```text
RegWrite
MemWrite
Branch
Jump
ALUControl
ALUOp
ResultSrc
PCSrc
```

Si la respuesta es sí:

```text
→ Controller
```

---

# ¿Entonces quién tiene la entrada y quién tiene la salida?

No existe un dueño absoluto.

Depende del punto de vista.

Por ejemplo:

Desde el Controller:

```text
Entradas:
opcode
funct3
funct7b5
opb5

Salidas:
RegWrite
ALUControl
```

Pero visto desde el Datapath:

```text
Entradas:
RegWrite
ALUControl

Salidas:
opcode
funct3
funct7b5
opb5
```

Son exactamente las mismas señales.

Simplemente observadas desde lados opuestos del límite.

---

# ¿Nuestro diseño anterior estaba mal?

No.

En absoluto.

Nuestro MiniDatapath actual ha cumplido perfectamente su objetivo.

Gracias a él comprendimos cómo funciona una instrucción R-Type.

Construimos un Register File.

Creamos un Program Counter.

Ejecutamos programas reales.

Validamos señales como:

```text
zero
overflow
```

y vimos cómo el Program Counter recorría automáticamente una secuencia de instrucciones.

Nada de eso estaba equivocado.

Simplemente habíamos construido el procesador como una sola pieza.

Ahora estamos aprendiendo a distinguir dos responsabilidades distintas.

---

# ¿Por qué esto es tan importante para el pipeline?

Porque cuando lleguemos al pipeline ocurrirá algo muy parecido.

Los datos seguirán viajando:

```text
IF
↓
ID
↓
EX
↓
MEM
↓
WB
```

Y las señales de control también avanzarán:

```text
RegWriteD
↓
RegWriteE
↓
RegWriteM
↓
RegWriteW
```

Es decir:

> El Datapath seguirá moviendo datos.

Y:

> El Controller seguirá tomando decisiones.

La diferencia es que ahora ambos estarán repartidos entre varias etapas y separados por registros intermedios.

---

# La verdadera idea de este nivel

No estamos modificando nuestro diseño porque estuviera mal.

Estamos aprendiendo a mirar el mismo procesador desde otra perspectiva.

La pregunta ya no es:

> ¿Qué módulos tengo?

Sino:

> ¿Quién mueve los datos?

y

> ¿Quién decide qué hacer con ellos?

Porque una vez que somos capaces de responder esa pregunta simplemente tapando uno de los lados del diagrama y observando qué señales cruzan la frontera, estamos pensando exactamente igual que los libros clásicos de arquitectura.

Y eso significa que el pipeline ya no está lejos.

Ahora sí estamos listos para entender cómo muchas instrucciones pueden avanzar simultáneamente sin interferirse entre sí.