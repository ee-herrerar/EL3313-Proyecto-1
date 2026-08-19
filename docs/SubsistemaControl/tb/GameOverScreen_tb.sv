`timescale 1ns / 1ps

module GameOverScreen_tb;

    logic clk;
    logic RESET;
    logic GameOverOut;

    logic GameOverDone;


    // Para simulación usamos solamente 3 ms
    GameOverScreen #(
        .TIEMPO_GAMEOVER_MS(3)
    ) DUT (
        .clk(clk),
        .RESET(RESET),
        .GameOverOut(GameOverOut),
        .GameOverDone(GameOverDone)
    );


    // Reloj de 100 MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    initial begin

        RESET = 1'b1;
        GameOverOut = 1'b0;

        #20;
        RESET = 1'b0;


        // Prueba 1: Reset
        if ((DUT.ContadorMs == 0) &&
            (GameOverDone == 0))
            $display("PASS: RESET correcto");
        else
            $error("ERROR: RESET incorrecto");


        // Prueba 2: Fuera de GameOver no cuenta
        repeat (20) @(posedge clk);
        #1;

        if ((DUT.ContadorCiclos == 0) &&
            (DUT.ContadorMs == 0))
            $display("PASS: No cuenta fuera de GameOver");
        else
            $error("ERROR: Cuenta fuera de GameOver");


        // Iniciar GameOver
        GameOverOut = 1'b1;


        // Prueba 3: Primer ms
        repeat (100000) @(posedge clk);
        #1;

        if ((DUT.ContadorMs == 1) &&
            (GameOverDone == 0))
            $display("PASS: Primer ms correcto");
        else
            $error("ERROR: Primer ms incorrecto");


        // Prueba 4: Segundo ms
        repeat (100000) @(posedge clk);
        #1;

        if ((DUT.ContadorMs == 2) &&
            (GameOverDone == 0))
            $display("PASS: Segundo ms correcto");
        else
            $error("ERROR: Segundo ms incorrecto");


        // Prueba 5: Tercer ms -> GameOverDone
        repeat (100000) @(posedge clk);
        #1;

        if (GameOverDone == 1)
            $display("PASS: GameOverDone se activa correctamente");
        else
            $error("ERROR: GameOverDone no se activo");


        // Prueba 6: Se mantiene activo
        repeat (20) @(posedge clk);
        #1;

        if (GameOverDone == 1)
            $display("PASS: GameOverDone permanece activo");
        else
            $error("ERROR: GameOverDone no permanece activo");


        // Prueba 7: Salir de GameOver
        GameOverOut = 1'b0;

        @(posedge clk);
        #1;

        if ((DUT.ContadorCiclos == 0) &&
            (DUT.ContadorMs == 0) &&
            (GameOverDone == 0))
            $display("PASS: Salir de GameOver reinicia el modulo");
        else
            $error("ERROR: No se reinicio correctamente");


        $display("--------------------------------");
        $display("FIN DE PRUEBAS GAMEOVERSCREEN");
        $display("--------------------------------");

        $finish;

    end

endmodule