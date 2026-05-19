module complex_adder #(
    parameter IN_WIDTH = 8,
    parameter OUT_WIDTH = IN_WIDTH + 1
) (
    input  logic                          clk,
    input  logic                          rst,

    input  logic signed [ IN_WIDTH - 1:0] a_re,
    input  logic signed [ IN_WIDTH - 1:0] a_im,
    input  logic                          a_vld,

    input  logic signed [ IN_WIDTH - 1:0] b_re,
    input  logic signed [ IN_WIDTH - 1:0] b_im,
    input  logic                          b_vld,

    output logic signed [OUT_WIDTH - 1:0] out_re,
    output logic signed [OUT_WIDTH - 1:0] out_im,
    output logic                          out_vld
);

    logic signed [OUT_WIDTH - 1:0] sum_re;
    logic signed [OUT_WIDTH - 1:0] sum_im;

    assign sum_re = a_re + b_re;
    assign sum_im = a_im + b_im;

    always_ff @(posedge clk) begin
        if (rst) begin
            out_vld <= 0;
        end
        else begin
            if (a_vld & b_vld) begin
                out_re <= sum_re;
                out_im <= sum_im;
            end
            out_vld <= a_vld & b_vld;
        end
    end

endmodule : complex_adder
