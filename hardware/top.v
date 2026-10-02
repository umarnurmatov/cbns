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
    
    // Hardcoded, because otherwise Quartus will optimize hole circuit entirely
    assign SEG[0]   = &converted;
    assign SEG[1]   = converted_valid;
    assign re_valid = KEY_SW[0];
    assign im_valid = KEY_SW[1];
    // Most tricky part: Quartus, probably, finds patterns in data, so
    // contatenating KEY_SW[0] IN_WIDTH times would result in almost total circuit reduction
    assign re       = PSEUDO_GPIO_USING_SDRAM_PINS[IN_WIDTH - 1:0];
    assign im       = PSEUDO_GPIO_USING_SDRAM_PINS[IN_WIDTH - 1:0];

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
