`timescale 1ns/1ps

module Sync2Step_tb;

    // Señales del testbench
    logic clk;
    logic reset;
    logic async_signal;
    logic sync_signal;

    // Instancia del módulo bajo prueba
    Sync2Step DUT (
        .clk          (clk),
        .reset        (reset),
        .async_signal (async_signal),
        .sync_signal  (sync_signal)
    );

    // Reloj de 100 MHz
    // Periodo = 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Pruebas
    initial begin

        // Valores iniciales
        reset        = 1;
        async_signal = 0;

        // Mantener reset durante dos ciclos
        repeat (2) @(posedge clk);
        #1;

        // Verificar reset
        if (sync_signal !== 1'b0)
            $error("ERROR: sync_signal no se reinicio correctamente");
        else
            $display("PASS: Reset correcto");

        // Desactivar reset
        reset = 0;

        // ---------------------------------------------
        // PRUEBA 1: Cambio de 0 a 1
        // ---------------------------------------------

        #7;
        async_signal = 1;

        // Primera etapa
        @(posedge clk);
        #1;

        if (sync_signal !== 1'b0)
            $error("ERROR: La salida cambio antes de completar las dos etapas");

        // Segunda etapa
        @(posedge clk);
        #1;

        if (sync_signal !== 1'b1)
            $error("ERROR: No se sincronizo correctamente el valor 1");
        else
            $display("PASS: Sincronizacion 0 -> 1 correcta");

        // ---------------------------------------------
        // PRUEBA 2: Cambio de 1 a 0
        // ---------------------------------------------

        #7;
        async_signal = 0;

        // Primera etapa
        @(posedge clk);
        #1;

        if (sync_signal !== 1'b1)
            $error("ERROR: La salida cambio antes de completar las dos etapas");

        // Segunda etapa
        @(posedge clk);
        #1;

        if (sync_signal !== 1'b0)
            $error("ERROR: No se sincronizo correctamente el valor 0");
        else
            $display("PASS: Sincronizacion 1 -> 0 correcta");

        // ---------------------------------------------
        // Fin
        // ---------------------------------------------

        $display("---------------------------------------");
        $display("Pruebas de Sync2Step finalizadas");
        $display("---------------------------------------");

        $finish;

    end

endmodule