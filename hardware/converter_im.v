module converter_im #(
    parameter IN_WIDTH  = 9,
    parameter OUT_WIDTH = 20
) (
    input logic clk,
    input logic rst,

    input logic signed [IN_WIDTH-1:0] in,

    output logic [OUT_WIDTH-1:0] out
);

    logic [OUT_WIDTH-1:0] p_sum_0;
    logic [OUT_WIDTH-1:0] p_sum_1;

    always_comb begin
        p_sum_1 = p_sum_0 << 1;
    end

    converter_re #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter_re
    (
        .clk        (clk    ),
        .rst        (rst    ),
        .in         (in     ),
        .out        (p_sum_0)
    );

    ripple_carry_adder #(.IN_WIDTH(OUT_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_ripple_carry_adder
    (
        .clk        (clk    ),
        .rst        (rst    ),
        .a          (p_sum_0),
        .b          (p_sum_1),
        .sum        (out    ),
        .carry_out  (       )
    );
    
endmodule : converter_im
