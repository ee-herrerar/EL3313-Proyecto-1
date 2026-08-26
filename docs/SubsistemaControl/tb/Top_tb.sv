`timescale 1ns / 1ps

module TopControl_tb;

    // =====================================================
    // Entradas
    // =====================================================

    logic       clk;
    logic       RESET;
    logic [7:0] BotonesRaw;
    logic       UART_RX;


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
    // Parámetros de simulación UART
    //
    // generador_baudios:
    // DIVISOR = 100 MHz / (9600 * 16) = 651
    //
    // 651 ciclos * 16 = 10416 ciclos por bit
    // 10416 * 10 ns = 104160 ns
    // =====================================================

    localparam integer BIT_TIME = 104160;


    // =====================================================
    // DUT
    // =====================================================

    TopControl DUT (
        .clk            (clk),
        .RESET          (RESET),

        .BotonesRaw     (BotonesRaw),

        .UART_RX        (UART_RX),

        .LlamadaTopoOut (LlamadaTopoOut),

        .LED_Activo     (LED_Activo),
        .LED_GameOver   (LED_GameOver),

        .seg            (seg),
        .an             (an),
        .dp             (dp)
    );


    // =====================================================
    // Reloj de 100 MHz
    // =====================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // =====================================================
    // Enviar un byte UART 8N1
    //
    // UART:
    // Idle  = 1
    // Start = 0
    // 8 bits LSB first
    // Stop  = 1
    // =====================================================

    task automatic enviar_byte_uart (
        input logic [7:0] dato
    );

        integer i;

    begin

        // Start bit
        UART_RX = 1'b0;
        #(BIT_TIME);


        // 8 bits de datos, LSB primero
        for (i = 0; i < 8; i = i + 1) begin
            UART_RX = dato[i];
            #(BIT_TIME);
        end


        // Stop bit
        UART_RX = 1'b1;


        // Esperar a que el receptor indique byte completo
        fork : ESPERA_UART

            begin
                wait (DUT.UARTValid === 1'b1);
            end

            begin
                #(BIT_TIME * 2);
                $fatal(
                    1,
                    "ERROR: Timeout esperando UARTValid"
                );
            end

        join_any

        disable ESPERA_UART;


        // Dejar que la FSM capture UARTValid
        @(posedge clk);
        #1;

    end

    endtask


    // =====================================================
    // Enviar posición del topo
    //
    // Solo importan los 3 LSB
    // =====================================================

    task automatic enviar_topo (
        input logic [2:0] posicion
    );

        logic [7:0] dato_uart;

    begin

        dato_uart = {5'b00000, posicion};

        enviar_byte_uart(dato_uart);


        if (DUT.UARTData[2:0] == posicion)
            $display(
                "PASS: UART recibio posicion %0d correctamente",
                posicion
            );
        else
            $error(
                "ERROR: UART recibio posicion incorrecta"
            );


        if (LED_Activo == 1'b1)
            $display(
                "PASS: Posicion %0d lleva a TopoActivo",
                posicion
            );
        else
            $error(
                "ERROR: FSM no entro a TopoActivo"
            );

    end

    endtask


    // =====================================================
    // Presionar botón físico
    //
    // Los botones son activos en bajo:
    //
    // Suelto     = 1
    // Presionado = 0
    // =====================================================

    task automatic presionar_boton (
        input integer numero
    );

    begin

        BotonesRaw[numero] = 1'b0;


        // Esperar:
        // Sync2Step + debounce + Botones
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
    // Esperar solicitud del siguiente topo
    // =====================================================

    task automatic esperar_llamada_topo;

    begin

        fork : ESPERA_LLAMADA

            begin
                wait (LlamadaTopoOut === 1'b1);
            end

            begin
                #2000;

                $fatal(
                    1,
                    "ERROR: FSM no solicito nuevo topo"
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

        // =================================================
        // Valores iniciales
        // =================================================

        RESET      = 1'b1;

        // Botones activos en bajo:
        // todos sueltos inicialmente
        BotonesRaw = 8'b11111111;

        // UART en estado IDLE
        UART_RX    = 1'b1;


        #20;


        // =================================================
        // PRUEBA 1: RESET
        // =================================================

        if ((DUT.AciertosTotales == 7'd0) &&
            (DUT.FallosTotales   == 7'd0) &&
            (LED_GameOver        == 1'b0))
        begin

            $display(
                "PASS: RESET inicial correcto"
            );

        end
        else begin

            $error(
                "ERROR: RESET inicial incorrecto"
            );

        end


        if (dp == 1'b1)
            $display(
                "PASS: Punto decimal apagado"
            );
        else
            $error(
                "ERROR: Punto decimal incorrecto"
            );


        RESET = 1'b0;


        // =================================================
        // PRUEBA 2: Extensor de LlamadaTopo
        //
        // La salida debe permanecer activa mucho más
        // que el pulso original de 10 ns.
        // =================================================

        wait (LlamadaTopoOut === 1'b1);

        #100;

        if (LlamadaTopoOut == 1'b1)
            $display(
                "PASS: LlamadaTopoOut permanece activa mas de 100 ns"
            );
        else
            $error(
                "ERROR: LlamadaTopoOut demasiado corta"
            );


        // Esperar que termine el pulso extendido
        wait (LlamadaTopoOut === 1'b0);


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
        // PRUEBA 3: UART + ACIERTO
        //
        // UART envía posición 3
        // jugador presiona botón 3
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
                "ERROR: Fallo inesperado"
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


        // Esperar que termine LlamadaTopo
        wait (LlamadaTopoOut === 1'b0);


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


        wait (LlamadaTopoOut === 1'b0);


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


        wait (LlamadaTopoOut === 1'b0);


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
                #2000;

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
                "ERROR: RESET no sale de GameOver"
            );


        // =================================================
        // FIN
        // =================================================

        $display(
            "========================================"
        );

        $display(
            "FIN DE PRUEBAS DE TOPCONTROL + UART"
        );

        $display(
            "========================================"
        );


        $finish;

    end

endmodule