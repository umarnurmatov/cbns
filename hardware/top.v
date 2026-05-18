`ifndef IN_WIDTH
`define IN_WIDTH 8
`endif

module top
# (
    parameter clk_mhz       = 50,

              w_key         = 4,
              w_sw          = 4,
              w_led         = 4,
              w_digit       = 4,

              w_red         = 1,
              w_green       = 1,
              w_blue        = 1
)
(
    input                  CLK,
    input                  RESET,

    input  [w_key   - 1:0] KEY_SW,
    output [w_led   - 1:0] LED,

    output [          7:0] SEG,
    output [w_digit - 1:0] DIG
);

    //------------------------------------------------------------------------

    localparam IN_WIDTH   = `IN_WIDTH;
    localparam OUT_WIDTH  = IN_WIDTH * 2 + 4;

    wire clk =   CLK;
    wire rst = ~ RESET;

    logic signed [ IN_WIDTH-1:0] re;
    logic                        re_valid;
    logic signed [ IN_WIDTH-1:0] im;
    logic                        im_valid;
    logic        [OUT_WIDTH-1:0] converted;
    logic                        converted_valid;

    //------------------------------------------------------------------------
    
    assign SEG      = converted[7:0];
    assign re_valid = 1;
    assign im_valid = 1;

    //------------------------------------------------------------------------

    converter #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter
    (
        .clk             (clk            ),
        .rst             (rst            ),
        .re              (re             ),
        .re_valid        (re_valid       ),
        .im              (im             ),
        .im_valid        (im_valid       ),
        .converted       (converted      ),
        .converted_valid (converted_valid)
    );

    //-------------------------------------------------------------

endmodule
