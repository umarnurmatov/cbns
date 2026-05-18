module ripple_carry_adder #(
    parameter IN_WIDTH  = 20,
    parameter OUT_WIDTH = 20
) (
    input  logic                 clk,
    input  logic                 rst,

    input  logic [ IN_WIDTH-1:0] a,
    input  logic [ IN_WIDTH-1:0] b,
    input  logic                 a_valid,
    input  logic                 b_valid,

    output logic [OUT_WIDTH-1:0] sum,
    output logic [          7:0] carry_out,
    output logic                 res_valid
);

    logic [OUT_WIDTH-1:0] addend_a;
    logic [OUT_WIDTH-1:0] addend_b;
    logic [OUT_WIDTH-1:0] sum_comb;
    logic                 sum_valid;
    logic [          7:0] carries [OUT_WIDTH+8];

    always_comb begin
        carries [0] = 'b0;
        addend_a    = { { OUT_WIDTH - IN_WIDTH {1'b0} }, a };
        addend_b    = { { OUT_WIDTH - IN_WIDTH {1'b0} }, b };
    end

    generate
        genvar i;
        for(i = 0; i < OUT_WIDTH; ++i) begin : genaddr

            full_adder i_full_adder
            (
                .clk        (  clk                     ),
                .rst        (  rst                     ),
                .a          (  addend_a[    i]         ),
                .b          (  addend_b[    i]         ),
                .carry_in   (  carries [    i]         ),
                .s_out      (  sum_comb[    i]         ),
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

    assign sum_valid = a_valid & b_valid;

    always_ff @(posedge clk) begin
        if (rst) begin
            sum       <= '0;
            carry_out <= '0;
            res_valid <= 0; 
        end 
        else begin
            res_valid <= sum_valid; 

            if(sum_valid) begin 
                sum       <= sum_comb;
                carry_out <= carries[OUT_WIDTH];
            end
        end
    end
    
endmodule : ripple_carry_adder
