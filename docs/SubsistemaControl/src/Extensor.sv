module ExtensorLlamadaTopo (
    input  logic clk,
    input  logic RESET,
    input  logic LlamadaTopoIn,

    output logic LlamadaTopoOut
);

    // 100 MHz -> 100000 ciclos = 1 ms
    logic [16:0] Contador;


    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin
            Contador         <= 17'd0;
            LlamadaTopoOut   <= 1'b0;
        end

        // La FSM genera el pulso original
        else if (LlamadaTopoIn && !LlamadaTopoOut) begin
            Contador         <= 17'd0;
            LlamadaTopoOut   <= 1'b1;
        end

        // Mientras el pulso extendido esté activo
        else if (LlamadaTopoOut) begin

            if (Contador == 17'd99999) begin
                Contador       <= 17'd0;
                LlamadaTopoOut <= 1'b0;
            end

            else begin
                Contador <= Contador + 17'd1;
            end

        end

        else begin
            Contador <= 17'd0;
        end

    end

endmodule