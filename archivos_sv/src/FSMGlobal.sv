module GameFSM (
    input  logic       clk,
    input  logic       RESET,

    input  logic       UARTValid,
    input  logic [2:0] TopoPosicion,
    input  logic [2:0] TopoJugador,
    input  logic       BotonValido,
    input  logic       TiempoFuera,
    input  logic [1:0] FallosConsecutivos,
    input  logic       GameOverDone,

    output logic       LlamadaTopoOut,
    output logic       TopoActivoOut,
    output logic       AciertosSube,
    output logic       FallosSube,
    output logic       ReiniciarFallosConsecutivos,
    output logic       ReajusteRelojOut,
    output logic       GameOverOut,
    output logic       ReiniciarJuego
);

    // State Declaration

    localparam [3:0] LlamadaTopo = 4'b0000,
                     EsperaTopo = 4'b0001,
                     TopoActivo = 4'b0010,
                     Acierto = 4'b0011,
                     AciertoSube = 4'b0100,
                     ReajusteReloj = 4'b0101,
                     Tiempo = 4'b0110,
                     Fallo = 4'b0111,
                     FalloSube = 4'b1000,
                     VerificarFallos = 4'b1001,
                     GameOver = 4'b1010;

    // Port/Signal Declaration

    logic [3:0] current_state;
    logic [3:0] next_state;

    // Module Body

    // FSM

    // 1-State Register

    always_ff @(posedge clk or posedge RESET) begin
        if (RESET) begin
            current_state <= LlamadaTopo;
        end else begin
            current_state <= next_state;
        end
    end


    // 2-Next State Logic

    always_comb begin

        case (current_state)

            LlamadaTopo: begin
                // Después de solicitar un nuevo topo
                next_state = EsperaTopo;
            end

            EsperaTopo: begin
                if (UARTValid) begin
                    // Se recibió una posición válida por UART
                    next_state = TopoActivo;
                end else begin
                    // Aún no se ha recibido la posición
                    next_state = EsperaTopo;
                end
            end

            TopoActivo: begin
                if (BotonValido) begin

                    if (TopoJugador == TopoPosicion) begin
                        // El jugador presionó el botón correcto
                        next_state = Acierto;
                    end else begin
                        // El jugador presionó un botón incorrecto
                        next_state = Fallo;
                    end

                end else if (TiempoFuera) begin
                    // Se agotó el tiempo del topo
                    next_state = Tiempo;
                end else begin
                    // No hubo pulsación ni Tiempo Fuera
                    next_state = TopoActivo;
                end
            end

            Acierto: begin
                // Se confirmó un acierto
                next_state = AciertoSube;
            end

            AciertoSube: begin
                // Después de aumentar el contador de aciertos
                next_state = ReajusteReloj;
            end

            ReajusteReloj: begin
                // Después de ajustar la dificultad
                next_state = LlamadaTopo;
            end

            Tiempo: begin
                // Tiempo Fuera cuenta como fallo
                next_state = FalloSube;
            end

            Fallo: begin
                // Se confirmó un fallo por botón incorrecto
                next_state = FalloSube;
            end

            FalloSube: begin
                // Después de aumentar los contadores de fallos
                next_state = VerificarFallos;
            end

            VerificarFallos: begin
                if (FallosConsecutivos == 2'b11) begin
                    // Se alcanzaron 3 fallos consecutivos
                    next_state = GameOver;
                end else begin
                    // Aún no se alcanzan 3 fallos consecutivos
                    next_state = LlamadaTopo;
                end
            end

            GameOver: begin
                if (GameOverDone) begin
                    // Finalizó el tiempo de Game Over
                    next_state = LlamadaTopo;
                end else begin
                    // Se mantiene en Game Over
                    next_state = GameOver;
                end
            end

            default: begin
                // Estado inválido: regresar al inicio
                next_state = LlamadaTopo;
            end

        endcase

    end


    // 3-Output Logic

    always_comb begin

        // Valores por defecto de las salidas
        LlamadaTopoOut = 1'b0;
        TopoActivoOut = 1'b0;
        AciertosSube = 1'b0;
        FallosSube = 1'b0;
        ReiniciarFallosConsecutivos = 1'b0;
        ReajusteRelojOut = 1'b0;
        GameOverOut = 1'b0;
        ReiniciarJuego = 1'b0;

        case (current_state)

            LlamadaTopo: begin
                // Solicita una nueva posición del topo
                LlamadaTopoOut = 1'b1;
            end

            EsperaTopo: begin
                // No se activa ninguna salida
            end

            TopoActivo: begin
                // Indica que el topo está activo
                TopoActivoOut = 1'b1;
            end

            Acierto: begin
                // No se activa ninguna salida
            end

            AciertoSube: begin
                // Incrementa los aciertos y reinicia los fallos consecutivos
                AciertosSube = 1'b1;
                ReiniciarFallosConsecutivos = 1'b1;
            end

            ReajusteReloj: begin
                // Solicita actualizar la ventana de tiempo
                ReajusteRelojOut = 1'b1;
            end

            Tiempo: begin
                // No se activa ninguna salida
            end

            Fallo: begin
                // No se activa ninguna salida
            end

            FalloSube: begin
                // Incrementa los contadores de fallos
                FallosSube = 1'b1;
            end

            VerificarFallos: begin
                // No se activa ninguna salida
            end

            GameOver: begin
                // Indica que el juego se encuentra en Game Over
                GameOverOut = 1'b1;

                // Reinicia los contadores al finalizar el Game Over
                if (GameOverDone) begin
                    ReiniciarJuego = 1'b1;
                end
            end

            default: begin
                // Las salidas permanecen en sus valores por defecto
            end

        endcase

    end

endmodule
