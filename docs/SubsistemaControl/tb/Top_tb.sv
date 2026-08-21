`timescale 1ns / 1ps

module TopControl_tb;

    // =====================================================
    // Entradas
    // =====================================================

    logic       clk;
    logic       RESET;
    logic [7:0] BotonesRaw;

    logic       UARTValid;
    logic [2:0] TopoPosicion;


    // =====================================================
    // Salidas
    // =====================================================

    logic       LlamadaTopoOut;

    logic       LED_Activo;
    logic       LED_GameOver;

    logic [6:0] seg;
    logic [3:0] an;
    logic       dp;


    // =====================================================
    // DUT
    // =====================================================

    TopControl DUT (
        .clk            (clk),
        .RESET          (RESET),

        .BotonesRaw     (BotonesRaw),

        .UARTValid      (UARTValid),
        .TopoPosicion   (TopoPosicion),

        .LlamadaTopoOut (LlamadaTopoOut),

        .LED_Activo     (LED_Activo),
        .LED_GameOver   (LED_GameOver),

        .seg            (seg),
        .an             (an),
        .dp             (dp)
    );


    // =====================================================
    // Reloj 100 MHz
    // =====================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // =====================================================
    // Simular dato recibido desde UART
    // =====================================================

    task automatic enviar_topo (
        input logic [2:0] posicion
    );
    begin

        @(negedge clk);

        TopoPosicion = posicion;
        UARTValid    = 1'b1;

        @(posedge clk);
        #1;

        UARTValid = 1'b0;

        if (LED_Activo == 1'b1)
            $display(
                "PASS: UART posicion %0d lleva a TopoActivo",
                posicion
            );
        else
            $error(
                "ERROR: Posicion %0d no llevo a TopoActivo",
                posicion
            );

    end
    endtask


    // =====================================================
    // Presionar botón
    // =====================================================

    task automatic presionar_boton (
        input integer numero
    );
    begin

        BotonesRaw[numero] = 1'b1;

        fork : ESPERA_BOTON

            begin
                wait (DUT.BotonValido === 1'b1);
            end

            begin
                #15_000_000;

                $fatal(
                    1,
                    "ERROR: Timeout esperando boton %0d",
                    numero
                );
            end

        join_any

        disable ESPERA_BOTON;

        #1;

        if (DUT.TopoJugador == numero)
            $display(
                "PASS: Boton %0d detectado correctamente",
                numero
            );
        else
            $error(
                "ERROR: Boton %0d identificado incorrectamente",
                numero
            );

    end
    endtask


    // =====================================================
    // Esperar nueva solicitud de topo
    // =====================================================

    task automatic esperar_llamada_topo;
    begin

        // Esperar primero a que esté baja para evitar
        // confundirla con un pulso anterior
        if (LlamadaTopoOut == 1'b1)
            wait (LlamadaTopoOut == 1'b0);

        fork : ESPERA_LLAMADA

            begin
                wait (LlamadaTopoOut === 1'b1);
            end

            begin
                #2_000_000;

                $fatal(
                    1,
                    "ERROR: No se genero nueva LlamadaTopoOut"
                );
            end

        join_any

        disable ESPERA_LLAMADA;

        #1;

    end
    endtask


    // =====================================================
    // Programa principal
    // =====================================================

    initial begin

        RESET        = 1'b1;
        BotonesRaw   = 8'b00000000;

        UARTValid    = 1'b0;
        TopoPosicion = 3'd0;


        // =================================================
        // PRUEBA 1: RESET
        // =================================================

        #20;

        if ((DUT.AciertosTotales == 7'd0) &&
            (DUT.FallosTotales   == 7'd0) &&
            (LED_GameOver        == 1'b0))
        begin
            $display("PASS: RESET inicial correcto");
        end
        else begin
            $error("ERROR: RESET inicial incorrecto");
        end


        // El extensor mantiene la salida en 0 durante RESET

        if (LlamadaTopoOut == 1'b0)
            $display(
                "PASS: LlamadaTopoOut permanece en 0 durante RESET"
            );
        else
            $error(
                "ERROR: LlamadaTopoOut activa durante RESET"
            );


        if (dp == 1'b1)
            $display("PASS: Punto decimal apagado");
        else
            $error("ERROR: Punto decimal incorrecto");


        // =================================================
        // PRUEBA 2: EXTENSOR DE LLAMADATOPO
        // =================================================

        RESET = 1'b0;


        // Primer flanco después de RESET
        @(posedge clk);
        #1;


        if (LlamadaTopoOut == 1'b1)
            $display(
                "PASS: LlamadaTopoOut se activa despues de RESET"
            );
        else
            $error(
                "ERROR: LlamadaTopoOut no se activo"
            );


        // Después de 99 999 ciclos adicionales todavía debe
        // estar activa.

        repeat (99999) @(posedge clk);
        #1;


        if (LlamadaTopoOut == 1'b1)
            $display(
                "PASS: LlamadaTopoOut permanece activa durante ~1 ms"
            );
        else
            $error(
                "ERROR: Pulso de LlamadaTopoOut demasiado corto"
            );


        // En el siguiente ciclo debe terminar

        @(posedge clk);
        #1;


        if (LlamadaTopoOut == 1'b0)
            $display(
                "PASS: LlamadaTopoOut termina despues de ~1 ms"
            );
        else
            $error(
                "ERROR: LlamadaTopoOut no termino correctamente"
            );


        // =================================================
        // Esperar estabilización de botones
        // =================================================

        fork : ESPERA_DEBOUNCE

            begin
                wait (
                    DUT.BotonesDebounced ===
                    8'b00000000
                );
            end

            begin
                #15_000_000;

                $fatal(
                    1,
                    "ERROR: Debouncers no se estabilizaron"
                );
            end

        join_any

        disable ESPERA_DEBOUNCE;


        $display(
            "PASS: Sistema de botones estabilizado"
        );


        // =================================================
        // PRUEBA 3: ACIERTO
        //
        // Topo = 3
        // Botón = 3
        // =================================================

        enviar_topo(3'd3);

        presionar_boton(3);

        esperar_llamada_topo();


        if (DUT.AciertosTotales == 7'd1)
            $display(
                "PASS: Primer acierto contabilizado"
            );
        else
            $error(
                "ERROR: Primer acierto no contabilizado"
            );


        if (DUT.FallosTotales == 7'd0)
            $display(
                "PASS: No se genero fallo durante el acierto"
            );
        else
            $error(
                "ERROR: Fallo inesperado durante el acierto"
            );


        // =================================================
        // PRUEBA 4: DIFICULTAD
        // =================================================

        if ((DUT.NivelDificultad == 4'd1) &&
            (DUT.TiempoLimite    == 11'd1400))
        begin

            $display(
                "PASS: Dificultad aumenta a nivel 1 / 1400 ms"
            );

        end
        else begin

            $error(
                "ERROR: Dificultad incorrecta"
            );

        end


        // =================================================
        // PRUEBA 5: DISPLAY ACIERTOS = 01
        // =================================================

        wait (
            DUT.display_inst.SelectorDisplay == 2'b10
        );

        #1;


        if ((an  == 4'b1011) &&
            (seg == 7'b1001111))
        begin

            $display(
                "PASS: Display recibe Aciertos = 01"
            );

        end
        else begin

            $error(
                "ERROR: Display de aciertos incorrecto"
            );

        end


        // Esperar que termine el pulso extendido antes
        // de empezar el siguiente turno

        wait (LlamadaTopoOut == 1'b0);


        // =================================================
        // PRUEBA 6: PRIMER FALLO
        //
        // Topo = 2
        // Botón = 4
        // =================================================

        enviar_topo(3'd2);

        presionar_boton(4);

        esperar_llamada_topo();


        if ((DUT.FallosTotales == 7'd1) &&
            (DUT.FallosConsecutivos == 2'd1))
        begin

            $display(
                "PASS: Primer fallo contabilizado"
            );

        end
        else begin

            $error(
                "ERROR: Primer fallo incorrecto"
            );

        end


        // Fallar no cambia dificultad

        if ((DUT.NivelDificultad == 4'd1) &&
            (DUT.TiempoLimite    == 11'd1400))
        begin

            $display(
                "PASS: Fallo no modifica dificultad"
            );

        end
        else begin

            $error(
                "ERROR: Fallo modifico dificultad"
            );

        end


        // =================================================
        // PRUEBA 7: DISPLAY FALLOS = 01
        // =================================================

        wait (
            DUT.display_inst.SelectorDisplay == 2'b00
        );

        #1;


        if ((an  == 4'b1110) &&
            (seg == 7'b1001111))
        begin

            $display(
                "PASS: Display recibe Fallos = 01"
            );

        end
        else begin

            $error(
                "ERROR: Display de fallos incorrecto"
            );

        end


        wait (LlamadaTopoOut == 1'b0);


        // =================================================
        // PRUEBA 8: SEGUNDO FALLO
        //
        // Topo = 5
        // Botón = 6
        // =================================================

        enviar_topo(3'd5);

        presionar_boton(6);

        esperar_llamada_topo();


        if ((DUT.FallosTotales == 7'd2) &&
            (DUT.FallosConsecutivos == 2'd2))
        begin

            $display(
                "PASS: Segundo fallo consecutivo correcto"
            );

        end
        else begin

            $error(
                "ERROR: Segundo fallo incorrecto"
            );

        end


        wait (LlamadaTopoOut == 1'b0);


        // =================================================
        // PRUEBA 9: TERCER FALLO -> GAME OVER
        //
        // Topo = 1
        // Botón = 7
        // =================================================

        enviar_topo(3'd1);

        presionar_boton(7);


        fork : ESPERA_GAMEOVER

            begin
                wait (LED_GameOver === 1'b1);
            end

            begin
                #1000;

                $fatal(
                    1,
                    "ERROR: No se entro a GameOver"
                );
            end

        join_any

        disable ESPERA_GAMEOVER;

        #1;


        if ((DUT.FallosTotales == 7'd3) &&
            (DUT.FallosConsecutivos == 2'd3))
        begin

            $display(
                "PASS: Tercer fallo contabilizado"
            );

        end
        else begin

            $error(
                "ERROR: Tercer fallo incorrecto"
            );

        end


        if (LED_GameOver == 1'b1)
            $display(
                "PASS: Tres fallos consecutivos llevan a GameOver"
            );
        else
            $error(
                "ERROR: GameOver no se activo"
            );


        if (LED_Activo == 1'b0)
            $display(
                "PASS: Topo inactivo durante GameOver"
            );
        else
            $error(
                "ERROR: Topo sigue activo durante GameOver"
            );


        // =================================================
        // PRUEBA 10: RESET DURANTE GAME OVER
        // =================================================

        RESET = 1'b1;

        #2;


        if ((DUT.AciertosTotales == 7'd0) &&
            (DUT.FallosTotales   == 7'd0))
        begin

            $display(
                "PASS: RESET limpia contadores"
            );

        end
        else begin

            $error(
                "ERROR: RESET no limpio contadores"
            );

        end


        if ((DUT.NivelDificultad == 4'd0) &&
            (DUT.TiempoLimite    == 11'd1500))
        begin

            $display(
                "PASS: RESET restaura dificultad inicial"
            );

        end
        else begin

            $error(
                "ERROR: RESET no restauro dificultad"
            );

        end


        if (LED_GameOver == 1'b0)
            $display(
                "PASS: RESET sale de GameOver"
            );
        else
            $error(
                "ERROR: RESET no salio de GameOver"
            );


        // Nueva diferencia:
        // durante RESET el extensor debe estar apagado

        if (LlamadaTopoOut == 1'b0)
            $display(
                "PASS: LlamadaTopoOut se limpia con RESET"
            );
        else
            $error(
                "ERROR: LlamadaTopoOut no se limpio con RESET"
            );


        // =================================================
        // PRUEBA 11: NUEVA LLAMADA DESPUÉS DE RESET
        // =================================================

        RESET = 1'b0;

        @(posedge clk);
        #1;


        if (LlamadaTopoOut == 1'b1)
            $display(
                "PASS: Despues de RESET se genera nueva solicitud de topo"
            );
        else
            $error(
                "ERROR: No se genero solicitud despues de RESET"
            );


        // =================================================
        // Fin
        // =================================================

        $display("========================================");
        $display("FIN DE PRUEBAS DE TOPCONTROL");
        $display("========================================");

        $finish;

    end

endmodule