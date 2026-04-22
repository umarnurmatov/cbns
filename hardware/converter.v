module converter #(
    parameter IN_WIDTH  = 8,
    parameter OUT_WIDTH = 20
) (
    input wire signed [IN_WIDTH-1:0] re,
    input wire signed [IN_WIDTH-1:0] im,

    output logic [OUT_WIDTH-1:0] converted
);

    logic [OUT_WIDTH-1:0] re_converted;
    logic [OUT_WIDTH-1:0] im_converted;

    converter_re #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter_re
    (
        .in     (re          ),
        .out    (re_converted)
    );

    converter_im #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_converter_im
    (
        .in     (im          ),
        .out    (im_converted)
    );

    ripple_carry_adder #(.IN_WIDTH(OUT_WIDTH), .OUT_WIDTH(OUT_WIDTH))
    i_ripple_carry_adder
    (
        .a          (re_converted),
        .b          (im_converted),
        .sum        (converted   ),
        .carry_out  (            )
    );

endmodule : converter
