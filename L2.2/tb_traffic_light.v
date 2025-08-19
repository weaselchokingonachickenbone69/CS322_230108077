`timescale 1ns/1ps
module tb_traffic_light;
    reg clk = 0;
    reg rst = 0;
    wire tick;
    wire ns_g, ns_y, ns_r, ew_g, ew_y, ew_r;

    tick_prescaler #(.DIV(20)) presc (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    traffic_light #(.NS_G_T(5), .NS_Y_T(2), .EW_G_T(5), .EW_Y_T(2)) dut (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        $display("Starting simulation - prescaler DIV=20 -> tick every 20 clk cycles");
        $display("Time\tclk\ttick\tns_g\tns_y\tns_r\tew_g\tew_y\tew_r");


        repeat (840) begin
            @(posedge clk);
            $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",
                $time, clk, tick, ns_g, ns_y, ns_r, ew_g, ew_y, ew_r);
        end
        $finish;
    end
endmodule
