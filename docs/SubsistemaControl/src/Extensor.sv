module ExtensorLlamadaTopo (
    input  logic clk,
    input  logic RESET,
    input  logic LlamadaTopoIn,

    output logic LlamadaTopoOut
);

    // 100 MHz -> 10 ns por ciclo
    // 250 ns -> 25 ciclos
    logic [4:0] Contador;

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin
            Contador        <= 5'd0;
            LlamadaTopoOut  <= 1'b0;
        end

        // Inicia la extensión cuando llega el pulso
        else if (LlamadaTopoIn && !LlamadaTopoOut) begin
            Contador        <= 5'd0;
            LlamadaTopoOut  <= 1'b1;
        end

        // Mantiene la salida activa durante 25 ciclos
        else if (LlamadaTopoOut) begin

            if (Contador == 5'd24) begin
                Contador        <= 5'd0;
                LlamadaTopoOut  <= 1'b0;
            end

            else begin
                Contador <= Contador + 5'd1;
            end

        end

        else begin
            Contador <= 5'd0;
        end

    end

endmodule