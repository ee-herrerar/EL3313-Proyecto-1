module generador_baudios #(
    parameter SYS_CLK_FREQ = 100_000_000, // De la Basys
    parameter BAUD_RATE    = 9600,      // Baud rate
    parameter OVERSAMPLE   = 16
)(
    input  logic clk,
    input  logic reset,
    output logic s_tick
);
    // Calcula el límite del contador para generar el "oversampled tick"
    localparam int DIVISOR = SYS_CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
    localparam int COUNTER_WIDTH = $clog2(DIVISOR);

    logic [COUNTER_WIDTH-1:0] count_reg, count_next;    
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= '0;
        end else begin
            count_reg <= count_next;
        end
    end

    always_comb begin
        count_next = count_reg + 1'b1;
        s_tick     = 1'b0;
        
        if (count_reg == DIVISOR - 1) begin
            count_next = '0;
            s_tick     = 1'b1;
        end
    end

endmodule
