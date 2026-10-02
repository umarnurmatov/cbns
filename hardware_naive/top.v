`ifndef IN_WIDTH
`define IN_WIDTH 8
`endif

module top
# (
    parameter CLK_MHZ       = 50,
              KEY_W         = 4,
              SW_W          = 4,
              LED_W         = 4,
              DIGIT_W       = 4,
              GPIO_W        = 14
)
(
    input                  CLK,
    input                  RESET,

    input  [KEY_W   - 1:0] KEY_SW,
    output [LED_W   - 1:0] LED,

    output [          7:0] SEG,
    output [DIGIT_W - 1:0] DIG,

    inout  [GPIO_W  - 1:0] PSEUDO_GPIO_USING_SDRAM_PINS
);

    localparam IN_WIDTH  = `IN_WIDTH;
    localparam OUT_WIDTH = IN_WIDTH + 1;

    //-------------------------------------------------------------------------

    logic signed [ IN_WIDTH - 1:0] a_re;
    logic signed [ IN_WIDTH - 1:0] b_re;
    logic                          a_vld;

    logic signed [ IN_WIDTH - 1:0] a_im;
    logic signed [ IN_WIDTH - 1:0] b_im;
    logic                          b_vld;

    logic signed [OUT_WIDTH - 1:0] sum_re;
    logic signed [OUT_WIDTH - 1:0] sum_im;
    logic                          sum_vld;

    //-------------------------------------------------------------------------

    // Hardcoded in order to avoid optimizations 
    assign a_vld  = 1;
    assign b_vld  = 1;
    assign DIG[1] = ^(sum_re & sum_im);
    assign DIG[0] = sum_vld;

    assign a_re = PSEUDO_GPIO_USING_SDRAM_PINS[IN_WIDTH - 1:0];
    assign b_re = PSEUDO_GPIO_USING_SDRAM_PINS[IN_WIDTH - 1:0];
    assign a_im = PSEUDO_GPIO_USING_SDRAM_PINS[IN_WIDTH - 1:0];
    assign b_im = PSEUDO_GPIO_USING_SDRAM_PINS[IN_WIDTH - 1:0];


    //-------------------------------------------------------------------------
    
    complex_adder #( .IN_WIDTH(IN_WIDTH) )
    i_complex_adder
    (
        .clk    ( CLK     ),
        .rst    ( RESET   ),
        .a_re   ( a_re    ),
        .a_im   ( a_im    ),
        .a_vld  ( a_vld   ),
        .b_re   ( b_re    ),
        .b_im   ( b_im    ),
        .b_vld  ( b_vld   ),
        .out_re ( sum_re  ),
        .out_im ( sum_im  ),
        .out_vld( sum_vld )
    );
 
endmodule
