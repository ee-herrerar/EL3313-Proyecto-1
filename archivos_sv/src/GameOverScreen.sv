module GameOverScreen #(
    parameter integer TIEMPO_GAMEOVER_MS = 2000
)(
    input  logic clk,
    input  logic RESET,
    input  logic GameOverOut,

    output logic GameOverDone
);

    logic [16:0] ContadorCiclos;
    logic [10:0] ContadorMs;
    logic        CE_1ms;

    // 100 MHz -> 100000 ciclos = 1 ms
    assign CE_1ms = GameOverOut &&
                    (ContadorCiclos == 17'd99999);


    // Contador de ciclos
    always_ff @(posedge clk or posedge RESET) begin
        if (RESET) begin
            ContadorCiclos <= 17'd0;
        end

        else if (!GameOverOut) begin
            ContadorCiclos <= 17'd0;
        end

        else if (GameOverDone) begin
            ContadorCiclos <= 17'd0;
        end

        else if (CE_1ms) begin
            ContadorCiclos <= 17'd0;
        end

        else begin
            ContadorCiclos <= ContadorCiclos + 17'd1;
        end
    end


    // Contador de milisegundos
    always_ff @(posedge clk or posedge RESET) begin
        if (RESET) begin
            ContadorMs   <= 11'd0;
            GameOverDone <= 1'b0;
        end

        else if (!GameOverOut) begin
            ContadorMs   <= 11'd0;
            GameOverDone <= 1'b0;
        end

        else if (CE_1ms && !GameOverDone) begin
            if ((ContadorMs + 11'd1) >= TIEMPO_GAMEOVER_MS) begin
                GameOverDone <= 1'b1;
            end

            else begin
                ContadorMs <= ContadorMs + 11'd1;
            end
        end
    end

endmodule
