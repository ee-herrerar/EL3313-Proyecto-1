`timescale 1ns / 1ps

module Dificultad_tb;

    // Entradas
    logic clk;
    logic RESET;
    logic ReajusteRelojOut;
    logic ReiniciarJuego;

    // Salidas
    logic [3:0]  NivelDificultad;
    logic [10:0] TiempoLimite;


    // Instancia del módulo bajo prueba
    Dificultad DUT (
        .clk(clk),
        .RESET(RESET),
        .ReajusteRelojOut(ReajusteRelojOut),
        .ReiniciarJuego(ReiniciarJuego),

        .NivelDificultad(NivelDificultad),
        .TiempoLimite(TiempoLimite)
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
        ReajusteRelojOut = 1'b0;
        ReiniciarJuego = 1'b0;


        // ------------------------------------------------
        // Prueba 1: RESET
        // ------------------------------------------------

        #2;

        if ((NivelDificultad == 4'd0) &&
            (TiempoLimite == 11'd1500))
            $display("PASS: RESET coloca dificultad en nivel 0 y 1500 ms");
        else
            $error("ERROR: RESET incorrecto");

        RESET = 1'b0;


        // ------------------------------------------------
        // Prueba 2: Subir al nivel 1
        // ------------------------------------------------

        ReajusteRelojOut = 1'b1;

        @(posedge clk);
        #1;

        ReajusteRelojOut = 1'b0;

        if ((NivelDificultad == 4'd1) &&
            (TiempoLimite == 11'd1400))
            $display("PASS: Nivel 1 corresponde a 1400 ms");
        else
            $error("ERROR: Nivel 1 incorrecto");


        // ------------------------------------------------
        // Prueba 3: Subir al nivel 2
        // ------------------------------------------------

        ReajusteRelojOut = 1'b1;

        @(posedge clk);
        #1;

        ReajusteRelojOut = 1'b0;

        if ((NivelDificultad == 4'd2) &&
            (TiempoLimite == 11'd1300))
            $display("PASS: Nivel 2 corresponde a 1300 ms");
        else
            $error("ERROR: Nivel 2 incorrecto");


        // ------------------------------------------------
        // Prueba 4: Llegar al nivel máximo
        // ------------------------------------------------

        repeat (8) begin
            ReajusteRelojOut = 1'b1;

            @(posedge clk);
            #1;

            ReajusteRelojOut = 1'b0;
        end

        if ((NivelDificultad == 4'd10) &&
            (TiempoLimite == 11'd500))
            $display("PASS: Nivel 10 corresponde a 500 ms");
        else
            $error("ERROR: Nivel maximo incorrecto");


        // ------------------------------------------------
        // Prueba 5: Saturación en nivel 10
        // ------------------------------------------------

        repeat (3) begin
            ReajusteRelojOut = 1'b1;

            @(posedge clk);
            #1;

            ReajusteRelojOut = 1'b0;
        end

        if ((NivelDificultad == 4'd10) &&
            (TiempoLimite == 11'd500))
            $display("PASS: NivelDificultad se limita a 10");
        else
            $error("ERROR: NivelDificultad supero el nivel 10");


        // ------------------------------------------------
        // Prueba 6: ReiniciarJuego
        // ------------------------------------------------

        ReiniciarJuego = 1'b1;

        @(posedge clk);
        #1;

        ReiniciarJuego = 1'b0;

        if ((NivelDificultad == 4'd0) &&
            (TiempoLimite == 11'd1500))
            $display("PASS: ReiniciarJuego vuelve a nivel 0 y 1500 ms");
        else
            $error("ERROR: ReiniciarJuego incorrecto");


        // ------------------------------------------------
        // Fin de las pruebas
        // ------------------------------------------------

        $display("------------------------------------");
        $display("FIN DE LAS PRUEBAS DE DIFICULTAD");
        $display("------------------------------------");

        $finish;

    end

endmodule