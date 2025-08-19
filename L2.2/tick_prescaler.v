module tick_prescaler #(
    parameter integer DIV = 20  
)(
    input  wire clk,
    input  wire rst,  
    output reg  tick
);

    reg [31:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt  <= 32'd0;
            tick <= 1'b0;
        end else begin
            if (DIV <= 1) begin
                tick <= 1'b1;
                cnt  <= 32'd0;
            end else begin
                if (cnt == (DIV - 1)) begin
                    tick <= 1'b1;
                    cnt  <= 32'd0;
                end else begin
                    tick <= 1'b0;
                    cnt  <= cnt + 1;
                end
            end
        end
    end

endmodule
