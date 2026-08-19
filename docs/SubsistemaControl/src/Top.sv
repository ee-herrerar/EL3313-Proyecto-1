module TopControl (
    input  logic       clk,
    input  logic       RESET,

    // 8 botones físicos
    input  logic [7:0] BotonesRaw,

    // Entradas temporales
    // Más adelante vendrán del UART_RX
    input  logic       UARTValid,
    input  logic [2:0] TopoPosicion,

    // Solicitud de una nueva posición del topo
    output logic       LlamadaTopoOut,

    // LEDs de estado
    output logic       LED_Activo,
    output logic       LED_GameOver,

    // Contadores
    output logic [6:0] AciertosTotales,
    output logic [6:0] FallosTotales
);


    // =====================================================
    // Señales internas
    // =====================================================

    logic [7:0] BotonesSync;
    logic [7:0] BotonesDebounced;

    logic       BotonValido;
    logic [2:0] TopoJugador;

    logic       TopoActivoOut;

    logic       AciertosSube;
    logic       FallosSube;

    logic       ReiniciarFallosConsecutivos;
    logic       ReajusteRelojOut;

    logic       GameOverOut;
    logic       GameOverDone;
    logic       ReiniciarJuego;

    logic [1:0] FallosConsecutivos;

    logic [3:0]  NivelDificultad;
    logic [10:0] TiempoLimite;

    logic       TiempoFuera;


    // =====================================================
    // Sincronización de los 8 botones
    // =====================================================

    genvar i;

    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_SYNC

            Sync2Step sync_inst (
                .clk          (clk),
                .reset        (RESET),
                .async_signal (BotonesRaw[i]),
                .sync_signal  (BotonesSync[i])
            );

        end
    endgenerate


    // =====================================================
    // Debounce de los 8 botones
    // =====================================================

    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_DEBOUNCE

            debounce debounce_inst (
                .clk     (clk),
                .btn_in  (BotonesSync[i]),
                .btn_out (BotonesDebounced[i])
            );

        end
    endgenerate


    // =====================================================
    // Procesamiento de botones
    // =====================================================

    Botones botones_inst (
        .clk               (clk),
        .RESET             (RESET),
        .BotonesDebounced  (BotonesDebounced),

        .BotonValido       (BotonValido),
        .TopoJugador       (TopoJugador)
    );


    // =====================================================
    // FSM principal
    // =====================================================

    GameFSM fsm_inst (
        .clk                           (clk),
        .RESET                         (RESET),

        .UARTValid                     (UARTValid),
        .TopoPosicion                  (TopoPosicion),

        .TopoJugador                   (TopoJugador),
        .BotonValido                   (BotonValido),

        .TiempoFuera                   (TiempoFuera),

        .FallosConsecutivos            (FallosConsecutivos),

        .GameOverDone                  (GameOverDone),

        .LlamadaTopoOut                (LlamadaTopoOut),
        .TopoActivoOut                 (TopoActivoOut),

        .AciertosSube                  (AciertosSube),
        .FallosSube                    (FallosSube),

        .ReiniciarFallosConsecutivos   (ReiniciarFallosConsecutivos),

        .ReajusteRelojOut              (ReajusteRelojOut),

        .GameOverOut                   (GameOverOut),
        .ReiniciarJuego                (ReiniciarJuego)
    );


    // =====================================================
    // Contadores
    // =====================================================

    contadores contadores_inst (
        .clk                           (clk),
        .RESET                         (RESET),

        .AciertosSube                  (AciertosSube),
        .FallosSube                    (FallosSube),

        .ReiniciarFallosConsecutivos   (ReiniciarFallosConsecutivos),
        .ReiniciarJuego                (ReiniciarJuego),

        .AciertosTotales               (AciertosTotales),
        .FallosTotales                 (FallosTotales),
        .FallosConsecutivos            (FallosConsecutivos)
    );


    // =====================================================
    // Control de dificultad
    // =====================================================

    Dificultad dificultad_inst (
        .clk               (clk),
        .RESET             (RESET),

        .ReajusteRelojOut  (ReajusteRelojOut),
        .ReiniciarJuego    (ReiniciarJuego),

        .NivelDificultad   (NivelDificultad),
        .TiempoLimite      (TiempoLimite)
    );


    // =====================================================
    // Temporizador del topo
    // =====================================================

    Temporizador temporizador_inst (
        .clk            (clk),
        .RESET          (RESET),

        .TopoActivoOut  (TopoActivoOut),
        .TiempoLimite   (TiempoLimite),

        .TiempoFuera    (TiempoFuera)
    );


    // =====================================================
    // Pantalla / temporizador de Game Over
    // =====================================================

    GameOverScreen gameover_inst (
        .clk           (clk),
        .RESET         (RESET),

        .GameOverOut   (GameOverOut),

        .GameOverDone  (GameOverDone)
    );


    // =====================================================
    // LEDs
    // =====================================================

    assign LED_Activo   = TopoActivoOut;
    assign LED_GameOver = GameOverOut;


endmodule