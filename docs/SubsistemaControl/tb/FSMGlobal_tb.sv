`timescale 1ns / 1ps

module GameFSM_tb;

    // Entradas
    logic       clk;
    logic       RESET;
    logic       UARTValid;
    logic [2:0] TopoPosicion;
    logic [2:0] TopoJugador;
    logic       BotonValido;
    logic       TiempoFuera;
    logic [1:0] FallosConsecutivos;
    logic       GameOverDone;

    // Salidas
    logic       LlamadaTopoOut;
    logic       TopoActivoOut;
    logic       AciertosSube;
    logic       FallosSube;
    logic       ReiniciarFallosConsecutivos;
    logic       ReajusteRelojOut;
    logic       GameOverOut;
    logic       ReiniciarJuego;


    // Estados utilizados para verificar la FSM
    localparam [3:0] LlamadaTopo     = 4'b0000,
                     EsperaTopo      = 4'b0001,
                     TopoActivo      = 4'b0010,
                     Acierto         = 4'b0011,
                     AciertoSube     = 4'b0100,
                     ReajusteReloj   = 4'b0101,
                     Tiempo          = 4'b0110,
                     Fallo           = 4'b0111,
                     FalloSube       = 4'b1000,
                     VerificarFallos = 4'b1001,
                     GameOver        = 4'b1010;


    // Instancia del módulo bajo prueba
    GameFSM DUT (
        .clk(clk),
        .RESET(RESET),

        .UARTValid(UARTValid),
        .TopoPosicion(TopoPosicion),
        .TopoJugador(TopoJugador),
        .BotonValido(BotonValido),
        .TiempoFuera(TiempoFuera),
        .FallosConsecutivos(FallosConsecutivos),
        .GameOverDone(GameOverDone),

        .LlamadaTopoOut(LlamadaTopoOut),
        .TopoActivoOut(TopoActivoOut),
        .AciertosSube(AciertosSube),
        .FallosSube(FallosSube),
        .ReiniciarFallosConsecutivos(ReiniciarFallosConsecutivos),
        .ReajusteRelojOut(ReajusteRelojOut),
        .GameOverOut(GameOverOut),
        .ReiniciarJuego(ReiniciarJuego)
    );


    // Reloj de 100 MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // Generación de estímulos
    initial begin

        // Valores iniciales
        RESET = 1'b1;
        UARTValid = 1'b0;
        TopoPosicion = 3'b000;
        TopoJugador = 3'b000;
        BotonValido = 1'b0;
        TiempoFuera = 1'b0;
        FallosConsecutivos = 2'b00;
        GameOverDone = 1'b0;


        // ------------------------------------------------
        // Prueba 1: RESET
        // ------------------------------------------------

        #2;

        if (DUT.current_state == LlamadaTopo)
            $display("PASS: RESET lleva a LlamadaTopo");
        else
            $error("ERROR: RESET no lleva a LlamadaTopo");

        RESET = 1'b0;


        // ------------------------------------------------
        // Prueba 2: LlamadaTopo -> EsperaTopo
        // ------------------------------------------------

        @(posedge clk);
        #1;

        if (DUT.current_state == EsperaTopo)
            $display("PASS: LlamadaTopo -> EsperaTopo");
        else
            $error("ERROR: No paso a EsperaTopo");


        // ------------------------------------------------
        // Prueba 3: EsperaTopo permanece sin UARTValid
        // ------------------------------------------------

        @(posedge clk);
        #1;

        if (DUT.current_state == EsperaTopo)
            $display("PASS: EsperaTopo espera UARTValid");
        else
            $error("ERROR: EsperaTopo cambio sin UARTValid");


        // ------------------------------------------------
        // Prueba 4: UARTValid -> TopoActivo
        // ------------------------------------------------

        UARTValid = 1'b1;

        @(posedge clk);
        #1;

        UARTValid = 1'b0;

        if (DUT.current_state == TopoActivo)
            $display("PASS: UARTValid lleva a TopoActivo");
        else
            $error("ERROR: UARTValid no llevo a TopoActivo");


        // ------------------------------------------------
        // Prueba 5: Acierto
        // ------------------------------------------------

        TopoPosicion = 3'b101;
        TopoJugador = 3'b101;
        BotonValido = 1'b1;

        @(posedge clk);
        #1;

        BotonValido = 1'b0;

        if (DUT.current_state == Acierto)
            $display("PASS: Boton correcto -> Acierto");
        else
            $error("ERROR: Boton correcto no llevo a Acierto");


        // Acierto -> AciertoSube
        @(posedge clk);
        #1;

        if ((DUT.current_state == AciertoSube) &&
            (AciertosSube == 1'b1) &&
            (ReiniciarFallosConsecutivos == 1'b1))
            $display("PASS: AciertoSube genera salidas correctas");
        else
            $error("ERROR: AciertoSube incorrecto");


        // AciertoSube -> ReajusteReloj
        @(posedge clk);
        #1;

        if ((DUT.current_state == ReajusteReloj) &&
            (ReajusteRelojOut == 1'b1))
            $display("PASS: ReajusteReloj correcto");
        else
            $error("ERROR: ReajusteReloj incorrecto");


        // ReajusteReloj -> LlamadaTopo
        @(posedge clk);
        #1;


        // LlamadaTopo -> EsperaTopo
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Nueva posición para probar fallo
        // ------------------------------------------------

        UARTValid = 1'b1;

        @(posedge clk);
        #1;

        UARTValid = 1'b0;

        TopoPosicion = 3'b010;
        TopoJugador = 3'b111;
        BotonValido = 1'b1;


        // ------------------------------------------------
        // Prueba 6: Botón incorrecto
        // ------------------------------------------------

        @(posedge clk);
        #1;

        BotonValido = 1'b0;

        if (DUT.current_state == Fallo)
            $display("PASS: Boton incorrecto -> Fallo");
        else
            $error("ERROR: Boton incorrecto no llevo a Fallo");


        // Fallo -> FalloSube
        @(posedge clk);
        #1;

        if ((DUT.current_state == FalloSube) &&
            (FallosSube == 1'b1))
            $display("PASS: FalloSube genera salida correcta");
        else
            $error("ERROR: FalloSube incorrecto");


        // Simula la actualización del contador externo
        FallosConsecutivos = 2'b01;


        // FalloSube -> VerificarFallos
        @(posedge clk);
        #1;

        if (DUT.current_state == VerificarFallos)
            $display("PASS: FalloSube -> VerificarFallos");
        else
            $error("ERROR: No paso a VerificarFallos");


        // VerificarFallos -> LlamadaTopo
        @(posedge clk);
        #1;

        if (DUT.current_state == LlamadaTopo)
            $display("PASS: Menos de 3 fallos permite continuar");
        else
            $error("ERROR: Verificacion de fallos incorrecta");


        // ------------------------------------------------
        // Prueba 7: TiempoFuera
        // ------------------------------------------------

        // LlamadaTopo -> EsperaTopo
        @(posedge clk);
        #1;

        UARTValid = 1'b1;

        // EsperaTopo -> TopoActivo
        @(posedge clk);
        #1;

        UARTValid = 1'b0;
        TiempoFuera = 1'b1;

        // TopoActivo -> Tiempo
        @(posedge clk);
        #1;

        TiempoFuera = 1'b0;

        if (DUT.current_state == Tiempo)
            $display("PASS: TiempoFuera -> Tiempo");
        else
            $error("ERROR: TiempoFuera no llevo a Tiempo");


        // Tiempo -> FalloSube
        @(posedge clk);
        #1;

        if (DUT.current_state == FalloSube)
            $display("PASS: Tiempo -> FalloSube");
        else
            $error("ERROR: Tiempo no llevo a FalloSube");


        // ------------------------------------------------
        // Prueba 8: Tercer fallo -> GameOver
        // ------------------------------------------------

        FallosConsecutivos = 2'b11;

        // FalloSube -> VerificarFallos
        @(posedge clk);
        #1;

        // VerificarFallos -> GameOver
        @(posedge clk);
        #1;

        if ((DUT.current_state == GameOver) &&
            (GameOverOut == 1'b1))
            $display("PASS: 3 fallos consecutivos -> GameOver");
        else
            $error("ERROR: No entro a GameOver");


        // ------------------------------------------------
        // Prueba 9: Permanecer en GameOver
        // ------------------------------------------------

        @(posedge clk);
        #1;

        if ((DUT.current_state == GameOver) &&
            (ReiniciarJuego == 1'b0))
            $display("PASS: GameOver espera GameOverDone");
        else
            $error("ERROR: GameOver termino antes de tiempo");


        // ------------------------------------------------
        // Prueba 10: ReiniciarJuego
        // ------------------------------------------------

        GameOverDone = 1'b1;

        // Como ReiniciarJuego es combinacional,
        // debe activarse mientras GameOverDone está activo
        #1;

        if (ReiniciarJuego == 1'b1)
            $display("PASS: GameOverDone activa ReiniciarJuego");
        else
            $error("ERROR: ReiniciarJuego no se activo");


        // ------------------------------------------------
        // Prueba 11: GameOver -> LlamadaTopo
        // ------------------------------------------------

        @(posedge clk);
        #1;

        GameOverDone = 1'b0;

        if (DUT.current_state == LlamadaTopo)
            $display("PASS: GameOverDone -> LlamadaTopo");
        else
            $error("ERROR: GameOverDone no reinicio la FSM");


        // ReiniciarJuego debe volver a cero
        if (ReiniciarJuego == 1'b0)
            $display("PASS: ReiniciarJuego vuelve a 0");
        else
            $error("ERROR: ReiniciarJuego permanecio activo");


        $display("------------------------------------");
        $display("FIN DE LAS PRUEBAS DE GameFSM");
        $display("------------------------------------");

        $finish;

    end

endmodule