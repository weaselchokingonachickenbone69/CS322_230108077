module four_bit_equality (
    input [3:0] A,
    input [3:0] B,
    output ans
);
    assign ans = (A == B);
endmodule