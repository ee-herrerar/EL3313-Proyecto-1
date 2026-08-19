module Botones (
    input  logic       clk,
    input  logic       RESET,
    input  logic [7:0] BotonesDebounced,

    output logic       BotonValido,
    output logic [2:0] TopoJugador
);

    logic [7:0] BotonesPrevios;
    logic [7:0] BotonesNuevos;


    // Detecta flanco de subida en cualquiera de los 8 botones
    assign BotonesNuevos = BotonesDebounced & ~BotonesPrevios;


    // Guarda el estado anterior de los botones
    always_ff @(posedge clk or posedge RESET) begin
        if (RESET) begin
            BotonesPrevios <= 8'b0;
        end
        else begin
            BotonesPrevios <= BotonesDebounced;
        end
    end


    // Identifica cuál botón fue presionado
    always_comb begin

        // Valores por defecto
        BotonValido = 1'b0;
        TopoJugador = 3'b000;

        case (BotonesNuevos)

            8'b00000001: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd0;
            end

            8'b00000010: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd1;
            end

            8'b00000100: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd2;
            end

            8'b00001000: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd3;
            end

            8'b00010000: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd4;
            end

            8'b00100000: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd5;
            end

            8'b01000000: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd6;
            end

            8'b10000000: begin
                BotonValido = 1'b1;
                TopoJugador = 3'd7;
            end

            default: begin
                BotonValido = 1'b0;
                TopoJugador = 3'b000;
            end

        endcase

    end

endmodule