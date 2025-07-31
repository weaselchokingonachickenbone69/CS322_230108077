`timescale 1ns / 1ps
module test_bench;

    reg A, B;
    wire o1, o2, o3;

    one_bit_comparator uut (
        .A(A), .B(B),
        .o1(o1), .o2(o2), .o3(o3)
    );

    initial begin
        $dumpfile("one_bit_comparator.vcd");
        $dumpvars(0, test_bench);

        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;

        $finish;
    end
endmodule