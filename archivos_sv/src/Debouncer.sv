module debounce(
    input clk,          // Reloj de 100 MHz de la Basys 3 (Pin W5)
    input btn_in,       // Entrada física del botón con rebote
    output reg btn_out  // Salida limpia y filtrada
);

    reg [19:0] contador = 0;
    reg btn_prev = 0;
    
    always @(posedge clk) begin
        if (btn_in != btn_prev) begin
            btn_prev <= btn_in;
            contador <= 0;
        end else if (contador < 20'd1048575) begin
            contador <= contador + 1;
        end else begin
            btn_out <= btn_prev;
        end
    end
endmodule
