## Informe técnico — Proyecto 1: Whack-a-mole híbrido FPGA / lógica discreta
Curso: EL3313 Taller de Diseño Digital
Semestre: II Semestre 2026
Proyecto: Whack-a-mole: juego híbrido FPGA / lógica discreta
Plataforma FPGA: Digilent Basys 3
Tecnología discreta: Familia 74xx, protoboard

## Resumen
El presente informe documenta el diseño y desarrollo de un sistema digital híbrido para implementar un juego tipo Whack-a-mole, combinando lógica digital discreta y una FPGA Basys 3. El circuito discreto tiene como función generar pseudoaleatoriamente la posición de uno de ocho posibles “topos”, visualizar dicha posición mediante un LED y transmitir la información correspondiente hacia la FPGA mediante un enlace serial. La FPGA concentra la lógica principal del juego. En ella se implementa una máquina de estados finitos encargada de solicitar nuevas posiciones, recibir y almacenar la posición generada por el circuito discreto, controlar el tiempo disponible para cada topo, registrar aciertos y fallos, modificar progresivamente la dificultad y gestionar el estado de Game Over. También se contempla el procesamiento de los ocho botones externos y la visualización de los resultados mediante los displays de siete segmentos. Para el circuito discreto se plantea un generador basado en un registro de desplazamiento con retroalimentación lineal (LFSR), formado por tres flip-flops y una compuerta XOR. Los tres bits generados se aplican a un decodificador 74LS138 para seleccionar uno de ocho LEDs. Posteriormente, un registro 74LS165 permite convertir la información paralela de la posición a una secuencia serial que será enviada a la FPGA.
Al momento de elaboración del informe, la generación y visualización del número de tres bits se encuentra en implementación física en protoboard, mientras que la transmisión UART y la integración completa con la FPGA constituyen etapas posteriores de desarrollo.

## Introduccion
El proyecto consiste en desarrollar un sistema híbrido basado en una FPGA y un circuito implementado con lógica discreta. El objetivo es reproducir el funcionamiento básico de un juego Whack-a-mole, en el cual un topo aparece en una de ocho posiciones y el jugador debe presionar el botón correspondiente antes de que finalice el tiempo disponible. Una característica fundamental del proyecto es que la generación de la posición del topo no se realiza dentro de la FPGA. Esta función corresponde a un circuito montado en protoboard utilizando circuitos integrados de la familia 74xx. El circuito discreto determina pseudoaleatoriamente una posición, la representa mediante un LED y posteriormente transmite la posición a la FPGA mediante un enlace serial. Esta separación entre ambos sistemas forma parte fundamental del propósito del proyecto. La FPGA, por su parte, se encarga del control general del juego. Esta división permite trabajar simultáneamente con circuitos secuenciales y combinacionales implementados mediante lógica discreta y con diseño RTL sintetizable sobre una FPGA. Además, ambos subsistemas deben operar con referencias temporales independientes. Por lo tanto, el reloj utilizado por el circuito discreto no debe compartirse con la FPGA; la diferencia entre dominios temporales debe resolverse mediante la comunicación serial.

## Fundamentación teórica
#### Circuitos secuenciales
Un circuito secuencial es aquel cuyo comportamiento depende de las entradas actuales y del estado almacenado previamente. En este proyecto, los flip-flops tipo D se utilizan como elementos de memoria para almacenar los bits del LFSR. Cada flip-flop actualiza su salida con base en el valor presente en su entrada D durante el flanco activo del reloj.

#### Registro de desplazamiento con retroalimentación lineal
Para la generación pseudoaleatoria de la posición del topo se utiliza un registro de desplazamiento con retroalimentación lineal (LFSR, Linear Feedback Shift Register) de tres bits. El registro está compuesto por tres flip-flops tipo D, cuyos estados se representan mediante Q2, Q1 Q0.

La realimentación se implementa mediante una compuerta XOR que combina los bits Q2 y Q0. Estos bits corresponden a los taps utilizados para generar el nuevo valor que ingresa al registro. Las ecuaciones de siguiente estado son:

$$ D_2=Q_2\oplus Q_0 $$ $$ D_1=Q_2 $$ $$ D_0=Q_1 $$

La red de realimentación utilizada puede representarse mediante el polinomio:

$$ P(x)=x^3+x+1 $$

Este polinomio describe los términos utilizados en la realimentación del LFSR y permite seleccionar una configuración que produzca una secuencia de longitud máxima para un registro de tres bits. Para un LFSR de \(n=3\) bits, el período máximo es:

$$ 2^3-1=7 $$

Por lo tanto, el circuito puede recorrer siete estados diferentes de cero antes de repetir la secuencia. Para una condición inicial de \(001\), la secuencia obtenida es:

$$ 001\rightarrow100\rightarrow110\rightarrow111 \rightarrow011\rightarrow101\rightarrow010\rightarrow001 $$

El estado \(000\) no debe utilizarse como condición inicial, debido a que la realimentación XOR produce nuevamente cero y el registro permanece indefinidamente en dicho estado. Por esta razón, durante la inicialización se debe garantizar que al menos uno de los tres flip-flops se encuentre en estado lógico 1.

#### Decodificador 74LS138
El 74LS138 permite convertir las tres señales binarias del LFSR en una de ocho salidas.

<img width="665" height="374" alt="Captura de pantalla 2026-08-26 135259" src="https://github.com/user-attachments/assets/d0999dac-fa36-4a0f-b827-b86a099fbe61" />

Las ocho salidas se conectan a los LEDs correspondientes a las posiciones del juego.

### Subsistema de control en FPGA
#### Estructura Del Sistema
##### Primer nivel
Para la etapa del diseño se planteó una estructura dividida en tres etapas: Discreta (UART-TX y generador pseudoaleatorio, ambas etapas discretas), Botones (Conexiones de botones físicos) y FPGA (Programación bajo Basys 3). 
Dicho orden se presenta a continuación:

<img style="width: 100%; max-width: 665px; aspect-ratio: 16 / 9; object-fit: contain;" alt="Diagrama de Primer Nivel Del Sistema" src="https://github.com/ee-herrerar/EL3313-Proyecto-1/raw/main/docs/ImagenesDocu/DiagramaBloques-PrimerNivel.png" />


##### Segundo Nivel
Para esto se desglosa aspectos relevantes como la etapa discreta y la recepción por la FPGA tanto por las señales de botones como la de señal enviada por la UART. 
Adicionalmente se tiene en consideración la presencia de la lógica del juego y salidas de las señales que regresan a la etapa discreta, así como la salida del sistema. Tal como puede verse a continuación:

<img style="width: 100%; max-width: 665px; aspect-ratio: 16 / 9; object-fit: contain;" alt="Diagrama de Segundo Nivel Del Sistema" src="https://github.com/ee-herrerar/EL3313-Proyecto-1/raw/main/docs/ImagenesDocu/DiagramaBloques-SegundoNivel.png" />


##### Tercer Nivel
Se tiene el desglose completo, el cual involucra:
- Etapa de sincronización y recepción de los datos discretos por parte de la UART.
- Configuración de reset y el clock por defecto de la FPGA.
- Tratamiento de los botones mediante sincronización (Para evitar Metaestabilidad), seguido de una etapa de antirebotes para asegurar entradas limpias a la FSM. 
- Estructura de FSM y salidas del comportamiento hacia los timers y señales de topo
- Comportamiento de las salidas a los Displays

<img style="width: 100%; max-width: 665px; aspect-ratio: 16 / 9; object-fit: contain;" alt="Diagrama de Tercer Nivel Del Sistema" src="https://github.com/ee-herrerar/EL3313-Proyecto-1/raw/main/docs/ImagenesDocu/DiagramaBloques-TercerNivel.png" />


#### Maquina de Estados

|  Estado Actual   |                                 Condición de Salto                                  |                                       Acción a realizar                                       |   Salto a Realizar   |
| :--------------: | :---------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------: | :------------------: |
|   Llamada Topo   |                 Se realiza el análisis del golpe del Topo anterior                  |                              Se pide la nueva posición del Topo                               |     Espera Topo      |
|   Espera Topo    |                    Se recibe la posición del Topo desde la UART                     |                       Se procesa y se guarda la nueva posición del Topo                       |     Topo Activo      |
|   Topo Activo    |         La posición nueva del Topo fue procesada y almacenada correctamente         |      Se inicia el tiempo permitido para realizar un golpe al Topo, recibiendo cada input      | Tiempo/Fallo/Acierto |
|     Acierto      |                   La posición elegida por el jugador es correcta                    |                              Se registra el golpe como un éxito                               |     Acierto Sube     |
|   Acierto Sube   |                   La posición elegida por el jugador es correcta                    | Se incrementa en uno el contador de aciertos y se reinicia el contador de fallos consecutivos |    Reajuste Reloj    |
|  Reajuste Reloj  |                   La posición elegida por el jugador es correcta                    |                     Se realiza el ajuste de temporizador correspondiente                      |     Llamada Topo     |
|      Tiempo      |                El tiempo disponible para realizar un golpe se acaba                 |                              Se registra el golpe como un fallo                               |      Fallo Sube      |
|      Fallo       |                  La posición elegida por el jugador es incorrecta                   |                              Se registra el golpe como un fallo                               |      Fallo Sube      |
|    Fallo Sube    |                        El golpe fue registrado como un fallo                        |    Se incrementan en uno el contador total de fallos y el contador de fallos consecutivos     |   Verificar Fallos   |
| Verificar Fallos |                        El golpe fue registrado como un fallo                        |              Se realiza la verificación de que el jugador posee vidas restantes               |  Fallos<3/Fallos=3   |
|    Fallos <3     | El golpe fue registrado como un fallo pero el jugador todavía tiene vidas restantes |                   El juego volverá a solicitar un Topo y el juego continúa                    |     Llamada Topo     |
|    Fallos =3     |   El golpe fue registrado como un fallo pero el jugador no tiene vidas restantes    |                        El juego transiciona a la pantalla de Game Over                        |      Game Over       |
|    Game Over     |   El golpe fue registrado como un fallo pero el jugador no tiene vidas restantes    |                              La pantalla despliega el Game Over                               |     Llamada Topo     |
| Cualquier Estado |                           El botón de RESET es presionado                           |     Reiniciar contadores, fallos consecutivos y temporizador; restaurar ventana a 1500 ms     |     Llamada Topo     |

#### Comunicación UART
Para la comunicación mediante UART RX se tendrá en cuenta que la información proveniente del circuito discreto utiliza un formato 8N1, constituido por un bit de inicio, ocho bits de datos y un bit de parada. De los ocho bits de datos recibidos, únicamente los tres bits menos significativos serán utilizados para representar la posición del Topo, permitiendo codificar las ocho posiciones posibles. Los cinco bits restantes se mantendrán en cero o podrán ser utilizados para otra función que se decida.
Debido a que el circuito discreto y la FPGA operan con referencias de reloj independientes, la señal serial recibida deberá pasar por un sincronizador de dos etapas antes de ser procesada por el receptor UART. Una vez recibida correctamente la trama, el receptor UART generará una señal de dato válido que indicará a la FSM que la posición recibida puede ser utilizada y que se puede continuar con la ejecución del juego. En cuanto al _baud rate_, se llego al acuerdo de usar 


#### Botones de los Topos
El procesamiento de los botones correspondientes a los “huecos” requiere principalmente dos procesos sobre cada una de las señales recibidas:
1. Sincronización de la señal: De manera similar a la señal recibida mediante UART, las señales provenientes de los botones son asíncronas respecto al reloj de la FPGA. Por esta razón, cada una pasará por un sincronizador de dos etapas antes de ser procesada.
2. Debounce: Debido al rebote mecánico producido al presionar los botones, pueden generarse múltiples cambios rápidos de estado durante una sola pulsación. Para evitar que estos sean interpretados como múltiples golpes, se utilizará un módulo de _debounce_ que permitirá obtener una señal estable.
Una vez realizados ambos procesos, las señales filtradas de los ocho botones podrán ser utilizadas por la FSM para determinar si la posición presionada corresponde con la posición del Topo activo.

#### Temporizador y Clock Enables
Uno de los requisitos del trabajo es lograr la implementación del sistema de tiempo del juego sin la creación de relojes adicionales dentro del código, ya que todo el sistema debe utilizar el mismo reloj de 100 MHz en todo momento. Para esto, se utilizará un contador interno encargado de llevar el tiempo transcurrido mientras el Topo se encuentre activo. El valor límite de este contador dependerá de la dificultad actual del juego y será reajustado mediante el módulo “Reajuste Reloj”, permitiendo disminuir progresivamente la duración de la ventana del Topo desde 1500 ms hasta un mínimo de 500 ms. El contador comenzará su operación en el momento en que la FSM ingrese al estado “Topo Activo” y, al alcanzar el límite correspondiente, generará una señal de tiempo acabado para la FSM.
Se utilizará un clock enable para controlar cuándo el contador del temporizador puede actualizarse. Este será generado a partir del reloj principal de 100 MHz y permitirá medir los intervalos de tiempo requeridos sin crear un reloj adicional, manteniendo todo el subsistema sincronizado con una única señal de reloj.

| Número de Aciertos | Tiempo Activo del Topo (ms) |
| -----------------: | --------------------------: |
|                  0 |                        1500 |
|                  1 |                        1400 |
|                  2 |                        1300 |
|                  3 |                        1200 |
|                  4 |                        1100 |
|                  5 |                        1000 |
|                  6 |                         900 |
|                  7 |                         800 |
|                  8 |                         700 |
|                  9 |                         600 |
|           10 o más |                         500 |

#### Conteo y Visualización de Resultados
- Contador de Aciertos: Lleva la cantidad total de aciertos obtenidos durante la partida y su valor se muestra en dos de los displays de 7 segmentos. Cada vez que la FSM ingrese al estado Aciertos Sube, el contador aumentará en uno.
- Contador de Fallos: Lleva la cantidad total de fallos obtenidos durante la partida y se muestra en los otros dos displays de 7 segmentos. Cada vez que la FSM ingrese al estado Fallos Sube, este contador aumentará en uno.
- Contador de Fallos Consecutivos: Este contador se utiliza para determinar cuándo termina la partida. Cada fallo incrementa su valor en uno, mientras que un acierto lo reinicia a cero. Al alcanzar tres fallos consecutivos, la FSM pasará al estado Game Over.

#### Game Over y RESET
Para esta sección simplemente se requiere el designar cada uno de los estados del juego:
- Game Over: Se alcanza cuando el jugador acumula tres fallos consecutivos. El sistema permanece en este estado durante al menos 2 segundos, indicando mediante el LED de estado que la partida ha terminado. Una vez transcurrido este tiempo, se reinician los valores correspondientes a la partida y la FSM vuelve a "Llamada Topo".
- RESET: Corresponde a una condición global activada mediante el botón físico central de la tarjeta. Puede ejecutarse desde cualquier estado y provoca el reinicio inmediato de los valores asociados a la partida, llevando nuevamente la FSM a "Llamada Topo".

Optimized tool selectionVoy a revisar los archivos principales del proyecto para describir correctamente la estructura y el comportamiento del sistema antes de redactarte la explicación.

#### Estructura código
- La parte de entrada está formada por los 8 botones externos, que se sincronizan y se filtran con un circuito de debounce para evitar pulsos espurios. Cada botón se interpreta como una posición de topo, y la lógica de detección produce una señal de “BotonValido” junto con el valor del botón pulsado.
- La señal SW0 permite seleccionar entre una UART real o una simulación interna. Cuando se activa, se genera una validación de recepción UART para simular la respuesta del circuito externo, y así iniciar o continuar el flujo del juego.
- La FSM principal es el núcleo del sistema. Maneja estados como solicitud de nuevo topo, espera de recepción, topo activo, acierto, fallo, tiempo agotado, verificación de fallos y game over. En cada transición, decide si se solicita el siguiente topo, si el jugador acertó, si aumenta la dificultad o si se termina la partida.
- El módulo de generación del topo produce una posición aleatoria mediante un LFSR. Esa posición se entrega como TopoPosicion cuando llega una señal de validación UART, y la compara con la pulsación del jugador. Si coinciden, se considera acierto; si no, fallo.
- El temporizador mide el tiempo durante el cual el topo está activo. El valor máximo depende del nivel de dificultad, que aumenta progresivamente tras cada acierto. Cuando se supera el tiempo permitido, se considera “TiempoFuera” y se contabiliza como fallo.
- Los contadores llevan el registro de aciertos totales, fallos totales y fallos consecutivos. Si el jugador falla tres veces seguidas, se activa la pantalla de game over.
- La lógica de Game Over genera una ventana de espera de 2 segundos antes de reiniciar la partida, y luego vuelve a la fase inicial para comenzar otra ronda.
- La dificultad se calcula en función del número de aciertos. A medida que aumenta el nivel, el tiempo disponible para responder se reduce, haciendo el juego más exigente.
- La salida visual se realiza con LEDs y un display de 7 segmentos. Los LEDs indican el estado del sistema y la posición del topo activo, mientras que el display multiplexado presenta los contadores de aciertos y fallos de forma legible.

### Subsistema de transmisión UART
#### Diseño 
El sistema de transmisión de la UART se compone de un bloque generador de baud rate, un bloque contador generador de estados y de lógica combinacional, un registro de desplazamiento y un MUX que selecciona la salida. El bloque generador de baud rate está compuesto por un oscilador astable con NE555 que oscila a una frecuencia de 38.4kHz, esta frecuencia es dividida por un contador 74LS161 entre cuatro para obtener un baud rate de 9600bps, este valor fue escogido por ser un valor estándar usado comúnmente y por ser relativamente bajo en comparación con otros valores comunes. El bloque generador de estados y de lógica combinacional se compone por un contador BCD 74LS162 el cual controla distintos elementos según el numero en que se encuentre por medio de compuertas NOR, OR, XNOR y AND. Los elementos controlados por el contador y las expresiones de las compuertas se muestran a continuación:

<div align="center">
<img src="./ImagenesDocu/TablaCompuertas.png" width="400" height="600">
</div>

$$ Idle =\neg{Q_B} \cdot \neg{Q_C} \cdot \neg(Q_A \oplus Q_D) $$

$$ Load = Q_B + Q_C + Q_D$$

$$ Reset =  Q_A + Q_B + Q_C + Q_D$$

$$ S = Q_B + Q_C + Q_D $$


Tal como se explica en el documento de diseño el contador se pone así mismo en reset al llegar a 0, en este estado la línea de “Idle” se mantiene en 1 en la primera entrada del MUX 2:1, por esta razón “S” (selección de línea del MUX) también mantiene esta línea escogida durante el “estado 0”, el “Load” del Shift register se mantiene en 0, esperando para guardar los datos que provienen de LFSR. Al recibir la señal de “siguiente topo” a través de una OR, el contador BCD sale del reset y al llegar el siguiente flanco la línea de “Idle” se convierte en 0 para generar el bit de inicio, pero antes tanto el “Idle” como “S” pasan por un flip-flop tipo D para sincronizarse, al igual que el “Load” y reset, por los tiempos de propagación de las compuertas y el tiempo de estabilidad requerido para que el valor sea actualizado en el flanco por el contador y registro de desplazamiento.    

El diseño general con compuertas se muestra a continuación:

<div align="center">
<img src="./ImagenesDocu/Circuito compuertas.png" width="900" height="1100">
</div>

El diseño general con integrados se muestra a continuación:

<div align="center">
<img src="./ImagenesDocu/Circuito integrados.png" width="900" height="1100">
</div>

#### Simulaciones 
En las simulaciones realizadas en multisim, se logro generar la señal de transmisión de forma correcta proando con distintos valores. en la siguiente imagen se muestra una señal transmisión con la siguiente secuencia:

| Bit / Campo | Start | A (LSB) | B | C | D | E | F | G | H (MSB) | Stop |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Valor** | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |

<div align="center">
<img src="./ImagenesDocu/SimulacionTX.png" width="800" height="600">
</div>

#### Mediciones 
Se realizaron mediciones experimentales para definir el porcentaje de error conjunto de los módulos UART. El reloj de frecuencia de la FPGA es los suficientemente preciso para dejar la mayor parte del margen de error a la parte de transmisión, que al estar formada por elementos menos precisos se alejaba más de los valores ideales. En la siguiente imagen se muestra el resultado del divisor de baud rate:
Cálculo del porcentaje de error de la UART de recepción:

<div align="center">
<img src="./ImagenesDocu/Reloj.jpg" width="800" height="600">
</div>

$$ f_{UART} = \frac{f_{FpgaClock}}{(16 \times (BRG+1)} $$

Con un BRG = 650 aproximado a partir de la misma formula y un reloj de la FPGA de 100MHz:

$$ f_{UART} = 9600.61 $$
$$ Error_{UART} = 0.006 \% $$

Cálculo del porcentaje de error de la UART de transmisión:
$$ f_{UART}) = \frac{f_{FpgaClock}}{(16 \times (BRG+1)} $$

Se puede observar que el valor del módulo de recepción es extremadamente mas bajo que el del módulo de transmisión, cuyo reloj es mucho menos preciso que el de la FPGA, esto permite que el porcentaje de error se mantenga apenas por debajo del porcentaje de error máximo recomendado de 5% [1], lo que facilitaría una lectura correcta de los datos sin que el receptor lea datos incorrectos.

La implementación de esta sección genero problemas, ya que algunos elementos funcionaban por separado únicamente, y al conectar el conjunto la señal se distorsionaba haciendo imposible la medición y transmisión de datos. A continuación, se muestran algunas señales distorsionadas que se observaron mientras se buscaba el problema:  

<div align="center">
<img src="./ImagenesDocu/SimulacionError.jpg" width="800" height="600">
</div>

## Resultados
#### Subsistema de Control
- Se logra crear la maquina de estados correspondiente a la lógica necesaria de juego.
- Se logra crear la función de reloj correspondiente a todo el sistema de manera general, además de lograr las restricciones temporales para cada uno de los niveles de dificultad sin utilizar diferentes relojes.
- Se logra la implementación de la función de los displays además de la funcionalidad de las LEDs de la FPGA
- Se logra la implementación física de los botones externos, además de lograr la sincronización y el debounce de los inputs.
- Se logra la implementación de un sistema de pruebas para la FPGA y el subsistema de control de manera aislada, por lo que se puede revisar el subsistema por si solo.

#### Subsistema de transmisión (Sistema discreto)
El módulo de transmisión de la UART no logro aplicarse exitosamente a pesar de modificaciones, como cambios de baud rate y de lógica. Al aplicar cambios en el baud rate se observó una mejor calidad de señal en el osciloscopio, calidad que conservó al pasar por otras compuertas. Los cambios de lógica se realizaron de forma experimental, por lo que no se realizó una simulación previa, el objetivo de este cambio fue comprobar si la calidad de la señal se esta viendo perjudicada por la cantidad de compuertas que se esta utilizando, o si una de estas podría estar generando el problema de comunicación, tras la reducción de compuertas mejoro la calidad de la señal transmitida. Es posible que el problema fuese tanto el número y elección de compuertas como la velocidad de la tasa de transmisión de bits.
- Se logra diseñar un modulo generador de baud rate exitosamente.
- Se generan las salidas correctas del contador generador de estados.
- Se genera un resultado correcto en la simulación.
- El circuito construido generaba señales ruidosas y deformes en todo el circuito al conectar la lógica.
- Tras ajustes de lógica y baud rate se logró mejorar la calidad de la señal, sin embargo, no se logró la transmisión de datos.

### Conclusión
En este proyecto se llevó a cabo la implementación de un juego por medio de sistemas descritos en HDL y sintetizados en una FPGA, y sistemas de lógica discreta. Para los sistemas descritos en HDL se logró desarrollar una solución aplicando y reforzando conocimientos de cursos pasados sobre el diseño de máquinas de estado, lógica combinacional, FPGA y SystemVerilog, logrando llegar a una solución que lograse cumplir con los requerimientos del proyecto. Se logro implementar una maquina de estados que controlara la secuencia de el juego, el aumento progresivo de la dificultad, la implementación de botones externos y su sincronización, el uso de displays e incluso la simulación de la parte de lógica discreta.
Para el sistema discreto, se logro diseñar un subsistema LFSR que genera posiciones de forma pseudoaleatoria, enciende los leds acorde a la misma y con la capacidad de transmitir los 8 bits de forma paralela al registro de desplazamiento. El subsistema de transmisión de la UART no se logró implementar físicamente a pesar de funcionar en la simulación, es posible la velocidad de envío de bits escogida para este módulo no fuese la ideal y que el diseño cargado de compuertas e integrados y la elección especifica de sus modelos dificultara la ubicación real del problema. En futuros diseños se optará por un diseño mas eficiente y menos propenso a errores en la medida de lo posible, también se realizara el proceso de búsqueda de errores de una forma más eficiente en cada módulo, además, se considerara detenidamente la elección de una velocidad de operación del circuito más apta. 

### Fuentes
[1]   David Harris y Sarah Harris. Digital Design and Computer Architecture. RISC-V
      Edition. Morgan Kaufmann, 2022, pagina 564. ´ ISBN: 978-0-12-820064-3.

[2] 	TI Precision Labs – Microcontrollers “UART Protocol Overview”, sf. [online]: 
      https://www.ti.com/content/dam/videos/external-videos/zh-tw/9/3816841626001/6313217959112.mp4/subassets/uart_protocol_overview_and_error_sources_0.pdf

[3] 	R. Xie, "Design and Simulation of UART Protocol Based on FPGA," 2024 6th International Conference on Applied Machine Learning (ICAML), Dalian, China, 2024,        pp. 551-557, doi:   10.1109/ICAML64299.2024.00103.

[4] 	W. Huang and G. Sheng, "Analysis and Research on UART Communication Protocol," 2024 4th Asia-Pacific Conference on Communications Technology and Computer          Science (ACCTCS), Shenyang, China, 2024, pp. 768-771, doi: 10.1109/ACCTCS61748.2024.00140. 
