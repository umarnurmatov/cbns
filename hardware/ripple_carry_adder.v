module ripple_carry_adder #(
    parameter IN_WIDTH  = 20,
    parameter OUT_WIDTH = 20
) (
    input wire [IN_WIDTH-1:0] a,
    input wire [IN_WIDTH-1:0] b,

    output logic [OUT_WIDTH-1:0] sum,
    output logic [          7:0] carry_out
);

    wire [OUT_WIDTH-1:0] addend_a = { { OUT_WIDTH - IN_WIDTH {1'b0} }, a };
    wire [OUT_WIDTH-1:0] addend_b = { { OUT_WIDTH - IN_WIDTH {1'b0} }, b };

    logic [7:0] carries [OUT_WIDTH+8];

    assign carry_out = carries[OUT_WIDTH];

    generate
        for(genvar i = 0; i < OUT_WIDTH; ++i) begin : genaddr

            full_adder i_full_adder
            (
                .a          (  addend_a[    i]         ),
                .b          (  addend_b[    i]         ),
                .carry_in   (  carries [    i]         ),
                .s_out      (  sum     [    i]         ),
                .carry_out  ({ carries [i + 8][i % 8],   
                               carries [i + 7][i % 8], 
                               carries [i + 6][i % 8], 
                               carries [i + 5][i % 8], 
                               carries [i + 4][i % 8], 
                               carries [i + 3][i % 8], 
                               carries [i + 2][i % 8], 
                               carries [i + 1][i % 8] })
            );

        end
    endgenerate
    
endmodule : ripple_carry_adder
