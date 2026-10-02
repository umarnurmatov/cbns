module converter_im #(
    parameter IN_WIDTH  = 9,
    parameter OUT_WIDTH = 20
) (
    input  logic                        clk,
    input  logic                        rst,

    input  logic signed [ IN_WIDTH-1:0] in,
    input  logic                        in_valid,

    output logic        [OUT_WIDTH-1:0] out,
    output logic                        out_valid
);

    typedef enum {
        STATE_CONVERT_RE,
        STATE_MULTIPLY
    } state_t;

    state_t state, next_state;

    logic [OUT_WIDTH-1:0] p_sum_0;
    logic                 p_sum_0_valid;
    logic [OUT_WIDTH-1:0] p_sum_1;
    logic [OUT_WIDTH-1:0] sum;
    logic                 sum_valid;

    // -------------------- STATE MACHINE LOGIC --------------------
    
    // State transition
    always_comb begin
        next_state = state;
        case (state)
            STATE_CONVERT_RE: if (p_sum_0_valid) next_state = STATE_MULTIPLY;
            STATE_MULTIPLY:   if (    sum_valid) next_state = STATE_CONVERT_RE;
        endcase
    end

    // State register
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= STATE_CONVERT_RE;
        end
        else begin
            state <= next_state;
        end
    end

    // -------------------------------------------------------------

    always_ff @(posedge clk) begin
        if (rst) begin
            out_valid <= 0;
            out       <= '0;
        end
        else begin
            if (sum_valid) out       <= sum;
                           out_valid <= sum_valid & (state == STATE_MULTIPLY);
        end
    end

    // ------------------------- MODULES ---------------------------

    converter_re #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter_re
    (
        .clk        (clk          ),
        .rst        (rst          ),
        .in         (in           ),
        .in_valid   (in_valid     ),
        .out        (p_sum_0      ),
        .out_valid  (p_sum_0_valid)
    );

    assign p_sum_1 = p_sum_0 << 1;

    ripple_carry_adder #(.IN_WIDTH(OUT_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_ripple_carry_adder
    (
        .clk        (clk          ),
        .rst        (rst          ),
        .a          (p_sum_0      ),
        .a_valid    (p_sum_0_valid),
        .b          (p_sum_1      ),
        .b_valid    (p_sum_0_valid),
        .sum        (sum          ),
        .carry_out  (             ),
        .res_valid  (sum_valid    )
    );
    
endmodule : converter_im
