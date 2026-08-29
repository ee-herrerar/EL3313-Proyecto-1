`timescale 1ns / 1ps

module Debouncer_tb;

    logic clk;
    logic btn_in;
    logic btn_out;

    debounce DUT (
        .clk(clk),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );

    // Reloj de 100 MHz => periodo 10 ns
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic wait_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask

    task automatic check_eq(input logic expected, input string msg);
        if (btn_out !== expected) begin
            $error("ERROR: %s | esperado=%0b | real=%0b", msg, expected, btn_out);
        end else begin
            $display("PASS: %s", msg);
        end
    endtask

    initial begin
        $display("Inicio de la simulacion del debounce");

        // Estado inicial estable: el botón está en 0 y el debounce debe
        // terminar en 0 antes de evaluar la primera transición.
        btn_in = 1'b0;
        wait_cycles(1200000);
        check_eq(1'b0, "estado inicial estabilizado en 0");

        // -------------------------------------------------------------------
        // Caso 1: presion limpia (0 -> 1)
        // -------------------------------------------------------------------
        btn_in = 1'b1;
        #200;
        check_eq(1'b0, "salida no cambia en el instante inicial de presion");

        // Debe permanecer estable por > 10.5 ms para aceptar el cambio
        wait_cycles(1200000);
        check_eq(1'b1, "presion limpia genera salida estable en 1");

        // -------------------------------------------------------------------
        // Caso 2: liberacion limpia (1 -> 0)
        // -------------------------------------------------------------------
        btn_in = 1'b0;
        #200;
        check_eq(1'b1, "salida mantiene el valor previo durante la liberacion");

        wait_cycles(1200000);
        check_eq(1'b0, "liberacion limpia genera salida estable en 0");

        // -------------------------------------------------------------------
        // Caso 3: rebote realista durante la presion
        // -------------------------------------------------------------------
        btn_in = 1'b1;
        #100;
        btn_in = 1'b0;
        #40;
        btn_in = 1'b1;
        #60;
        btn_in = 1'b0;
        #80;
        btn_in = 1'b1;
        #120;

        // El rebote no debe producir un cambio inmediato en la salida
        check_eq(1'b0, "rebotes no cambian la salida antes del debounce");

        wait_cycles(1200000);
        check_eq(1'b1, "presion con rebotes termina en salida estable en 1");

        // -------------------------------------------------------------------
        // Caso 4: rebote realista durante la liberacion
        // -------------------------------------------------------------------
        btn_in = 1'b0;
        #120;
        btn_in = 1'b1;
        #50;
        btn_in = 1'b0;
        #70;
        btn_in = 1'b1;
        #90;
        btn_in = 1'b0;
        #110;

        check_eq(1'b1, "rebotes durante la liberacion no cambian la salida antes del debounce");

        wait_cycles(1200000);
        check_eq(1'b0, "liberacion con rebotes termina en salida estable en 0");

        $display("FIN de la simulacion del debounce");
        $finish;
    end

endmodule
