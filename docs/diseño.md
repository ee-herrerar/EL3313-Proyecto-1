## Subsistema de Control

### Descripción General
El subsistema de control es implementado en la FPGA y es el encargado de manejar la lógica general del juego. Este recibe distintas señales de entrada, como la señal del botón de RESET, la información de la posición del Topo proveniente del circuito discreto mediante UART, las señales correspondientes a los botones de los topos y el reloj global de 100 MHz. A partir de estas entradas, el subsistema se encarga de controlar el funcionamiento del juego, incluyendo la secuencia de estados, la temporización, el conteo de aciertos y fallos, la dificultad y la visualización de los resultados.
### Diagrama de Bloques
![Diagrama de bloques](./ImagenesDocu/DiagramaBloques.png)
### Maquina de Estados
![Máquina de estados](./ImagenesDocu/FSM(Topos).png)


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

### Comunicación UART
Para la comunicación mediante UART RX se tendrá en cuenta que la información proveniente del circuito discreto utiliza un formato 8N1, constituido por un bit de inicio, ocho bits de datos y un bit de parada. De los ocho bits de datos recibidos, únicamente los tres bits menos significativos serán utilizados para representar la posición del Topo, permitiendo codificar las ocho posiciones posibles. Los cinco bits restantes se mantendrán en cero o podrán ser utilizados para otra función que se decida.
Debido a que el circuito discreto y la FPGA operan con referencias de reloj independientes, la señal serial recibida deberá pasar por un sincronizador de dos etapas antes de ser procesada por el receptor UART. Una vez recibida correctamente la trama, el receptor UART generará una señal de dato válido que indicará a la FSM que la posición recibida puede ser utilizada y que se puede continuar con la ejecución del juego. En cuanto al _baud rate_, este se tendrá que ajustar de acuerdo con las necesidades del circuito discreto, por lo que se definirá en una etapa más avanzada.
![Diagrama UART](./ImagenesDocu/DiagramaUART.png)


### Botones de los Topos
El procesamiento de los botones correspondientes a los “huecos” requiere principalmente dos procesos sobre cada una de las señales recibidas:
1. Sincronización de la señal: De manera similar a la señal recibida mediante UART, las señales provenientes de los botones son asíncronas respecto al reloj de la FPGA. Por esta razón, cada una pasará por un sincronizador de dos etapas antes de ser procesada.
2. Debounce: Debido al rebote mecánico producido al presionar los botones, pueden generarse múltiples cambios rápidos de estado durante una sola pulsación. Para evitar que estos sean interpretados como múltiples golpes, se utilizará un módulo de _debounce_ que permitirá obtener una señal estable.
Una vez realizados ambos procesos, las señales filtradas de los ocho botones podrán ser utilizadas por la FSM para determinar si la posición presionada corresponde con la posición del Topo activo.
![Diagrama de Botones](./ImagenesDocu/DiagramaBoton.png)


### Temporizador y Clock Enables
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

### Conteo y Visualización de Resultados
- Contador de Aciertos: Lleva la cantidad total de aciertos obtenidos durante la partida y su valor se muestra en dos de los displays de 7 segmentos. Cada vez que la FSM ingrese al estado Aciertos Sube, el contador aumentará en uno.
- Contador de Fallos: Lleva la cantidad total de fallos obtenidos durante la partida y se muestra en los otros dos displays de 7 segmentos. Cada vez que la FSM ingrese al estado Fallos Sube, este contador aumentará en uno.
- Contador de Fallos Consecutivos: Este contador se utiliza para determinar cuándo termina la partida. Cada fallo incrementa su valor en uno, mientras que un acierto lo reinicia a cero. Al alcanzar tres fallos consecutivos, la FSM pasará al estado Game Over.

### Game Over y RESET
Para esta sección simplemente se requiere el designar cada uno de los estados del juego:
- Game Over: Se alcanza cuando el jugador acumula tres fallos consecutivos. El sistema permanece en este estado durante al menos 2 segundos, indicando mediante el LED de estado que la partida ha terminado. Una vez transcurrido este tiempo, se reinician los valores correspondientes a la partida y la FSM vuelve a "Llamada Topo".
- RESET: Corresponde a una condición global activada mediante el botón físico central de la tarjeta. Puede ejecutarse desde cualquier estado y provoca el reinicio inmediato de los valores asociados a la partida, llevando nuevamente la FSM a "Llamada Topo".
![Diagrama de Game Over y Reset](./ImagenesDocu/DiagramaGOR.png)

### Plan de Pruebas
El plan de pruebas simplemente demostrara el correcto funcionamiento tanto de cada parte individual del sistema como el sistema completo. Para esto se esperara que cada parte designada en el siguiente cuadro realize la función indicada al lado, de ser así, se considera que esa parte funciona correctamente. 

|           Sistema            |                                                         Prueba de funcionamiento a realizar                                                          |
| :--------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------: |
|           UART RX            |                       Se recibe correctamente la información desde el circuito discreto, ya estando sincronizado correctamente                       |
|        Botones Topos         |      Se recibe correctamente la información del botón presionado, además de que la señal fue filtrada correctamente (Debouncer y Sincronizador)      |
| Temporizador y Clock Enables |           Los clock enables son capaces de ajustar correctamente el tiempo de cada Topo según la cantidad de aciertos que tenga el jugador           |
|          Game Over           |                      Si el jugador se equivoca 3 veces consecutivas, el juego despliega correctamente el estado de "Game Over"                       |
|            RESET             |                          El juego es reiniciado correctamente al presionar el botón sin importar en que estado se encuentre                          |
|     Dificultad Correcta      |                  Cada una de las velocidades es correctamente asignada al nivel de dificultad presentado en la tabla de velocidades                  |
|    Conteo y Visualización    | Los contadores suben correctamente cuando el juego alcanza "Fallos Sube" o "Aciertos Sube", además de correctamente visualizar estos en los displays |
|           FSM FPGA           |                        La lógica del juego funciona correctamente, es capaz de moverse de un estado al otro según corresponde                        |
|         Tiempo Fuera         |  Si finaliza la ventana de tiempo sin recibir una pulsación, se registra correctamente un fallo y la FSM continúa con la secuencia correspondiente.  |

