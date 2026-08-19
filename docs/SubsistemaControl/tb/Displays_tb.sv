`timescale 1ns / 1ps

module Display7Seg_tb;

    logic       clk;
    logic       RESET;
    logic [6:0] AciertosTotales;
    logic [6:0] FallosTotales;

    logic [6:0] seg;
    logic [3:0] an;
    logic       dp;


    // =====================================================
    // DUT
    // =====================================================

    Display7Seg DUT (
        .clk              (clk),
        .RESET            (RESET),
        .AciertosTotales  (AciertosTotales),
        .FallosTotales    (FallosTotales),
        .seg              (seg),
        .an               (an),
        .dp               (dp)
    );


    // =====================================================
    // Reloj de 100 MHz
    // =====================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // =====================================================
    // Pruebas
    // =====================================================

    initial begin

        RESET           = 1'b1;
        AciertosTotales = 7'd23;
        FallosTotales   = 7'd7;

        #20;
        RESET = 1'b0;

        // -------------------------------------------------
        // Punto decimal apagado
        // -------------------------------------------------

        #1;

        if (dp == 1'b1)
            $display("PASS: Punto decimal apagado");
        else
            $error("ERROR: Punto decimal incorrecto");


        // =================================================
        // Caso:
        //
        // Aciertos = 23
        // Fallos   = 07
        //
        // Display esperado:
        //
        // [2][3][0][7]
        // =================================================


        // -------------------------------------------------
        // AN0 -> unidades de fallos = 7
        // -------------------------------------------------

        wait (DUT.SelectorDisplay == 2'b00);
        #1;

        if ((an == 4'b1110) &&
            (seg == 7'b0001111))
            $display("PASS: Fallos unidades = 7");
        else
            $error("ERROR: Fallos unidades incorrecto");


        // -------------------------------------------------
        // AN1 -> decenas de fallos = 0
        // -------------------------------------------------

        wait (DUT.SelectorDisplay == 2'b01);
        #1;

        if ((an == 4'b1101) &&
            (seg == 7'b0000001))
            $display("PASS: Fallos decenas = 0");
        else
            $error("ERROR: Fallos decenas incorrecto");


        // -------------------------------------------------
        // AN2 -> unidades de aciertos = 3
        // -------------------------------------------------

        wait (DUT.SelectorDisplay == 2'b10);
        #1;

        if ((an == 4'b1011) &&
            (seg == 7'b0000110))
            $display("PASS: Aciertos unidades = 3");
        else
            $error("ERROR: Aciertos unidades incorrecto");


        // -------------------------------------------------
        // AN3 -> decenas de aciertos = 2
        // -------------------------------------------------

        wait (DUT.SelectorDisplay == 2'b11);
        #1;

        if ((an == 4'b0111) &&
            (seg == 7'b0010010))
            $display("PASS: Aciertos decenas = 2");
        else
            $error("ERROR: Aciertos decenas incorrecto");


        // =================================================
        // Prueba del valor máximo: 99 / 99
        // =================================================

        AciertosTotales = 7'd99;
        FallosTotales   = 7'd99;


        // Esperamos volver a AN0
        wait (DUT.SelectorDisplay == 2'b00);
        #1;

        if ((an == 4'b1110) &&
            (seg == 7'b0000100))
            $display("PASS: Fallos unidades = 9");
        else
            $error("ERROR: Fallos unidades para 99 incorrecto");


        wait (DUT.SelectorDisplay == 2'b01);
        #1;

        if ((an == 4'b1101) &&
            (seg == 7'b0000100))
            $display("PASS: Fallos decenas = 9");
        else
            $error("ERROR: Fallos decenas para 99 incorrecto");


        wait (DUT.SelectorDisplay == 2'b10);
        #1;

        if ((an == 4'b1011) &&
            (seg == 7'b0000100))
            $display("PASS: Aciertos unidades = 9");
        else
            $error("ERROR: Aciertos unidades para 99 incorrecto");


        wait (DUT.SelectorDisplay == 2'b11);
        #1;

        if ((an == 4'b0111) &&
            (seg == 7'b0000100))
            $display("PASS: Aciertos decenas = 9");
        else
            $error("ERROR: Aciertos decenas para 99 incorrecto");


        // =================================================
        // Fin
        // =================================================

        $display("--------------------------------");
        $display("FIN DE PRUEBAS DISPLAY 7 SEG");
        $display("--------------------------------");

        $finish;

    end

endmodule