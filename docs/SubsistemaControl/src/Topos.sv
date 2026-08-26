module GeneradorTopoAleatorio(
    input  logic       clk,
    input  logic       RESET,
    input  logic       GenerarTopo,
    output logic [2:0] TopoPosicion
);

    logic [7:0] LFSR;
    logic       Feedback;

    assign Feedback =
        LFSR[7] ^
        LFSR[5] ^
        LFSR[4] ^
        LFSR[3];

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin

            // Semilla distinta de cero
            LFSR         <= 8'hA5;
            TopoPosicion <= 3'd0;

        end
        else begin

            // El LFSR cambia continuamente.
            //
            // Así, el instante en que llegue la UART determina
            // qué posición será capturada.
            LFSR <= {
                LFSR[6:0],
                Feedback
            };

            // Una recepción UART válida genera un nuevo topo.
            if (GenerarTopo) begin
                TopoPosicion <= LFSR[2:0];
            end

        end

    end

endmodule