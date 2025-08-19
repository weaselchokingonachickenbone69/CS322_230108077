module slave_fsm(
    input  wire clk,
    input  wire rst,
    input  wire req,
    input  wire [7:0] data_in,
    output reg  ack,
    output reg [7:0] last_byte
);
    localparam [1:0] S_WAIT = 2'b00;
    localparam [1:0] S_ACK1 = 2'b01;
    localparam [1:0] S_ACK2 = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge clk) begin
        if (rst) begin
            state <= S_WAIT;
            ack <= 1'b0;
            last_byte <= 8'd0;
        end else begin
            state <= next_state;
            ack <= ack;         
            last_byte <= last_byte;
        end
    end

    reg ack_comb;
    reg [7:0] last_byte_comb;

    always @(*) begin
        next_state = state;
        ack_comb = 1'b0;
        last_byte_comb = last_byte;

        case (state)
            S_WAIT: begin
                ack_comb = 1'b0;
                if (req) begin
                    last_byte_comb = data_in;
                    next_state = S_ACK1;
                end else begin
                    next_state = S_WAIT;
                end
            end

            S_ACK1: begin
                ack_comb = 1'b1;
                next_state = S_ACK2;
            end

            S_ACK2: begin
                ack_comb = 1'b1;
                next_state = S_WAIT;
            end

            default: begin
                ack_comb = 1'b0;
                next_state = S_WAIT;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            ack <= 1'b0;
            last_byte <= 8'd0;
        end else begin
            ack <= ack_comb;
            last_byte <= last_byte_comb;
        end
    end

endmodule
