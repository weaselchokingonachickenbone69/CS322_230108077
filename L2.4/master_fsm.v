module master_fsm(
    input  wire clk,
    input  wire rst, 
    input  wire ack,
    output reg  req,
    output reg [7:0] data,
    output reg  done
);
    parameter NUM_BYTES = 4;

    reg [7:0] bytes [0:NUM_BYTES-1];
    initial begin
        bytes[0] = 8'hA0;
        bytes[1] = 8'hA1;
        bytes[2] = 8'hA2;
        bytes[3] = 8'hA3;
    end

    localparam [2:0] M_IDLE         = 3'd0;
    localparam [2:0] M_REQ          = 3'd1;
    localparam [2:0] M_WAIT_ACK     = 3'd2;
    localparam [2:0] M_DROP_REQ     = 3'd3;
    localparam [2:0] M_WAIT_ACK_LOW = 3'd4;
    localparam [2:0] M_DONE         = 3'd5;

    reg [2:0] state, next_state;
    integer idx, next_idx;

    always @(posedge clk) begin
        if (rst) begin
            state <= M_IDLE;
            idx <= 0;
            req <= 1'b0;
            data <= 8'd0;
            done <= 1'b0;
        end else begin
            state <= next_state;
            idx <= next_idx;
            req <= req;   
            data <= data; 
            done <= done;
        end
    end

    reg req_comb;
    reg [7:0] data_comb;
    reg done_comb;

    always @(*) begin
        next_state = state;
        next_idx = idx;
        req_comb = 1'b0;
        data_comb = 8'd0;
        done_comb = 1'b0;

        case (state)
            M_IDLE: begin
                next_state = M_REQ;
                next_idx = 0;
            end

            M_REQ: begin
                req_comb = 1'b1;
                data_comb = bytes[idx];
                next_state = M_WAIT_ACK;
            end

            M_WAIT_ACK: begin
                req_comb = 1'b1;
                data_comb = bytes[idx];
                if (ack) begin
                    next_state = M_DROP_REQ;
                    next_idx = idx; 
                end else begin
                    next_state = M_WAIT_ACK;
                end
            end

            M_DROP_REQ: begin
                req_comb = 1'b0;
                data_comb = bytes[idx];
                next_state = M_WAIT_ACK_LOW;
                next_idx = idx + 1;
            end

            M_WAIT_ACK_LOW: begin
                req_comb = 1'b0;
                if (!ack) begin
                    if (next_idx >= NUM_BYTES) begin
                        next_state = M_DONE;
                    end else begin
                        next_state = M_REQ;
                    end
                end else begin
                    next_state = M_WAIT_ACK_LOW;
                end
            end

            M_DONE: begin
                done_comb = 1'b1;
                next_state = M_DONE;
            end

            default: begin
                next_state = M_IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            req <= 1'b0;
            data <= 8'd0;
            done <= 1'b0;
        end else begin
            req <= req_comb;
            data <= data_comb;
            done <= done_comb;
        end
    end

endmodule
