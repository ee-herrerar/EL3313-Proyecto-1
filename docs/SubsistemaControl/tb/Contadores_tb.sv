`timescale 1ns / 1ps

module contadores_tb;

    // Entradas
    logic clk;
    logic RESET;
    logic AciertosSube;
    logic FallosSube;
    logic ReiniciarFallosConsecutivos;
    logic ReiniciarJuego;

    // Salidas
    logic [6:0] AciertosTotales;
    logic [6:0] FallosTotales;
    logic [1:0] FallosConsecutivos;


    // Instancia del módulo bajo prueba
    contadores DUT (
        .clk(clk),
        .RESET(RESET),
        .AciertosSube(AciertosSube),
        .FallosSube(FallosSube),
        .ReiniciarFallosConsecutivos(ReiniciarFallosConsecutivos),
        .ReiniciarJuego(ReiniciarJuego),

        .AciertosTotales(AciertosTotales),
        .FallosTotales(FallosTotales),
        .FallosConsecutivos(FallosConsecutivos)
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
        AciertosSube = 1'b0;
        FallosSube = 1'b0;
        ReiniciarFallosConsecutivos = 1'b0;
        ReiniciarJuego = 1'b0;


        // ------------------------------------------------
        // Prueba 1: RESET
        // ------------------------------------------------

        #2;

        if ((AciertosTotales == 7'd0) &&
            (FallosTotales == 7'd0) &&
            (FallosConsecutivos == 2'd0))
            $display("PASS: RESET reinicia todos los contadores");
        else
            $error("ERROR: RESET no reinicio correctamente");

        RESET = 1'b0;


        // ------------------------------------------------
        // Prueba 2: Incrementar un acierto
        // ------------------------------------------------

        AciertosSube = 1'b1;

        @(posedge clk);
        #1;

        AciertosSube = 1'b0;

        if (AciertosTotales == 7'd1)
            $display("PASS: AciertosTotales incrementa correctamente");
        else
            $error("ERROR: AciertosTotales no incremento");


        // ------------------------------------------------
        // Prueba 3: Incrementar un fallo
        // ------------------------------------------------

        FallosSube = 1'b1;

        @(posedge clk);
        #1;

        FallosSube = 1'b0;

        if ((FallosTotales == 7'd1) &&
            (FallosConsecutivos == 2'd1))
            $display("PASS: Fallo incrementa total y consecutivos");
        else
            $error("ERROR: Incremento de fallos incorrecto");


        // ------------------------------------------------
        // Prueba 4: Segundo fallo consecutivo
        // ------------------------------------------------

        FallosSube = 1'b1;

        @(posedge clk);
        #1;

        FallosSube = 1'b0;

        if ((FallosTotales == 7'd2) &&
            (FallosConsecutivos == 2'd2))
            $display("PASS: Segundo fallo consecutivo correcto");
        else
            $error("ERROR: Segundo fallo incorrecto");


        // ------------------------------------------------
        // Prueba 5: Reiniciar fallos consecutivos
        // ------------------------------------------------

        ReiniciarFallosConsecutivos = 1'b1;

        @(posedge clk);
        #1;

        ReiniciarFallosConsecutivos = 1'b0;

        if ((FallosConsecutivos == 2'd0) &&
            (FallosTotales == 7'd2))
            $display("PASS: Reinicio de fallos consecutivos correcto");
        else
            $error("ERROR: Reinicio de fallos consecutivos incorrecto");


        // ------------------------------------------------
        // Prueba 6: Un acierto también reinicia consecutivos
        // ------------------------------------------------

        // Generar un fallo primero
        FallosSube = 1'b1;

        @(posedge clk);
        #1;

        FallosSube = 1'b0;

        // Generar acierto
        AciertosSube = 1'b1;

        @(posedge clk);
        #1;

        AciertosSube = 1'b0;

        if ((AciertosTotales == 7'd2) &&
            (FallosConsecutivos == 2'd0))
            $display("PASS: Acierto reinicia fallos consecutivos");
        else
            $error("ERROR: Acierto no reinicio fallos consecutivos");


        // ------------------------------------------------
        // Prueba 7: ReiniciarJuego
        // ------------------------------------------------

        ReiniciarJuego = 1'b1;

        @(posedge clk);
        #1;

        ReiniciarJuego = 1'b0;

        if ((AciertosTotales == 7'd0) &&
            (FallosTotales == 7'd0) &&
            (FallosConsecutivos == 2'd0))
            $display("PASS: ReiniciarJuego reinicia todos los contadores");
        else
            $error("ERROR: ReiniciarJuego incorrecto");


        // ------------------------------------------------
        // Prueba 8: Saturación de FallosConsecutivos en 3
        // ------------------------------------------------

        repeat (5) begin
            FallosSube = 1'b1;

            @(posedge clk);
            #1;
        end

        FallosSube = 1'b0;

        if (FallosConsecutivos == 2'd3)
            $display("PASS: FallosConsecutivos se limita a 3");
        else
            $error("ERROR: FallosConsecutivos supero o no llego a 3");


        // ------------------------------------------------
        // Limpiar antes de pruebas de saturación
        // ------------------------------------------------

        ReiniciarJuego = 1'b1;

        @(posedge clk);
        #1;

        ReiniciarJuego = 1'b0;


        // ------------------------------------------------
        // Prueba 9: Saturación de AciertosTotales en 99
        // ------------------------------------------------

        repeat (105) begin
            AciertosSube = 1'b1;

            @(posedge clk);
            #1;
        end

        AciertosSube = 1'b0;

        if (AciertosTotales == 7'd99)
            $display("PASS: AciertosTotales se limita a 99");
        else
            $error("ERROR: AciertosTotales no se limito a 99");


        // ------------------------------------------------
        // Reiniciar antes de probar fallos totales
        // ------------------------------------------------

        ReiniciarJuego = 1'b1;

        @(posedge clk);
        #1;

        ReiniciarJuego = 1'b0;


        // ------------------------------------------------
        // Prueba 10: Saturación de FallosTotales en 99
        // ------------------------------------------------

        repeat (105) begin
            FallosSube = 1'b1;

            @(posedge clk);
            #1;
        end

        FallosSube = 1'b0;

        if ((FallosTotales == 7'd99) &&
            (FallosConsecutivos == 2'd3))
            $display("PASS: FallosTotales se limita a 99 y consecutivos a 3");
        else
            $error("ERROR: Saturacion de fallos incorrecta");


        // ------------------------------------------------
        // Fin de pruebas
        // ------------------------------------------------

        $display("------------------------------------");
        $display("FIN DE LAS PRUEBAS DE CONTADORES");
        $display("------------------------------------");

        $finish;

    end

endmodule