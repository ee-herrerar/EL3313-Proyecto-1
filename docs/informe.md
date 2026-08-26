## Informe técnico — Proyecto 1: Whack-a-mole híbrido FPGA / lógica discreta
Curso: EL3313 Taller de Diseño Digital
Semestre: II Semestre 2026
Proyecto: Whack-a-mole: juego híbrido FPGA / lógica discreta
Plataforma FPGA: Digilent Basys 3
Tecnología discreta: Familia 74xx, protoboard

### Resumen
El presente informe documenta el diseño y desarrollo de un sistema digital híbrido para implementar un juego tipo Whack-a-mole, combinando lógica digital discreta y una FPGA Basys 3. El circuito discreto tiene como función generar pseudoaleatoriamente la posición de uno de ocho posibles “topos”, visualizar dicha posición mediante un LED y transmitir la información correspondiente hacia la FPGA mediante un enlace serial. La FPGA concentra la lógica principal del juego. En ella se implementa una máquina de estados finitos encargada de solicitar nuevas posiciones, recibir y almacenar la posición generada por el circuito discreto, controlar el tiempo disponible para cada topo, registrar aciertos y fallos, modificar progresivamente la dificultad y gestionar el estado de Game Over. También se contempla el procesamiento de los ocho botones externos y la visualización de los resultados mediante los displays de siete segmentos. Para el circuito discreto se plantea un generador basado en un registro de desplazamiento con retroalimentación lineal (LFSR), formado por tres flip-flops y una compuerta XOR. Los tres bits generados se aplican a un decodificador 74LS138 para seleccionar uno de ocho LEDs. Posteriormente, un registro 74LS165 permite convertir la información paralela de la posición a una secuencia serial que será enviada a la FPGA.
Al momento de elaboración del informe, la generación y visualización del número de tres bits se encuentra en implementación física en protoboard, mientras que la transmisión UART y la integración completa con la FPGA constituyen etapas posteriores de desarrollo.

### Introduccion
El proyecto consiste en desarrollar un sistema híbrido basado en una FPGA y un circuito implementado con lógica discreta. El objetivo es reproducir el funcionamiento básico de un juego Whack-a-mole, en el cual un topo aparece en una de ocho posiciones y el jugador debe presionar el botón correspondiente antes de que finalice el tiempo disponible. Una característica fundamental del proyecto es que la generación de la posición del topo no se realiza dentro de la FPGA. Esta función corresponde a un circuito montado en protoboard utilizando circuitos integrados de la familia 74xx. El circuito discreto determina pseudoaleatoriamente una posición, la representa mediante un LED y posteriormente transmite la posición a la FPGA mediante un enlace serial. Esta separación entre ambos sistemas forma parte fundamental del propósito del proyecto. La FPGA, por su parte, se encarga del control general del juego. Esta división permite trabajar simultáneamente con circuitos secuenciales y combinacionales implementados mediante lógica discreta y con diseño RTL sintetizable sobre una FPGA. Además, ambos subsistemas deben operar con referencias temporales independientes. Por lo tanto, el reloj utilizado por el circuito discreto no debe compartirse con la FPGA; la diferencia entre dominios temporales debe resolverse mediante la comunicación serial.

### Fundamentación teórica
#### Circuitos secuenciales
Un circuito secuencial es aquel cuyo comportamiento depende de las entradas actuales y del estado almacenado previamente. En este proyecto, los flip-flops tipo D se utilizan como elementos de memoria para almacenar los bits del LFSR. Cada flip-flop actualiza su salida con base en el valor presente en su entrada D durante el flanco activo del reloj.

#### Registro de desplazamiento con retroalimentación lineal
Para la generación pseudoaleatoria de la posición del topo se utiliza un registro de desplazamiento con retroalimentación lineal (LFSR, Linear Feedback Shift Register) de cuatro bits. El registro está compuesto por cuatro flip-flops tipo D, cuyos estados se representan mediante Q3 Q2 Q1 Q0. La realimentación del registro se obtiene mediante una operación XOR entre determinados bits del estado actual. Para el LFSR de cuatro bits se utiliza el polinomio de retroalimentación: P(x)=x^4+x+1. Este polinomio define los taps utilizados para generar el nuevo bit de realimentación. En la implementación propuesta, los bits Q3 y Q0 se combinan mediante una compuerta XOR: D3 = Q3​⊕Q0​. 
Los demás bits se desplazan dentro del registro:
D2=Q3 
D1=Q2 
D0=Q1
Los cuatro flip-flops reciben el mismo reloj, de manera que en cada flanco activo se actualiza simultáneamente el estado del registro. Una característica importante del LFSR es que el estado 0000 no debe utilizarse como estado inicial. Si el registro entra en dicho estado, la realimentación también produce cero. por lo que el circuito permanecería bloqueado. Para un LFSR de cuatro bits, el número máximo de estados diferentes de cero que puede recorrer es: 2^4-1=15 
Por lo tanto, cuando se utiliza un polinomio de retroalimentación apropiado, el registro puede recorrer hasta 15 estados antes de repetir la secuencia.
En el presente proyecto, el LFSR se utiliza como fuente pseudoaleatoria para generar la posición del topo. Debido a que el tablero posee ocho posiciones, los estados generados por el LFSR deberán posteriormente ser utilizados mediante una etapa de selección o mapeo que permita obtener las ocho combinaciones correspondientes a las posiciones:​
Por ultimo, para una secuencia iniciada en 001 se esperaría 001 → 100 → 110 → 111 → 011 → 101 → 010 → 001.

#### Decodificador 74LS138
El 74LS138 permite convertir las tres señales binarias del LFSR en una de ocho salidas.

<img width="665" height="383" alt="Captura de pantalla 2026-08-26 135259" src="https://github.com/user-attachments/assets/d0999dac-fa36-4a0f-b827-b86a099fbe61" />

Las ocho salidas se conectan a los LEDs correspondientes a las posiciones del juego.

### Subsistema de control en FPGA


### Comunicación UART


### Resultados


### Conclusion
