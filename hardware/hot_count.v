module hot_count #(
    parameter WIDTH = 8
) (
    input  logic [          WIDTH-1:0] value,
    output logic [$clog2(WIDTH+1)-1:0] cnt
);

    // FIXME !!!
    always_comb begin
        cnt = '0;
        for (int i = 0; i < WIDTH; i++) begin
            case (value[i])
                1'b1: cnt = cnt + 1;
                1'bz, 1'b0: ;
            endcase
        end
    end

endmodule : hot_count
