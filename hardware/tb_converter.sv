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

    localparam int L_BOUND = -$rtoi($pow(2, IN_WIDTH - 1));
    localparam int H_BOUND =  $rtoi($pow(2, IN_WIDTH - 1)) - 1;

    logic                        clk;
    logic                        rst;
    logic signed [ IN_WIDTH-1:0] re;
    logic                        re_valid;
    logic signed [ IN_WIDTH-1:0] im;
    logic                        im_valid;
    logic        [OUT_WIDTH-1:0] converted;
    logic                        converted_valid;

    //-------------------------------------------------------------

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

        int test_cnt = 1;
        bit failed   = 0;
        int re_int   = L_BOUND;
        int im_int   = L_BOUND;

        int converted_re, converted_im;

        @(negedge rst); 

        for(; re_int <= H_BOUND; re_int += 1) begin

            im_int = L_BOUND;
            for(; im_int <= H_BOUND; im_int += 1) begin

                re       <= re_int;
                im       <= im_int;
                re_valid <= 1;
                im_valid <= 1;

                @(negedge converted_valid);

                cbns_to_complex(converted, converted_re, converted_im);

                if (converted_re !== re || converted_im !== im) begin
                    $display({"(test %5d) ", `RED("[FAIL]   "), "%d + %dj = %b (actual %5d+%5di)"},
                             test_cnt, re, im, converted, converted_re, converted_im);
                    failed = 1;
                    break;
                end
                else begin
                    $display({"(test %5d) ", `GREEN("[  OK]   "), "%d + %dj = %b"},
                             test_cnt, re, im, converted);
                end

                test_cnt++;

            end

            if(failed) break;

        end

        if (!failed)
            $display({`YELLOW("[%2d BITS] "), `GREEN("[TEST PASSED] "), "%d conversions"}, IN_WIDTH, test_cnt);
        else
            $display({`YELLOW("[%2d BITS] "), `RED("[TEST FAILED]")}, IN_WIDTH);

        $finish();
    end

    //-------------------------------------------------------------

    initial begin
        $dumpfile(`DUMP_FILE);
        $dumpvars();
    end

endmodule : tb
