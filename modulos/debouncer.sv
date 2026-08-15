module btn_debouncer(
    input logic clk,            // Reloj de 100 MHz de la Basys 3 
    input logic btn_in,          // Entrada física del botón con rebote
    output logic btn_out        // Salida filtrada
);
    logic [19:0] contador = 0;
    logic btn_prev = 0;
    
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