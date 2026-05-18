module hot_count #(
    parameter WIDTH = 8
) (
    input  logic [          WIDTH-1:0] value,
    output logic [$clog2(WIDTH+1)-1:0] cnt
);

always_comb begin
    cnt = '0;  
    for(int idx = 0; idx < WIDTH; idx = idx + 1) begin
        cnt = cnt + value[idx];
    end
end

endmodule : hot_count
