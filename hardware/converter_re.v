module converter_re #(
    IN_WIDTH  = 8,
    OUT_WIDTH = 20
) (
    input wire [IN_WIDTH-1:0] in,

    output wire [OUT_WIDTH-1:0] out
);

    wire [IN_WIDTH-1:0] shroeppel = {IN_WIDTH/4{'hC}};

    wire [IN_WIDTH-1:0] base_neg4 = (in + shroeppel) ^ shroeppel;

    always_comb begin

        for(int i = 0; i < IN_WIDTH; i+=2) begin
            case(base_neg4[i+1:i])

                2'b00: out[i*2+3:i*2] = 4'b0000;
                2'b01: out[i*2+3:i*2] = 4'b0001;
                2'b10: out[i*2+3:i*2] = 4'b1100;
                2'b11: out[i*2+3:i*2] = 4'b1101;
                
            endcase
        end

    end

    
endmodule