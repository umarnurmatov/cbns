module full_adder
(
    input logic      clk,
    input logic      rst,

    input logic       a,
    input logic       b,
    input logic [7:0] carry_in,
    
    output logic       s_out,
    output logic [7:0] carry_out
);

    logic [$clog2(8):0] ones;
    logic [$clog2(8):0] carry_in_ones;

    always_comb begin
        ones = carry_in_ones + a + b;         // TODO optimize popcount
    end

    always_comb begin
        case(ones)
            'd0: { s_out, carry_out } = 9'b000000000;
            'd1: { s_out, carry_out } = 9'b100000000;
            'd2: { s_out, carry_out } = 9'b000000110;
            'd3: { s_out, carry_out } = 9'b100000110;
            'd4: { s_out, carry_out } = 9'b011101000;
            'd5: { s_out, carry_out } = 9'b111101000;
            'd6: { s_out, carry_out } = 9'b011101110;
            'd7: { s_out, carry_out } = 9'b111101110;
            'd8: { s_out, carry_out } = 9'b011100000;
            default: 
                { s_out, carry_out } = 9'bxxxxxxxx;
        endcase
    end

    hot_count #( .WIDTH(8) )
    i_hot_count
    (
        .value (carry_in),
        .cnt   (carry_in_ones)
    );
    
endmodule : full_adder
