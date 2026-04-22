`define ANSI_COLOR_RED "\x1b[31m"
`define ANSI_COLOR_GREEN "\x1b[32m"
`define ANSI_COLOR_YELLOW "\x1b[33m"
`define ANSI_COLOR_RESET "\x1b[0m"

`define GREEN(str) {`ANSI_COLOR_GREEN, str, `ANSI_COLOR_RESET}
`define RED(str) {`ANSI_COLOR_RED  , str, `ANSI_COLOR_RESET}

module tb;

    localparam IN_WIDTH   = 8;
    localparam OUT_WIDTH  = 20;

    localparam signed [IN_WIDTH-1:0] L_BOUND = -$rtoi($pow(2, IN_WIDTH - 1));
    localparam signed [IN_WIDTH-1:0] H_BOUND =  $rtoi($pow(2, IN_WIDTH - 1)) - 1;

    logic signed [ IN_WIDTH-1:0] re;
    logic signed [ IN_WIDTH-1:0] im;
    logic        [OUT_WIDTH-1:0] converted;

    converter #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter
    (
        .re         (re       ),
        .im         (im       ),
        .converted  (converted)
    );

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

    initial begin

        int test_cnt = 1;
        bit failed   = 0;

        int converted_re, converted_im;

        re = L_BOUND;
        for(; re < H_BOUND; re += 1) begin

            im = L_BOUND;
            for(; im < H_BOUND; im += 1) begin

                #1;

                cbns_to_complex(converted, converted_re, converted_im);

                if (converted_re == re && converted_im == im) begin
                    $display({"(test %5d) ", `GREEN("[CORRECT]"), "%d + %dj = %b"}, test_cnt, re, im, converted);
                end

                else begin
                    $display({"(test %5d) ", `RED("[FAIL]   "), "%d + %dj = %b (actual %5d+%5di)"}, test_cnt, re, im, converted, converted_re, converted_im);
                    failed = 1;
                end

                test_cnt++;

            end
        end

        if (!failed)
            $display(`GREEN("[TEST PASSED]"));
        else
            $display(`RED("[TEST FAILED]"));

        $finish(); 
    end

    initial begin
        $dumpvars();
    end

endmodule : tb
