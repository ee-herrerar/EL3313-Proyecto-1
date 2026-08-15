module btn_top(
    input logic clk,
    input logic btn_in,     // Entrada física
    output logic btn_out    // Salida sincronizada y sin rebote
);
    
    logic btn_sync;
    
    btn_synchronizer synchronizer(
        .clk(clk),
        .btn_in(btn_in),
        .btn_out(btn_sync)
    );
    
    btn_debouncer debouncer(
        .clk(clk),
        .btn_in(btn_sync),
        .btn_out(btn_out)
    );
endmodule

