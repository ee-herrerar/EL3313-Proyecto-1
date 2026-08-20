module Display7Seg (
    input  logic       clk,
    input  logic       RESET,
    input  logic [6:0] AciertosTotales,
    input  logic [6:0] FallosTotales,

    output logic [6:0] seg,
    output logic [3:0] an,
    output logic       dp
);

    // =====================================================
    // Señales internas
    // =====================================================

    logic [16:0] ContadorRefresh;
    logic [1:0]  SelectorDisplay;

    logic [3:0] AciertosDecenas;
    logic [3:0] AciertosUnidades;

    logic [3:0] FallosDecenas;
    logic [3:0] FallosUnidades;

    logic [3:0] DigitoActual;


    // =====================================================
    // Conversión a decenas y unidades
    // =====================================================

    always_comb begin

        AciertosDecenas  = AciertosTotales / 10;
        AciertosUnidades = AciertosTotales % 10;

        FallosDecenas    = FallosTotales / 10;
        FallosUnidades   = FallosTotales % 10;

    end


    // =====================================================
    // Contador de refresco
    //
    // Importante:
    // NO se reinicia con RESET.
    // Debe seguir corriendo para mantener activos los
    // cuatro displays durante RESET.
    // =====================================================

    always_ff @(posedge clk) begin
        ContadorRefresh <= ContadorRefresh + 17'd1;
    end


    // Bits superiores usados para seleccionar display
    assign SelectorDisplay = ContadorRefresh[16:15];


    // =====================================================
    // Selección del display activo
    //
    // Basys 3:
    // an = 0 -> display encendido
    // =====================================================

    always_comb begin

        an           = 4'b1111;
        DigitoActual = 4'd0;

        case (SelectorDisplay)

            // AN0
            // Unidades de fallos
            2'b00: begin
                an           = 4'b1110;
                DigitoActual = FallosUnidades;
            end


            // AN1
            // Decenas de fallos
            2'b01: begin
                an           = 4'b1101;
                DigitoActual = FallosDecenas;
            end


            // AN2
            // Unidades de aciertos
            2'b10: begin
                an           = 4'b1011;
                DigitoActual = AciertosUnidades;
            end


            // AN3
            // Decenas de aciertos
            2'b11: begin
                an           = 4'b0111;
                DigitoActual = AciertosDecenas;
            end


            default: begin
                an           = 4'b1111;
                DigitoActual = 4'd0;
            end

        endcase

    end


    // =====================================================
    // Decoder BCD -> 7 segmentos
    //
    // seg[6:0] = {a,b,c,d,e,f,g}
    // Segmentos activos en bajo
    // =====================================================

    always_comb begin

        case (DigitoActual)

            4'd0: seg = 7'b0000001;
            4'd1: seg = 7'b1001111;
            4'd2: seg = 7'b0010010;
            4'd3: seg = 7'b0000110;
            4'd4: seg = 7'b1001100;
            4'd5: seg = 7'b0100100;
            4'd6: seg = 7'b0100000;
            4'd7: seg = 7'b0001111;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0000100;

            default: seg = 7'b1111111;

        endcase

    end


    // Punto decimal apagado
    assign dp = 1'b1;


endmodule
//Version 2