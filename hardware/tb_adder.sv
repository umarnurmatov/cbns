`include "defines.svh"

`ifndef IN_WIDTH
`define IN_WIDTH 8
`endif

`ifndef DUMP_FILE
`define DUMP_FILE "dump.vcd"
`endif

module tb;

    localparam CLK_FREQ   = 5;
    localparam IN_WIDTH   = `IN_WIDTH;
    localparam OUT_WIDTH  = IN_WIDTH * 2 + 4;
    localparam TEST_CNT   = 1000;

    logic signed [ IN_WIDTH-1:0] re;
    logic signed [ IN_WIDTH-1:0] im;
    logic        [OUT_WIDTH-1:0] converted;
    logic        [OUT_WIDTH-1:0] addend_a;
    logic        [OUT_WIDTH-1:0] addend_b;
    logic        [OUT_WIDTH-1:0] sum;
    logic                        clk;
    logic                        rst;

    int addend_a_re;
    int addend_a_im;
    int addend_b_re;
    int addend_b_im;

    //-------------------------------------------------------------

    converter #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter
    (
        .clk        (clk      ),
        .rst        (rst      ),
        .re         (re       ),
        .im         (im       ),
        .converted  (converted)
    );

    ripple_carry_adder #(.IN_WIDTH(OUT_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_adder
    (
        .clk        (clk      ),
        .rst        (rst      ),
        .a          (addend_a ),
        .b          (addend_b ),
        .sum        (sum      )
    );
    
    //-------------------------------------------------------------

    task automatic cbns_to_complex (
        input  logic [OUT_WIDTH-1:0] cbns,
        output int                   result_re,
        output int                   result_im
    );
        localparam int BASE_RE = -1;
        localparam int BASE_IM =  1;

        int base_pow_re, base_pow_im;
        int temp_re, temp_im;

        result_re   = 0;
        result_im   = 0;
        base_pow_re = 1;
        base_pow_im = 0;

        for (int k = 0; k < OUT_WIDTH; k++) begin
            if (cbns[k]) begin
                result_re += base_pow_re;
                result_im += base_pow_im;
            end

            temp_re = base_pow_re * BASE_RE - base_pow_im * BASE_IM;
            temp_im = base_pow_re * BASE_IM + base_pow_im * BASE_RE;
            base_pow_re = temp_re;
            base_pow_im = temp_im;
        end
    endtask

    //-------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #CLK_FREQ clk = ~ clk;
    end
    
    //-------------------------------------------------------------

    initial begin
        rst <= 1'bx;
        repeat (2) @ (posedge clk);
        rst <= 1'b1;
        repeat (2) @ (posedge clk);
        rst <= 1'b0;
    end
    
    //-------------------------------------------------------------
    
    initial begin

        bit failed   = 0;

        int sum_re, sum_im;

        @(negedge rst); 

        for(int i = 0; i < TEST_CNT; ++i) begin

            addend_a_re = $random() % $rtoi($pow(2, IN_WIDTH - 1));
            addend_a_re = $random() % $rtoi($pow(2, IN_WIDTH - 1));

            re <= addend_a_re;
            im <= addend_a_im;

            #1;

            addend_a <= converted;

            addend_b_re = $random() % $rtoi($pow(2, IN_WIDTH - 1));
            addend_b_re = $random() % $rtoi($pow(2, IN_WIDTH - 1));

            re <= addend_b_re;
            im <= addend_b_im;

            #1;
  
            addend_b <= converted; 

            #1;

            cbns_to_complex(sum, sum_re, sum_im);

            if(sum_re != addend_a_re + addend_b_re || sum_im != addend_a_im + addend_b_im) begin

                    $display({`RED("[FAIL]   "), "(%5d + %5dj) + (%5d +%5dj) = %b (actual %5d+%5di)"},
                             addend_a_re, addend_a_im, addend_b_re, addend_b_im, converted, sum_re, sum_im);
                    failed = 1;
                    break;
            end
            
            if(failed) break;

        end

        if (!failed)
            $display({`YELLOW("[%2d BITS] "), `GREEN("[TEST PASSED] ")}, IN_WIDTH);
        else
            $display({`YELLOW("[%2d BITS] "), `RED("[TEST FAILED]")}, IN_WIDTH);

        $finish();
    end

    //-------------------------------------------------------------

`ifdef DUMP
    initial begin
        $dumpfile(`DUMP_FILE);
        $dumpvars();
    end
`endif 

endmodule : tb
