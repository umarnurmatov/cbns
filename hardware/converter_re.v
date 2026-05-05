`define ceil_nearest_even(x)((x) % 2 == 0 ? x : x + 1)

module converter_re #(
    parameter IN_WIDTH  = 8,
    parameter OUT_WIDTH = 20
) (
    input logic clk,
    input logic rst,

    input logic signed [IN_WIDTH-1:0] in,

    output logic [OUT_WIDTH-1:0] out
);

    localparam BASE_NEG4_WIDTH = `ceil_nearest_even(IN_WIDTH + 2);

    logic signed [BASE_NEG4_WIDTH-1:0] in_extend;
    logic signed [BASE_NEG4_WIDTH-1:0] shroeppel;
    logic signed [BASE_NEG4_WIDTH-1:0] base_neg4;

    always_comb begin
        // TODO maybe use $signed()?
        in_extend  = { { BASE_NEG4_WIDTH - IN_WIDTH {in[IN_WIDTH-1]}}, in }; 

        // TODO fix width truncation
        shroeppel  = { IN_WIDTH/4 + 1 {4'hC} }; 
        
        base_neg4  = (in_extend + shroeppel) ^ shroeppel;
    end

    always_comb begin

        for(int i = 0; i < BASE_NEG4_WIDTH; i += 2) begin

            case(base_neg4[i+:2])

                2'b00: out[i*2+:4] = 4'b0000;
                2'b01: out[i*2+:4] = 4'b0001;
                2'b10: out[i*2+:4] = 4'b1100;
                2'b11: out[i*2+:4] = 4'b1101;
                
            endcase

        end
    end

    
endmodule : converter_re
