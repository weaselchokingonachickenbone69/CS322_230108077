`timescale 1ns/1ps
module tb_vending_mealy;
    reg clk = 0;
    reg rst = 0;
    reg [1:0] coin = 2'b00;
    wire dispense;
    wire chg5;

    vending_mealy dut(.clk(clk), .rst(rst), .coin(coin),
                      .dispense(dispense), .chg5(chg5));

    always #5 clk = ~clk;

    task put5;
    begin
        coin = 2'b01;
        @(posedge clk);
        coin = 2'b00;
        @(posedge clk);
    end
    endtask

    task put10;
    begin
        coin = 2'b10;
        @(posedge clk);
        coin = 2'b00;
        @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_vending_mealy);
        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        $display("Test: 10 + 10 -> dispense only");
        put10; put10;
        @(posedge clk); @(posedge clk);

        $display("Test: 5 + 5 + 10 -> dispense only");
        put5; put5; put10;
        @(posedge clk); @(posedge clk);

        $display("Test: 10 + 5 + 10 -> vend + chg5 (25 total)");
        put10; put5; put10;
        @(posedge clk); @(posedge clk);

        $display("Done tests");
        $finish;
    end
endmodule
