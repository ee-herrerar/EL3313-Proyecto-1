module two_stage_synchronizer (
    input  logic clk,
    input  logic reset,
    input  logic async_signal,
    output logic sync_signal
);

    logic sync_ff1;

    always_ff @(posedge clk) begin
        if (reset) begin
            sync_ff1    <= 1'b0;
            sync_signal <= 1'b0;
        end
        else begin
            sync_ff1    <= async_signal;
            sync_signal <= sync_ff1;
        end
    end

endmodule