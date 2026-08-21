module Dificultad (
    input  logic        clk,
    input  logic        RESET,
    input  logic        ReajusteRelojOut,
    input  logic        ReiniciarJuego,

    output logic [3:0]  NivelDificultad,
    output logic [10:0] TiempoLimite
);

    // Registro del nivel de dificultad
    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin
            // Reinicia la dificultad al nivel inicial
            NivelDificultad <= 4'd0;
        end

        else if (ReiniciarJuego) begin
            // Una nueva partida comienza en nivel 0
            NivelDificultad <= 4'd0;
        end

        else if (ReajusteRelojOut) begin

            // Aumenta la dificultad hasta un máximo de nivel 10
            if (NivelDificultad < 4'd10) begin
                NivelDificultad <= NivelDificultad + 4'd1;
            end

        end

    end


    // Conversión del nivel de dificultad al tiempo límite
    always_comb begin

        case (NivelDificultad)

            4'd0: begin
                TiempoLimite = 11'd1500;
            end

            4'd1: begin
                TiempoLimite = 11'd1400;
            end

            4'd2: begin
                TiempoLimite = 11'd1300;
            end

            4'd3: begin
                TiempoLimite = 11'd1200;
            end

            4'd4: begin
                TiempoLimite = 11'd1100;
            end

            4'd5: begin
                TiempoLimite = 11'd1000;
            end

            4'd6: begin
                TiempoLimite = 11'd900;
            end

            4'd7: begin
                TiempoLimite = 11'd800;
            end

            4'd8: begin
                TiempoLimite = 11'd700;
            end

            4'd9: begin
                TiempoLimite = 11'd600;
            end

            4'd10: begin
                TiempoLimite = 11'd500;
            end

            default: begin
                TiempoLimite = 11'd1500;
            end

        endcase

    end

endmodule
