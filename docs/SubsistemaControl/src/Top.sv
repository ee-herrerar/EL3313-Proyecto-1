module TopControl (
    input  logic       clk,
    input  logic       RESET,

    // Botones físicos
    input  logic [7:0] BotonesRaw,

    // Señales provenientes del módulo UART externo
    input  logic       UARTValid,
    input  logic [2:0] TopoPosicion,

    // Solicitud hacia la lógica discreta
    output logic       LlamadaTopoOut,

    // LEDs de estado
    output logic       LED_Activo,
    output logic       LED_GameOver,

    // Display de 7 segmentos
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic       dp
);


    // =====================================================
    // Señales internas - Botones
    // =====================================================

    logic [7:0] BotonesSync;
    logic [7:0] BotonesDebounced;

    logic       BotonValido;
    logic [2:0] TopoJugador;


    // =====================================================
    // Señales internas - FSM
    // =====================================================

    logic TopoActivoOut;

    logic AciertosSube;
    logic FallosSube;

    logic ReiniciarFallosConsecutivos;
    logic ReajusteRelojOut;

    logic GameOverOut;
    logic GameOverDone;
    logic ReiniciarJuego;

    logic TiempoFuera;

    // Pulso original de la FSM
    logic LlamadaTopoFSM;


    // =====================================================
    // Señales internas - Contadores
    // =====================================================

    logic [6:0] AciertosTotales;
    logic [6:0] FallosTotales;
    logic [1:0] FallosConsecutivos;


    // =====================================================
    // Señales internas - Dificultad
    // =====================================================

    logic [3:0]  NivelDificultad;
    logic [10:0] TiempoLimite;


    // =====================================================
    // Sincronización + Debounce de los 8 botones
    // =====================================================

    genvar i;

    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_BOTONES

            Sync2Step sync_inst (
                .clk          (clk),
                .reset        (RESET),
                .async_signal (~BotonesRaw[i]),
                .sync_signal  (BotonesSync[i])
            );


            debounce debounce_inst (
                .clk     (clk),
                .btn_in  (BotonesSync[i]),
                .btn_out (BotonesDebounced[i])
            );

        end
    endgenerate


    // =====================================================
    // Identificación del botón
    // =====================================================

    Botones botones_inst (
        .clk              (clk),
        .RESET            (RESET),
        .BotonesDebounced (BotonesDebounced),

        .BotonValido      (BotonValido),
        .TopoJugador      (TopoJugador)
    );


    // =====================================================
    // FSM principal
    // =====================================================

    GameFSM fsm_inst (
        .clk                         (clk),
        .RESET                       (RESET),

        .UARTValid                   (UARTValid),
        .TopoPosicion                (TopoPosicion),

        .TopoJugador                 (TopoJugador),
        .BotonValido                 (BotonValido),

        .TiempoFuera                 (TiempoFuera),

        .FallosConsecutivos          (FallosConsecutivos),

        .GameOverDone                (GameOverDone),

        // Ahora sale primero a una señal interna
        .LlamadaTopoOut              (LlamadaTopoFSM),

        .TopoActivoOut               (TopoActivoOut),

        .AciertosSube                (AciertosSube),
        .FallosSube                  (FallosSube),

        .ReiniciarFallosConsecutivos (ReiniciarFallosConsecutivos),

        .ReajusteRelojOut            (ReajusteRelojOut),

        .GameOverOut                 (GameOverOut),
        .ReiniciarJuego              (ReiniciarJuego)
    );


    // =====================================================
    // Extensor de LlamadaTopo
    //
    // Convierte el pulso de 1 ciclo de la FSM
    // en un pulso de aproximadamente 1 ms
    // =====================================================

    ExtensorLlamadaTopo extensor_inst (
        .clk            (clk),
        .RESET          (RESET),
        .LlamadaTopoIn  (LlamadaTopoFSM),
        .LlamadaTopoOut (LlamadaTopoOut)
    );


    // =====================================================
    // Contadores
    // =====================================================

    contadores contadores_inst (
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


    // =====================================================
    // Dificultad
    // =====================================================

    Dificultad dificultad_inst (
        .clk              (clk),
        .RESET            (RESET),

        .ReajusteRelojOut (ReajusteRelojOut),
        .ReiniciarJuego   (ReiniciarJuego),

        .NivelDificultad  (NivelDificultad),
        .TiempoLimite     (TiempoLimite)
    );


    // =====================================================
    // Temporizador del topo
    // =====================================================

    Temporizador temporizador_inst (
        .clk           (clk),
        .RESET         (RESET),

        .TopoActivoOut (TopoActivoOut),
        .TiempoLimite  (TiempoLimite),

        .TiempoFuera   (TiempoFuera)
    );


    // =====================================================
    // Temporizador de Game Over
    // =====================================================

    GameOverScreen gameover_inst (
        .clk          (clk),
        .RESET        (RESET),

        .GameOverOut  (GameOverOut),

        .GameOverDone (GameOverDone)
    );


    // =====================================================
    // Displays de 7 segmentos
    // =====================================================

    Display7Seg display_inst (
        .clk             (clk),
        .RESET           (RESET),

        .AciertosTotales (AciertosTotales),
        .FallosTotales   (FallosTotales),

        .seg             (seg),
        .an              (an),
        .dp              (dp)
    );


    // =====================================================
    // LEDs
    // =====================================================

    assign LED_Activo   = TopoActivoOut;
    assign LED_GameOver = GameOverOut;


endmodule