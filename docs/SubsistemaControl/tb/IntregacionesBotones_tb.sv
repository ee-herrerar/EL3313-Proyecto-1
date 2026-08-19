`timescale 1ns / 1ps

module BotonesIntegracion_tb;

    logic clk;
    logic RESET;

    logic [7:0] BotonesRaw;
    logic [7:0] BotonesSync;
    logic [7:0] BotonesDebounced;

    logic       BotonValido;
    logic [2:0] TopoJugador;


    // ------------------------------------------------
    // Reloj de 100 MHz
    // ------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ------------------------------------------------
    // 8 sincronizadores
    // ------------------------------------------------

    genvar i;

    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_SYNC

            Sync2Step sync_inst (
                .clk(clk),
                .reset(RESET),
                .async_signal(BotonesRaw[i]),
                .sync_signal(BotonesSync[i])
            );

        end
    endgenerate


    // ------------------------------------------------
    // 8 debouncers
    // ------------------------------------------------

    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_DEBOUNCE

            debounce debounce_inst (
                .clk(clk),
                .btn_in(BotonesSync[i]),
                .btn_out(BotonesDebounced[i])
            );

        end
    endgenerate


    // ------------------------------------------------
    // Módulo Botones
    // ------------------------------------------------

    Botones DUT (
        .clk(clk),
        .RESET(RESET),
        .BotonesDebounced(BotonesDebounced),
        .BotonValido(BotonValido),
        .TopoJugador(TopoJugador)
    );


    // ------------------------------------------------
    // Pruebas
    // ------------------------------------------------

    initial begin

        RESET      = 1'b1;
        BotonesRaw = 8'b00000000;

        #20;
        RESET = 1'b0;


        // ------------------------------------------------
        // Esperar que los debouncers se estabilicen en 0
        // ------------------------------------------------

        wait (BotonesDebounced === 8'b00000000);

        $display("PASS: Entradas estabilizadas correctamente");


        // ------------------------------------------------
        // Prueba botón 3 con un pequeño rebote
        // ------------------------------------------------

        BotonesRaw[3] = 1'b1;

        // Rebote corto
        repeat (100) @(posedge clk);
        BotonesRaw[3] = 1'b0;

        repeat (100) @(posedge clk);
        BotonesRaw[3] = 1'b1;


        // Esperar hasta que pase el debounce
        wait (BotonValido === 1'b1);

        #1;

        if (TopoJugador == 3'd3)
            $display("PASS: Boton 3 atraveso Sync + Debounce + Botones");
        else
            $error("ERROR: Boton 3 fue identificado incorrectamente");


        // ------------------------------------------------
        // BotonValido debe durar un solo ciclo
        // ------------------------------------------------

        @(posedge clk);
        #1;

        if (BotonValido == 1'b0)
            $display("PASS: BotonValido dura solamente un ciclo");
        else
            $error("ERROR: BotonValido permanece activo");


        // ------------------------------------------------
        // Soltar botón
        // ------------------------------------------------

        BotonesRaw[3] = 1'b0;

        wait (BotonesDebounced[3] === 1'b0);

        $display("PASS: Liberacion del boton detectada correctamente");


        // ------------------------------------------------
        // Probar otro botón
        // ------------------------------------------------

        BotonesRaw[6] = 1'b1;

        wait (BotonValido === 1'b1);

        #1;

        if (TopoJugador == 3'd6)
            $display("PASS: Boton 6 detectado correctamente");
        else
            $error("ERROR: Boton 6 incorrecto");


        // ------------------------------------------------
        // Fin
        // ------------------------------------------------

        $display("--------------------------------");
        $display("FIN DE PRUEBAS DE INTEGRACION");
        $display("--------------------------------");

        $finish;

    end

endmodule