module traffic_light #(
    parameter integer NS_G_T = 5,
    parameter integer NS_Y_T = 2,
    parameter integer EW_G_T = 5,
    parameter integer EW_Y_T = 2
)(
    input  wire clk,
    input  wire rst, 
    input  wire tick,
    output reg ns_g, ns_y, ns_r,
    output reg ew_g, ew_y, ew_r
);

    localparam [1:0] S_NS_G = 2'b00;
    localparam [1:0] S_NS_Y = 2'b01;
    localparam [1:0] S_EW_G = 2'b10;
    localparam [1:0] S_EW_Y = 2'b11;

    reg [1:0] state, next_state;
    integer cnt, next_cnt;

    always @(posedge clk) begin
        if (rst) begin
            state <= S_NS_G;
            cnt <= 0;
        end else begin
            state <= next_state;
            cnt <= next_cnt;
        end
    end

    always @(*) begin
        ns_g = 1'b0; ns_y = 1'b0; ns_r = 1'b0;
        ew_g = 1'b0; ew_y = 1'b0; ew_r = 1'b0;

        next_state = state;
        next_cnt = cnt;

        case (state)
            S_NS_G: begin
                ns_g = 1'b1;
                ew_r = 1'b1;
                if (tick) begin
                    if (cnt == NS_G_T - 1) begin
                        next_state = S_NS_Y;
                        next_cnt = 0;
                    end else begin
                        next_state = S_NS_G;
                        next_cnt = cnt + 1;
                    end
                end
            end

            S_NS_Y: begin
                ns_y = 1'b1;
                ew_r = 1'b1;
                if (tick) begin
                    if (cnt == NS_Y_T - 1) begin
                        next_state = S_EW_G;
                        next_cnt = 0;
                    end else begin
                        next_state = S_NS_Y;
                        next_cnt = cnt + 1;
                    end
                end
            end

            S_EW_G: begin
                ew_g = 1'b1;
                ns_r = 1'b1;
                if (tick) begin
                    if (cnt == EW_G_T - 1) begin
                        next_state = S_EW_Y;
                        next_cnt = 0;
                    end else begin
                        next_state = S_EW_G;
                        next_cnt = cnt + 1;
                    end
                end
            end

            S_EW_Y: begin
                ew_y = 1'b1;
                ns_r = 1'b1;
                if (tick) begin
                    if (cnt == EW_Y_T - 1) begin
                        next_state = S_NS_G;
                        next_cnt = 0;
                    end else begin
                        next_state = S_EW_Y;
                        next_cnt = cnt + 1;
                    end
                end
            end

            default: begin
                next_state = S_NS_G;
                next_cnt = 0;
            end
        endcase
    end

endmodule
