`timescale 1ns / 1ps

module test_bench;

    reg [3:0] A, B;
    wire ans;

    four_bit_equality uut (
        .A(A),
        .B(B),
        .ans(ans)
    );

    integer i, j;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_bench);

        // Loop through all 256 possible combinations
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A = i;
                B = j;
                #5;
            end
        end

        $finish;
    end
endmodule