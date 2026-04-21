module ripple_carry_adder #(
    IN_WIDTH  = 8,
    OUT_WIDTH = 20
) (
    input wire [IN_WIDTH-1:0] re,
    input wire [IN_WIDTH-1:0] im,

    output wire [OUT_WIDTH-1:0] sum,
    output wire [7:0]           carry_out
);

    wire [OUT_WIDTH-1:0] addend_re = { {OUT_WIDTH-IN_WIDTH{1'b0}}, re };
    wire [OUT_WIDTH-1:0] addend_im = { {OUT_WIDTH-IN_WIDTH{1'b0}}, im };

    wire [7:0] carries [OUT_WIDTH+1];

    assign carry_out = carries[OUT_WIDTH];

    generate
        for(genvar i = 0; i < OUT_WIDTH; ++i) begin

            full_adder i_full_adder
            (
                .a (addend_re[i]),
                .b (addend_im[i]),
                .carry_in(carries[i]),
                .s_out(sum[i]),
                .carry_out(carries[i+1])
            );

        end
    endgenerate
    
endmodule