module Temporizador (
    input  logic        clk,
    input  logic        RESET,
    input  logic        TopoActivoOut,
    input  logic [10:0] TiempoLimite,

    output logic        TiempoFuera
);

    // Declaración de señales internas
    logic [16:0] ContadorCiclos;
    logic [10:0] ContadorMs;
    logic        CE_1ms;


    // A 100 MHz, 100 000 ciclos corresponden a 1 ms
    assign CE_1ms = TopoActivoOut &&
                    (ContadorCiclos == 17'd99999);


    // ------------------------------------------------
    // Contador de ciclos de reloj
    // ------------------------------------------------

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin
            ContadorCiclos <= 17'd0;
        end

        // Fuera de TopoActivo se prepara para el próximo turno
        else if (!TopoActivoOut) begin
            ContadorCiclos <= 17'd0;
        end

        // Si ya ocurrió TiempoFuera, deja de contar
        else if (TiempoFuera) begin
            ContadorCiclos <= 17'd0;
        end

        // Cada 100 000 ciclos vuelve a comenzar
        else if (CE_1ms) begin
            ContadorCiclos <= 17'd0;
        end

        else begin
            ContadorCiclos <= ContadorCiclos + 17'd1;
        end

    end


    // ------------------------------------------------
    // Contador de milisegundos y generación de TiempoFuera
    // ------------------------------------------------

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin
            ContadorMs  <= 11'd0;
            TiempoFuera <= 1'b0;
        end

        // Al salir de TopoActivo se reinicia el temporizador
        else if (!TopoActivoOut) begin
            ContadorMs  <= 11'd0;
            TiempoFuera <= 1'b0;
        end

        // Incrementa solamente cada 1 ms
        else if (CE_1ms && !TiempoFuera) begin

            // Se alcanzó el tiempo máximo permitido
            if ((ContadorMs + 11'd1) >= TiempoLimite) begin
                TiempoFuera <= 1'b1;
            end

            else begin
                ContadorMs <= ContadorMs + 11'd1;
            end

        end

    end

endmodule
