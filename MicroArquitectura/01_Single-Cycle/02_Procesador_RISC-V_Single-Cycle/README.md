# Ejecución de una Instrucción de 32 Bits

Hasta este punto se ha presentado la arquitectura RISC-V, así como los principales componentes que conforman su microarquitectura. Sin embargo, comprender la función individual de cada bloque no es suficiente para entender el funcionamiento global del procesador. Resulta necesario analizar cómo una instrucción es procesada internamente y cómo la información fluye a través del datapath durante su ejecución. Para ello, en esta sección se estudiará el recorrido de una instrucción de 32 bits a través de las distintas etapas del procesador monociclo RISC-V.

1. **Fetch (Obtención de la instrucción)**
   - Se utiliza el valor del Program Counter (PC) para obtener la siguiente instrucción desde la memoria de instrucciones.

2. **Decode (Decodificación)**
   - Se interpreta la instrucción para identificar la operación a realizar y los registros involucrados.

3. **Evaluate Address (Evaluación de dirección)**
   - Se calcula una dirección de memoria cuando la instrucción requiere acceder a datos almacenados en memoria.

4. **Fetch Operands (Obtención de operandos)**
   - Se leen los operandos necesarios desde el banco de registros o desde otras fuentes de datos.

5. **Execute (Ejecución)**
   - Se realiza la operación principal de la instrucción, generalmente mediante la ALU.

6. **Store Result (Almacenamiento del resultado)**
   - Se guarda el resultado obtenido en el registro o ubicación de memoria correspondiente.