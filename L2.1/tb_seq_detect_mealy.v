`timescale 1ns/1ps
module tb_seq_detect_mealy;
    reg clk = 0;
    reg rst = 0;
    reg din = 0;
    wire y;

    reg [10:0] stream;
    integer i;

    seq_detect_mealy dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .y(y)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        $display("Time\tclk\tdin\ty");

        stream = 11'b11011011101; 

        for (i = 10; i >= 0; i = i - 1) begin
            din = stream[i];
            @(posedge clk);
            $display("%0t\t%b\t%b\t%b", $time, clk, din, y);
        end

        din = 0;
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
endmodule

