`define CARRY_W 8

module full_adder
(
    input  logic                clk,
    input  logic                rst,

    input  logic                a,
    input  logic                b,
    input  logic [`CARRY_W-1:0] carry_in,
    
    output logic                s_out,
    output logic [`CARRY_W-1:0] carry_out
);

    localparam HOTCOUNT_W = $clog2(`CARRY_W) + 1;

    logic [HOTCOUNT_W-1:0] hotcount;
    logic [HOTCOUNT_W-1:0] carry_in_hotcount;

    always_comb begin
        hotcount = carry_in_hotcount + { {HOTCOUNT_W - 1 {1'b0} }, a} + { {HOTCOUNT_W - 1 {1'b0} }, b};
    end

    always_comb begin
        case(hotcount)
            'd0:     { s_out, carry_out } = 9'b000000000;
            'd1:     { s_out, carry_out } = 9'b100000000;
            'd2:     { s_out, carry_out } = 9'b000000110;
            'd3:     { s_out, carry_out } = 9'b100000110;
            'd4:     { s_out, carry_out } = 9'b011101000;
            'd5:     { s_out, carry_out } = 9'b111101000;
            'd6:     { s_out, carry_out } = 9'b011101110;
            'd7:     { s_out, carry_out } = 9'b111101110;
            'd8:     { s_out, carry_out } = 9'b011100000;
            default: { s_out, carry_out } = 9'b000000000;
        endcase
    end

    // TODO optimize popcount
    hot_count #( .WIDTH(`CARRY_W) )
    i_hot_count
    (
        .value (carry_in         ),
        .cnt   (carry_in_hotcount)
    );
    
endmodule : full_adder
