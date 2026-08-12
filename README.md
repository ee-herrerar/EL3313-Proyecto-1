# EL3313: Taller de Diseño Digital
## Proyecto 2:  Whack-a-mole vía FPGA y lógica discreta

### Introducción
Este proyecto consiste en el diseño e implementación de una versión híbrida del clásico juego electrónico **Whack-a-mole** ("golpea al topo"). El objetivo principal es integrar de forma práctica los conocimientos de sistemas combinacionales, secuenciales, *datapath* y *control path*. Para ello, el sistema propuesto divide sus tareas entre un subsistema de **lógica discreta** (implementado en *protoboard* con circuitos integrados de la familia 74xx) y un subsistema de control digital sintetizado en una **FPGA** mediante el lenguaje de descripción de hardware SystemVerilog.
El juego se desarrolla mediante la interacción de ambos entornos: el circuito discreto determina de manera pseudoaleatoria cuál de las ocho posiciones posibles ocupará el "topo", lo muestra localmente mediante un LED y envía esta información a la FPGA a través de un enlace de comunicación serial asíncrono UART. Por su parte, la FPGA gestiona toda la lógica de control del juego, lo que incluye la habilitación del turno, el control de la dificultad progresiva reduciendo la ventana de tiempo mediante *clock enables*, el registro de vidas (con un límite de 3 fallos consecutivos), la lectura de los pulsadores externos de golpe conectados por GPIO y la visualización de los puntajes en displays de siete segmentos. Este enfoque híbrido permite experimentar tanto el diseño síncrono en HDL como los retos físicos de comunicar de forma confiable dos dominios de reloj independientes que carecen de una referencia de tiempo compartida.

### Planteamiento de diseño

#### Circuito discreto
Este sistema se encarga de seleccionas psudoaleatoriamente un led y lo enciende, funciona usando un registro de desplazamiento con retroalimentación lineal para generar un numero de tres bits cada vez que la fpga lo indique, este funciona con 3 flip flops en serie donde la entrada del primero es la salida de una compuerta xor cuyas entradas son las salidas de los otros flip flops, cada vez que la fpga envia la señal esta llega a la entrada de reloj para que los bits de salida que dan los fliop flops se desplazan generando asi un numero de tres bits. Una vez genrado el numero de tres bits, este pasa por el decodificador 74LS138 el cual dependiendo del numero binario generado anteriormente enciende una de las 8 posibles entradas, estas entradas se conectan a los 8 leds. Por ultimo mediante un 74LS165 se empaqueta una secuencia de 8 bits que se envian a la fpga para indicarle cual posicion actual tiene al led encendido.  

<img width="636" height="559" alt="Captura de pantalla 2026-08-12 113503" src="https://github.com/user-attachments/assets/40c7f6c1-4d64-4c0e-9d0e-f3c6ea0d0a36" />

#### UART: módulo de transmisión
UART (Universal Asynchronous Receiver Transmitter) es un protocolo de comunicación asíncrono, capaz de transmitir información entre dos dispositivos que operan a distintas frecuencias. Este protocolo utiliza una tasa de baudios (baud rate) común entre transmisor y receptor, esto equivale a la cantidad de bits transmitidos por segundo, la elección de el baud rate puede afectar la velocidad, calidad y eficiencia de la comunicación, por lo que para este proyecto se contempla el uso de una tasa de baudios estándar baja. Para asegurar la comunicación entre dispositivos, la línea TX (de transmisión) se mantiene constantemente en 1, e indica el inicio de la transmisión bajando a 0, así mismo, tras finalizar la transmisión la línea vuelve a 1.

El siguiente circuito está compuesto por una señal de reloj generada con un oscilador astable con 555 y un divisor de frecuencia hecho con flip-flops tipo D, estos dos elementos se utilizarán para generar el baud rate al que se transmiten los datos. El registro de desplazamiento paralelo serie 74LS165 se encarga de la transmisión de los 8 bits en serie desde el decodificador a través de la línea de transmisión TX. La parte de control de secuencia se encarga de contar los bits desplazados en cada señal del generador de baudios así como de generar y controlar las señales de “Load” en el registro de desplazamientos, el control se hace a través de un MUX 2 a 1, el cual decide entre las entradas según el numero en el que el contador en que se encuentre, se planea que la primera entrada se mantenga en alto y a partir de cierto numero pase a cero (tras ser activado el contador), activando así las señales de “start (0)” y “stop (1)”, las cuales se encargan de indicar al receptor el inicio y fin de la transmisión asincrónica. La segunda entrada se conecta al registro de desplazamiento y se activa después de el “start (0)” de la primera entrada para iniciar la transmisión en serie de los bits, finalmente se regresa a la primera entrada manteniéndola en 1 o “stop”.


##### MUX

<img width="145" height="174" alt="image" src="https://github.com/user-attachments/assets/d633499c-8549-418d-9d13-dafaa6faa369" />

Para esta sección se considera el uso de un contador de 4 bits de 0 a 9. Por medio de lógica combinacional se planea el control de las salidas de MUX, el estado de la línea A (señal de “start” y “stop”) y el control del load para cargar los bits e iniciar el desplazamiento.

<img width="600" height="72" alt="image" src="https://github.com/user-attachments/assets/89aad524-ce61-466f-8e0a-6eb9cacddad4" />

<img width="598" height="336" alt="image" src="https://github.com/user-attachments/assets/b1810e6d-8f39-4408-9a31-0217cbb4ba98" />

Los números del contador se usarán para la carga paralela de bits en el registro de desplazamiento e iniciar el desplazamiento, cambiar la línea A entre 1 y 0, elegir entre salidas del MUX y activar una señal de enable una vez finaliza la transmisión, deteniendo la cuenta. Para este primer planteamiento se toma en cuenta la posibilidad de generar una señal que desactiva el enable una vez inicia la transmisión y los bits para su transmisión. 

<img width="539" height="331" alt="image" src="https://github.com/user-attachments/assets/d13b8462-2430-43b8-b05a-6e66f45518aa" />

