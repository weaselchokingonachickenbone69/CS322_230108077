`timescale 1ns/1ps
module tb_link_top;
    reg clk = 0;
    reg rst = 0;
    wire done;

    link_top dut(.clk(clk), .rst(rst), .done(done));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_link_top);

        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        $display("time req ack data last_byte done");
        repeat (200) begin
            @(posedge clk);
            $display("%0t %b   %b   %02h   %02h        %b",
                $time,
                dut.master.req,
                dut.slave.ack,
                dut.master.data,
                dut.slave.last_byte,
                done);
            if (done) begin
                $display("Done observed at time %0t", $time);
                @(posedge clk);
                $finish;
            end
        end
        $finish;
    end
endmodule
