module TopControl(
    input  logic       clk,
    input  logic       RESET,

    // Switch para habilitar la prueba aislada
    input  logic       SW0,

    // Botones externos del juego
    input  logic [7:0] BotonesRaw,

    // UART física proveniente del circuito discreto
    input  logic       UART_RX,

    // Solicitud de nuevo topo hacia el circuito discreto
    output logic       LlamadaTopoOut,

    // LEDs de estado
    output logic       LED_Activo,
    output logic       LED_GameOver,

    // LEDs temporales para visualizar los 8 topos
    output logic [7:0] LED_Topo,

    // Display de 7 segmentos
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic       dp
);


    // ============================================================
    // CONFIGURACIÓN
    // ============================================================
    //
    // 1 -> Prueba aislada:
    //      SW0 simula respuestas UART y la FPGA genera el topo.
    //
    // 0 -> Versión final:
    //      UART_RX recibe la posición desde el circuito discreto.
    //
    // Para las pruebas actuales dejar en 1.
    // ============================================================

    localparam logic USAR_UART_SIMULADA = 1'b1;


    // ============================================================
    // BOTONES EXTERNOS
    // ============================================================

    logic [7:0] BotonesSync;
    logic [7:0] BotonesDebounced;

    logic       BotonValido;
    logic [2:0] TopoJugador;


    // ============================================================
    // SW0 - PRUEBA AISLADA
    // ============================================================

    logic SW0Sync;
    logic SW0Debounced;
    logic SW0Prev;

    logic UARTValidSimulado;


    // ============================================================
    // UART FÍSICA
    // ============================================================

    logic       s_tick;
    logic       UARTValidReal;
    logic [7:0] UARTData;


    // ============================================================
    // SEÑALES SELECCIONADAS PARA LA FSM
    // ============================================================

    logic       UARTValid;

    logic [2:0] TopoPosicion;
    logic [2:0] TopoPosicionAleatoria;


    // ============================================================
    // FSM
    // ============================================================

    logic LlamadaTopoFSM;
    logic TopoActivoOut;

    logic AciertosSube;
    logic FallosSube;

    logic ReiniciarFallosConsecutivos;
    logic ReajusteRelojOut;

    logic GameOverOut;
    logic GameOverDone;
    logic ReiniciarJuego;

    logic TiempoFuera;


    // ============================================================
    // CONTADORES
    // ============================================================

    logic [6:0] AciertosTotales;
    logic [6:0] FallosTotales;
    logic [1:0] FallosConsecutivos;


    // ============================================================
    // DIFICULTAD
    // ============================================================

    logic [3:0]  NivelDificultad;
    logic [10:0] TiempoLimite;


    // ============================================================
    // SINCRONIZACIÓN Y DEBOUNCE DE BOTONES EXTERNOS
    //
    // Los botones externos son activos en LOW.
    // Por eso se invierten antes del sincronizador.
    // ============================================================

    genvar i;

    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_BOTONES

            Sync2Step SyncBoton (
                .clk          (clk),
                .reset        (RESET),
                .async_signal (~BotonesRaw[i]),
                .sync_signal  (BotonesSync[i])
            );

            debounce DebounceBoton (
                .clk     (clk),
                .btn_in  (BotonesSync[i]),
                .btn_out (BotonesDebounced[i])
            );

        end
    endgenerate


    // ============================================================
    // DECODIFICACIÓN DE BOTONES
    // ============================================================

    Botones Botones_inst (
        .clk              (clk),
        .RESET            (RESET),
        .BotonesDebounced (BotonesDebounced),
        .BotonValido      (BotonValido),
        .TopoJugador      (TopoJugador)
    );


    // ============================================================
    // SINCRONIZACIÓN DE SW0
    // ============================================================

    Sync2Step SyncSW0 (
        .clk          (clk),
        .reset        (RESET),
        .async_signal (SW0),
        .sync_signal  (SW0Sync)
    );


    // ============================================================
    // DEBOUNCE DE SW0
    // ============================================================

    debounce DebounceSW0 (
        .clk     (clk),
        .btn_in  (SW0Sync),
        .btn_out (SW0Debounced)
    );


    // ============================================================
    // UART VALID SIMULADO
    //
    // SW0 = 0:
    //      No se generan respuestas simuladas.
    //
    // SW0 pasa 0 -> 1:
    //      Se genera la primera respuesta.
    //
    // SW0 permanece en 1:
    //      Cada nueva LlamadaTopoFSM genera automáticamente
    //      una nueva respuesta simulada.
    //
    // UARTValidSimulado dura solamente 1 ciclo.
    // ============================================================

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin

            SW0Prev           <= 1'b0;
            UARTValidSimulado <= 1'b0;

        end
        else begin

            UARTValidSimulado <= 1'b0;

            // Primer inicio del juego
            if (SW0Debounced && !SW0Prev) begin
                UARTValidSimulado <= 1'b1;
            end

            // Solicitudes siguientes
            else if (SW0Debounced && LlamadaTopoFSM) begin
                UARTValidSimulado <= 1'b1;
            end

            SW0Prev <= SW0Debounced;

        end

    end


    // ============================================================
    // GENERADOR DE BAUDIOS
    // ============================================================

    generador_baudios #(
        .SYS_CLK_FREQ (100_000_000),
        .BAUD_RATE    (9600),
        .OVERSAMPLE   (16)
    ) GeneradorBaudios_inst (
        .clk    (clk),
        .reset  (RESET),
        .s_tick (s_tick)
    );


    // ============================================================
    // RECEPTOR UART FÍSICO
    //
    // En modo final:
    //
    // UARTValidReal -> indica byte recibido
    // UARTData[2:0] -> posición enviada por circuito discreto
    // ============================================================

    uart_rx #(
        .DBIT    (8),
        .SB_TICK (16)
    ) UART_RX_inst (
        .clk          (clk),
        .reset        (RESET),
        .rx           (UART_RX),
        .s_tick       (s_tick),
        .rx_done_tick (UARTValidReal),
        .dout         (UARTData)
    );


    // ============================================================
    // GENERADOR DE TOPO PARA PRUEBAS AISLADAS
    //
    // Solo se utiliza cuando USAR_UART_SIMULADA = 1.
    // ============================================================

    GeneradorTopoAleatorio GeneradorTopo_inst (
        .clk          (clk),
        .RESET        (RESET),
        .GenerarTopo  (UARTValidSimulado),
        .TopoPosicion (TopoPosicionAleatoria)
    );


    // ============================================================
    // SELECCIÓN ENTRE MODO DE PRUEBA Y MODO FINAL
    //
    // PRUEBA:
    //
    // SW0
    //  ↓
    // UARTValidSimulado
    //  ↓
    // TopoPosicionAleatoria
    //
    //
    // FINAL:
    //
    // UART_RX
    //  ↓
    // uart_rx
    //  ↓
    // UARTValidReal + UARTData[2:0]
    // ============================================================

    always_comb begin

        if (USAR_UART_SIMULADA) begin

            UARTValid    = UARTValidSimulado;
            TopoPosicion = TopoPosicionAleatoria;

        end
        else begin

            UARTValid    = UARTValidReal;
            TopoPosicion = UARTData[2:0];

        end

    end


    // ============================================================
    // FSM PRINCIPAL
    // ============================================================

    GameFSM GameFSM_inst (
        .clk                         (clk),
        .RESET                       (RESET),

        .UARTValid                   (UARTValid),
        .TopoPosicion                (TopoPosicion),

        .TopoJugador                 (TopoJugador),
        .BotonValido                 (BotonValido),

        .TiempoFuera                 (TiempoFuera),
        .FallosConsecutivos          (FallosConsecutivos),
        .GameOverDone                (GameOverDone),

        .LlamadaTopoOut              (LlamadaTopoFSM),
        .TopoActivoOut               (TopoActivoOut),

        .AciertosSube                (AciertosSube),
        .FallosSube                  (FallosSube),

        .ReiniciarFallosConsecutivos (ReiniciarFallosConsecutivos),
        .ReajusteRelojOut            (ReajusteRelojOut),

        .GameOverOut                 (GameOverOut),
        .ReiniciarJuego              (ReiniciarJuego)
    );


    // ============================================================
    // EXTENSOR DE LLAMADA TOPO
    // ============================================================

    ExtensorLlamadaTopo ExtensorLlamadaTopo_inst (
        .clk            (clk),
        .RESET          (RESET),
        .LlamadaTopoIn  (LlamadaTopoFSM),
        .LlamadaTopoOut (LlamadaTopoOut)
    );


    // ============================================================
    // CONTADORES DEL JUEGO
    // ============================================================

    contadores Contadores_inst (
        .clk                         (clk),
        .RESET                       (RESET),

        .AciertosSube                (AciertosSube),
        .FallosSube                  (FallosSube),

        .ReiniciarFallosConsecutivos (ReiniciarFallosConsecutivos),
        .ReiniciarJuego              (ReiniciarJuego),

        .AciertosTotales             (AciertosTotales),
        .FallosTotales               (FallosTotales),
        .FallosConsecutivos          (FallosConsecutivos)
    );


    // ============================================================
    // DIFICULTAD
    // ============================================================

    Dificultad Dificultad_inst (
        .clk              (clk),
        .RESET            (RESET),

        .ReajusteRelojOut (ReajusteRelojOut),
        .ReiniciarJuego   (ReiniciarJuego),

        .NivelDificultad  (NivelDificultad),
        .TiempoLimite     (TiempoLimite)
    );


    // ============================================================
    // TEMPORIZADOR
    // ============================================================

    Temporizador Temporizador_inst (
        .clk           (clk),
        .RESET         (RESET),

        .TopoActivoOut (TopoActivoOut),
        .TiempoLimite  (TiempoLimite),

        .TiempoFuera   (TiempoFuera)
    );


    // ============================================================
    // GAME OVER
    // ============================================================

    GameOverScreen GameOverScreen_inst (
        .clk          (clk),
        .RESET        (RESET),
        .GameOverOut  (GameOverOut),
        .GameOverDone (GameOverDone)
    );


    // ============================================================
    // DISPLAY DE 7 SEGMENTOS
    // ============================================================

    Display7Seg Display7Seg_inst (
        .clk             (clk),
        .RESET           (RESET),

        .AciertosTotales (AciertosTotales),
        .FallosTotales   (FallosTotales),

        .seg             (seg),
        .an              (an),
        .dp              (dp)
    );


    // ============================================================
    // LEDs DE ESTADO
    // ============================================================

    assign LED_Activo   = TopoActivoOut;
    assign LED_GameOver = GameOverOut;


    // ============================================================
    // LEDs DE LOS TOPOS
    //
    // Estos LEDs sirven tanto para probar la FPGA aisladamente
    // como para observar qué posición recibió por UART durante
    // la integración final.
    // ============================================================

    always_comb begin

        LED_Topo = 8'b0000_0000;

        if (TopoActivoOut) begin
            LED_Topo = 8'b0000_0001 << TopoPosicion;
        end

    end


endmodule