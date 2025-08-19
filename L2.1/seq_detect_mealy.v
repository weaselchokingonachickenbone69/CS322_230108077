module seq_detect_mealy(
    input  wire clk,
    input  wire rst,
    input  wire din,
    output reg  y 
);

    localparam [1:0] S_A = 2'b00; 
    localparam [1:0] S_B = 2'b01; 
    localparam [1:0] S_C = 2'b10; 
    localparam [1:0] S_D = 2'b11;

    reg [1:0] state, next_state;
    reg       y_next;

    always @(posedge clk) begin
        if (rst) begin
            state <= S_A;
            y     <= 1'b0;
        end else begin
            state <= next_state;
            y     <= y_next;
        end
    end

    always @(*) begin
        next_state = state;
        y_next = 1'b0;

        case (state)
            S_A: begin
                if (din) next_state = S_B;
                else     next_state = S_A;
            end

            S_B: begin
                if (din) next_state = S_C;
                else     next_state = S_A;
            end

            S_C: begin
                if (din) next_state = S_D;
                else     next_state = S_A;
            end

            S_D: begin
                if (din) begin
                    y_next = 1'b1;
                    next_state = S_B;
                end else begin
                    next_state = S_A;
                end
            end

            default: begin
                next_state = S_A;
                y_next = 1'b0;
            end
        endcase
    end

endmodule
