module contadores (
    input  logic       clk,
    input  logic       RESET,
    input  logic       AciertosSube,
    input  logic       FallosSube,
    input  logic       ReiniciarFallosConsecutivos,
    input  logic       ReiniciarJuego,

    output logic [6:0] AciertosTotales,
    output logic [6:0] FallosTotales,
    output logic [1:0] FallosConsecutivos
);

    // Actualización de los contadores
    always_ff @(posedge clk or posedge RESET) begin

        // Reinicio general del sistema
        if (RESET) begin
            AciertosTotales     <= 7'd0;
            FallosTotales       <= 7'd0;
            FallosConsecutivos  <= 2'd0;
        end

        // Reinicio automático al comenzar una nueva partida
        else if (ReiniciarJuego) begin
            AciertosTotales     <= 7'd0;
            FallosTotales       <= 7'd0;
            FallosConsecutivos  <= 2'd0;
        end

        // Se produjo un acierto
        else if (AciertosSube) begin

            // El contador de aciertos se limita a 99
            if (AciertosTotales < 7'd99) begin
                AciertosTotales <= AciertosTotales + 7'd1;
            end

            // Un acierto reinicia los fallos consecutivos
            FallosConsecutivos <= 2'd0;
        end

        // Se produjo un fallo
        else if (FallosSube) begin

            // El contador de fallos totales se limita a 99
            if (FallosTotales < 7'd99) begin
                FallosTotales <= FallosTotales + 7'd1;
            end

            // Los fallos consecutivos se limitan a 3
            if (FallosConsecutivos < 2'd3) begin
                FallosConsecutivos <= FallosConsecutivos + 2'd1;
            end
        end

        // Reinicio independiente de los fallos consecutivos
        else if (ReiniciarFallosConsecutivos) begin
            FallosConsecutivos <= 2'd0;
        end

    end

endmodule