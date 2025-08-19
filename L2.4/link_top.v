module link_top(
    input  wire clk,
    input  wire rst,
    output wire done
);
    wire req;
    wire ack;
    wire [7:0] data;
    wire [7:0] last_byte;

    master_fsm master(
        .clk(clk), .rst(rst), .ack(ack),
        .req(req), .data(data), .done(done)
    );

    slave_fsm slave(
        .clk(clk), .rst(rst), .req(req),
        .data_in(data), .ack(ack), .last_byte(last_byte)
    );

endmodule
