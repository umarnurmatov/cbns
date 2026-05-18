module hot_count #(
    parameter WIDTH = 7
) (
    input  logic [        WIDTH-1:0] value,
    output logic [$clog2(WIDTH)-1:0] cnt
);

always_comb  begin
    cnt = { WIDTH {1'b0} };  
    for(int idx = 0; idx < WIDTH; idx = idx + 1) begin
        cnt = cnt + value[idx];
    end
end

endmodule : hot_count
