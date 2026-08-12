# EL3313: Taller de Diseño Digital
## Proyecto 2:  Whack-a-mole vía FPGA y lógica discreta

### Introducción
Este proyecto consiste en el diseño e implementación de una versión híbrida del clásico juego electrónico **Whack-a-mole** ("golpea al topo"). El objetivo principal es integrar de forma práctica los conocimientos de sistemas combinacionales, secuenciales, *datapath* y *control path*. Para ello, el sistema propuesto divide sus tareas entre un subsistema de **lógica discreta** (implementado en *protoboard* con circuitos integrados de la familia 74xx) y un subsistema de control digital sintetizado en una **FPGA** mediante el lenguaje de descripción de hardware SystemVerilog.
El juego se desarrolla mediante la interacción de ambos entornos: el circuito discreto determina de manera pseudoaleatoria cuál de las ocho posiciones posibles ocupará el "topo", lo muestra localmente mediante un LED y envía esta información a la FPGA a través de un enlace de comunicación serial asíncrono UART. Por su parte, la FPGA gestiona toda la lógica de control del juego, lo que incluye la habilitación del turno, el control de la dificultad progresiva reduciendo la ventana de tiempo mediante *clock enables*, el registro de vidas (con un límite de 3 fallos consecutivos), la lectura de los pulsadores externos de golpe conectados por GPIO y la visualización de los puntajes en displays de siete segmentos. Este enfoque híbrido permite experimentar tanto el diseño síncrono en HDL como los retos físicos de comunicar de forma confiable dos dominios de reloj independientes que carecen de una referencia de tiempo compartida.

### Planteamiento de diseño

#### Circuito discreto
Este sistema se encarga de seleccionas psudoaleatoriamente un led y lo enciende, funciona usando un registro de desplazamiento con retroalimentación lineal para generar un numero de tres bits cada vez que la fpga lo indique, este funciona con 3 flip flops en serie donde la entrada del primero es la salida de una compuerta xor cuyas entradas son las salidas de los otros flip flops, cada vez que la fpga envia la señal esta llega a la entrada de reloj para que los bits de salida que dan los fliop flops se desplazan generando asi un numero de tres bits. Una vez genrado el numero de tres bits, este pasa por el decodificador 74LS138 el cual dependiendo del numero binario generado anteriormente enciende una de las 8 posibles entradas, estas entradas se conectan a los 8 leds. Por ultimo mediante un 74LS165 se empaqueta una secuencia de 8 bits que se envian a la fpga para indicarle cual posicion actual tiene al led encendido.  

<img width="636" height="559" alt="Captura de pantalla 2026-08-12 113503" src="https://github.com/user-attachments/assets/40c7f6c1-4d64-4c0e-9d0e-f3c6ea0d0a36" />


