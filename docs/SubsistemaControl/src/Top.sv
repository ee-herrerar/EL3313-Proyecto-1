module TopControl(
    input  logic       clk,
    input  logic       RESET,

    // Switch para habilitar la UART simulada
    input  logic       SW0,

    // Botones externos del juego
    input  logic [7:0] BotonesRaw,

    // UART física
    input  logic       UART_RX,

    // Solicitud hacia circuito externo
    output logic       LlamadaTopoOut,

    // LEDs de estado
    output logic       LED_Activo,
    output logic       LED_GameOver,

    // LEDs que representan los 8 topos
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
    // 1 = utilizar SW0 para simular respuestas UART
    // 0 = utilizar la UART física conectada a UART_RX
    //
    // Para la prueba actual dejar en 1.
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
    // SW0 - CONTROL DE UART SIMULADA
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

    logic       UARTValid;


    // ============================================================
    // TOPO
    // ============================================================

    logic [2:0] TopoPosicion;


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
    // SINCRONIZACIÓN Y DEBOUNCE
    // DE LOS 8 BOTONES EXTERNOS
    //
    // Los botones externos son activos en LOW:
    //
    // Suelto      = 1
    // Presionado  = 0
    //
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
    // DECODIFICACIÓN DE LOS BOTONES
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
    //
    // Evita que el rebote mecánico del switch genere varias
    // recepciones UART falsas.
    // ============================================================

    debounce DebounceSW0 (
        .clk     (clk),
        .btn_in  (SW0Sync),
        .btn_out (SW0Debounced)
    );


    // ============================================================
    // UART VALID SIMULADO
    //
    // Hay dos situaciones que generan una respuesta UART:
    //
    // 1. SW0 cambia de 0 -> 1
    //    Esto inicia el juego cuando la FSM ya está esperando.
    //
    // 2. SW0 continúa en 1 y GameFSM genera LlamadaTopoFSM
    //    Esto simula que el circuito externo responde
    //    automáticamente con el siguiente topo.
    //
    // UARTValidSimulado dura solamente 1 ciclo de clk.
    // ============================================================

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin

            SW0Prev           <= 1'b0;
            UARTValidSimulado <= 1'b0;

        end
        else begin

            // Por defecto UARTValid está apagado
            UARTValidSimulado <= 1'b0;


            // ----------------------------------------------------
            // SW0 acaba de encenderse
            // ----------------------------------------------------

            if (SW0Debounced && !SW0Prev) begin

                UARTValidSimulado <= 1'b1;

            end


            // ----------------------------------------------------
            // El juego ya está habilitado
            // y la FSM solicita un nuevo topo
            // ----------------------------------------------------

            else if (SW0Debounced && LlamadaTopoFSM) begin

                UARTValidSimulado <= 1'b1;

            end


            // Guardar estado anterior del switch
            SW0Prev <= SW0Debounced;

        end

    end


    // ============================================================
    // GENERADOR DE BAUDIOS
    //
    // Se conserva porque la UART física sigue formando parte
    // del diseño.
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
    // SELECCIÓN UART
    //
    // Por ahora:
    //
    // UARTValid = UARTValidSimulado
    //
    // En la versión con circuito discreto:
    //
    // UARTValid = UARTValidReal
    // ============================================================

    always_comb begin

        if (USAR_UART_SIMULADA)
            UARTValid = UARTValidSimulado;
        else
            UARTValid = UARTValidReal;

    end


    // ============================================================
    // GENERADOR DE TOPO ALEATORIO
    //
    // Cada recepción UART válida selecciona una nueva
    // posición entre 0 y 7.
    // ============================================================

    GeneradorTopoAleatorio GeneradorTopo_inst (
        .clk          (clk),
        .RESET        (RESET),
        .GenerarTopo  (UARTValid),
        .TopoPosicion (TopoPosicion)
    );


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
    //
    // Extiende el pulso generado por la FSM para la salida
    // física hacia el circuito discreto.
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
        .clk                          (clk),
        .RESET                        (RESET),

        .AciertosSube                 (AciertosSube),
        .FallosSube                   (FallosSube),

        .ReiniciarFallosConsecutivos  (ReiniciarFallosConsecutivos),
        .ReiniciarJuego               (ReiniciarJuego),

        .AciertosTotales              (AciertosTotales),
        .FallosTotales                (FallosTotales),
        .FallosConsecutivos           (FallosConsecutivos)
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
    // Mientras TopoActivoOut = 1:
    //
    // Posición 0 -> LED_Topo[0]
    // Posición 1 -> LED_Topo[1]
    // ...
    // Posición 7 -> LED_Topo[7]
    //
    // Cuando el topo deja de estar activo:
    //
    // LED_Topo = 0000_0000
    // ============================================================

    always_comb begin

        LED_Topo = 8'b0000_0000;

        if (TopoActivoOut) begin
            LED_Topo = 8'b0000_0001 << TopoPosicion;
        end

    end


endmodule