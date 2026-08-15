module btn_synchronizer(
    input logic clk,
    input logic btn_in,         // Entrada física del botón
    output logic btn_out        // Entrada sincronizada
);
    logic q1 = 0;
    logic q2 = 0;
    
    always @(posedge clk) begin
        q1 <= btn_in;
        q2 <= q1;
    end
    
    assign btn_out = q2;
endmodule
