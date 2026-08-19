`timescale 1ns / 1ps

module Botones_tb;

    logic       clk;
    logic       RESET;
    logic [7:0] BotonesDebounced;

    logic       BotonValido;
    logic [2:0] TopoJugador;


    // Módulo bajo prueba
    Botones DUT (
        .clk(clk),
        .RESET(RESET),
        .BotonesDebounced(BotonesDebounced),
        .BotonValido(BotonValido),
        .TopoJugador(TopoJugador)
    );


    // Reloj de 100 MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    initial begin

        RESET = 1'b1;
        BotonesDebounced = 8'b00000000;

        #20;
        RESET = 1'b0;

        // ------------------------------------------------
        // Prueba 1: RESET
        // ------------------------------------------------
        #1;

        if ((BotonValido == 1'b0) &&
            (TopoJugador == 3'd0))
            $display("PASS: RESET correcto");
        else
            $error("ERROR: RESET incorrecto");


        // ------------------------------------------------
        // Prueba 2: Botón 0
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00000001;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd0))
            $display("PASS: Boton 0 detectado correctamente");
        else
            $error("ERROR: Boton 0 incorrecto");


        // Mantener botón presionado
        @(posedge clk);
        #1;

        if (BotonValido == 1'b0)
            $display("PASS: Mantener boton no genera otro pulso");
        else
            $error("ERROR: BotonValido permanece activo");


        // Soltar botón
        BotonesDebounced <= 8'b00000000;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 3: Botón 1
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00000010;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd1))
            $display("PASS: Boton 1 detectado correctamente");
        else
            $error("ERROR: Boton 1 incorrecto");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 4: Botón 2
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00000100;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd2))
            $display("PASS: Boton 2 detectado correctamente");
        else
            $error("ERROR: Boton 2 incorrecto");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 5: Botón 3
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00001000;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd3))
            $display("PASS: Boton 3 detectado correctamente");
        else
            $error("ERROR: Boton 3 incorrecto");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 6: Botón 4
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00010000;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd4))
            $display("PASS: Boton 4 detectado correctamente");
        else
            $error("ERROR: Boton 4 incorrecto");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 7: Botón 5
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00100000;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd5))
            $display("PASS: Boton 5 detectado correctamente");
        else
            $error("ERROR: Boton 5 incorrecto");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 8: Botón 6
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b01000000;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd6))
            $display("PASS: Boton 6 detectado correctamente");
        else
            $error("ERROR: Boton 6 incorrecto");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 9: Botón 7
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b10000000;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd7))
            $display("PASS: Boton 7 detectado correctamente");
        else
            $error("ERROR: Boton 7 incorrecto");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 10: Dos botones simultáneos
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00000110;
        #1;

        if (BotonValido == 1'b0)
            $display("PASS: Dos botones simultaneos son invalidos");
        else
            $error("ERROR: Se aceptaron dos botones simultaneos");

        BotonesDebounced <= 8'b0;
        @(posedge clk);
        #1;


        // ------------------------------------------------
        // Prueba 11: Se puede volver a presionar el mismo botón
        // ------------------------------------------------
        @(posedge clk);
        BotonesDebounced <= 8'b00001000;
        #1;

        if ((BotonValido == 1'b1) &&
            (TopoJugador == 3'd3))
            $display("PASS: Nueva pulsacion se detecta correctamente");
        else
            $error("ERROR: No se detecto nueva pulsacion");


        $display("--------------------------------");
        $display("FIN DE PRUEBAS DE BOTONES");
        $display("--------------------------------");

        $finish;

    end

endmodule