`timescale 1ns / 1ps

module Temporizador_tb;

    // Entradas
    logic        clk;
    logic        RESET;
    logic        TopoActivoOut;
    logic [10:0] TiempoLimite;

    // Salida
    logic        TiempoFuera;


    // Instancia del módulo bajo prueba
    Temporizador DUT (
        .clk(clk),
        .RESET(RESET),
        .TopoActivoOut(TopoActivoOut),
        .TiempoLimite(TiempoLimite),
        .TiempoFuera(TiempoFuera)
    );


    // Reloj de 100 MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    initial begin

        // Valores iniciales
        RESET = 1'b1;
        TopoActivoOut = 1'b0;
        TiempoLimite = 11'd3;


        // ------------------------------------------------
        // Prueba 1: RESET
        // ------------------------------------------------

        #2;

        if ((DUT.ContadorCiclos == 17'd0) &&
            (DUT.ContadorMs == 11'd0) &&
            (TiempoFuera == 1'b0))
            $display("PASS: RESET reinicia el temporizador");
        else
            $error("ERROR: RESET incorrecto");

        RESET = 1'b0;


        // ------------------------------------------------
        // Prueba 2: Fuera de TopoActivo no cuenta
        // ------------------------------------------------

        repeat (10) @(posedge clk);
        #1;

        if ((DUT.ContadorCiclos == 17'd0) &&
            (DUT.ContadorMs == 11'd0) &&
            (TiempoFuera == 1'b0))
            $display("PASS: Fuera de TopoActivo no cuenta");
        else
            $error("ERROR: Temporizador conto fuera de TopoActivo");


        // ------------------------------------------------
        // Prueba 3: Iniciar conteo
        // ------------------------------------------------

        TopoActivoOut = 1'b1;

        repeat (10) @(posedge clk);
        #1;

        if (DUT.ContadorCiclos == 17'd10)
            $display("PASS: ContadorCiclos inicia correctamente");
        else
            $error("ERROR: ContadorCiclos no inicio correctamente");


        // ------------------------------------------------
        // Prueba 4: Primer milisegundo
        // ------------------------------------------------

        repeat (99990) @(posedge clk);
        #1;

        if (DUT.ContadorMs == 11'd1)
            $display("PASS: Primer milisegundo contado correctamente");
        else
            $error("ERROR: Primer milisegundo incorrecto");


        // ------------------------------------------------
        // Prueba 5: Segundo milisegundo
        // ------------------------------------------------

        repeat (100000) @(posedge clk);
        #1;

        if ((DUT.ContadorMs == 11'd2) &&
            (TiempoFuera == 1'b0))
            $display("PASS: Segundo milisegundo contado correctamente");
        else
            $error("ERROR: Segundo milisegundo incorrecto");


        // ------------------------------------------------
        // Prueba 6: TiempoFuera en 3 ms
        // ------------------------------------------------

        repeat (100000) @(posedge clk);
        #1;

        if (TiempoFuera == 1'b1)
            $display("PASS: TiempoFuera se activa al llegar al limite");
        else
            $error("ERROR: TiempoFuera no se activo");


        // ------------------------------------------------
        // Prueba 7: No sigue contando después de TiempoFuera
        // ------------------------------------------------

        repeat (20) @(posedge clk);
        #1;

        if (TiempoFuera == 1'b1)
            $display("PASS: TiempoFuera permanece activo");
        else
            $error("ERROR: TiempoFuera se desactivo inesperadamente");


        // ------------------------------------------------
        // Prueba 8: Salir de TopoActivo reinicia temporizador
        // ------------------------------------------------

        TopoActivoOut = 1'b0;

        @(posedge clk);
        #1;

        if ((DUT.ContadorCiclos == 17'd0) &&
            (DUT.ContadorMs == 11'd0) &&
            (TiempoFuera == 1'b0))
            $display("PASS: Salir de TopoActivo reinicia temporizador");
        else
            $error("ERROR: No se reinicio al salir de TopoActivo");


        // ------------------------------------------------
        // Prueba 9: Puede iniciar un nuevo turno
        // ------------------------------------------------

        TopoActivoOut = 1'b1;

        repeat (100000) @(posedge clk);
        #1;

        if ((DUT.ContadorMs == 11'd1) &&
            (TiempoFuera == 1'b0))
            $display("PASS: Nuevo turno inicia correctamente");
        else
            $error("ERROR: Nuevo turno incorrecto");


        // ------------------------------------------------
        // Fin de pruebas
        // ------------------------------------------------

        $display("------------------------------------");
        $display("FIN DE LAS PRUEBAS DEL TEMPORIZADOR");
        $display("------------------------------------");

        $finish;

    end

endmodule