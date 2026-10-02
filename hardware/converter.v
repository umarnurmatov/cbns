module converter #(
    parameter IN_WIDTH  = 8,
    parameter OUT_WIDTH = 20
) (
    input logic                        clk,
    input logic                        rst,
    
    input logic signed [ IN_WIDTH-1:0] re,
    input logic                        re_valid,
    input logic signed [ IN_WIDTH-1:0] im,
    input logic                        im_valid,

    output logic       [OUT_WIDTH-1:0] converted,
    output logic                       converted_valid
);

    typedef enum {
        STATE_CONVERT,
        STATE_ADD

    } state_t;

    state_t state, next_state;

    logic [OUT_WIDTH-1:0] re_converted;
    logic                 re_converted_valid;
    logic [OUT_WIDTH-1:0] im_converted;
    logic                 im_converted_valid;
    logic [OUT_WIDTH-1:0] sum;
    logic                 sum_valid;


    // -------------------- STATE MACHINE LOGIC --------------------

    
    // State transition logic
    always_comb begin
        next_state = state;
        case (state) 
            STATE_CONVERT: if(re_valid & im_valid) next_state = STATE_ADD;
            STATE_ADD:     if(sum_valid          ) next_state = STATE_CONVERT;
        endcase
    end
    
    // State register
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= STATE_CONVERT; 
        end
        else begin
            state <= next_state; 
        end
    end

    // -------------------------------------------------------------
    
    always_ff @(posedge clk) begin
        if (rst) begin
            converted       <= '0;
            converted_valid <= 0;
        end
        else begin
            converted       <= sum;
            converted_valid <= sum_valid & (state == STATE_ADD);
        end
    end

    // ------------------------- MODULES ---------------------------
    
    converter_re #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter_re
    (
        .clk        (clk               ),
        .rst        (rst               ),
        .in         (re                ),
        .in_valid   (re_valid          ),
        .out        (re_converted      ),
        .out_valid  (re_converted_valid)
    );

    converter_im #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter_im
    (
        .clk        (clk               ),
        .rst        (rst               ),
        .in         (im                ),
        .in_valid   (im_valid          ),
        .out        (im_converted      ),
        .out_valid  (im_converted_valid)
    );

    ripple_carry_adder #(.IN_WIDTH(OUT_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_ripple_carry_adder
    (
        .clk        (clk               ),
        .rst        (rst               ),
        .a          (re_converted      ),
        .a_valid    (im_converted_valid),
        .b          (im_converted      ),
        .b_valid    (im_converted_valid),
        .sum        (sum               ),
        .carry_out  (                  ),
        .res_valid  (sum_valid         )
    );


endmodule : converter
