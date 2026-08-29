module vending_mealy(
    input  wire clk,
    input  wire rst,     
    input  wire [1:0] coin, 
    output reg dispense, 
    output reg chg5      
);

    localparam [1:0] T0  = 2'b00;
    localparam [1:0] T5  = 2'b01;
    localparam [1:0] T10 = 2'b10;
    localparam [1:0] T15 = 2'b11;

    reg [1:0] state, next_state;
    reg dispense_next, chg5_next;

    always @(posedge clk) begin
        if (rst) begin
            state    <= T0;
            dispense <= 1'b0;
            chg5     <= 1'b0;
        end else begin
            state    <= next_state;
            dispense <= dispense_next;
            chg5     <= chg5_next;
        end
    end

    always @(*) begin
        next_state = state;
        dispense_next = 1'b0;
        chg5_next = 1'b0;

        case (state)
            T0: begin
                case (coin)
                    2'b01: next_state = T5;      
                    2'b10: next_state = T10;    
                    default: next_state = T0; 
                endcase
            end

            T5: begin
                case (coin)
                    2'b01: next_state = T10;     
                    2'b10: next_state = T15;    
                    default: next_state = T5;
                endcase
            end

            T10: begin
                case (coin)
                    2'b01: next_state = T15;     
                    2'b10: begin                 
                        dispense_next = 1'b1;
                        chg5_next = 1'b0;
                        next_state = T0;
                    end
                    default: next_state = T10;
                endcase
            end

            T15: begin
                case (coin)
                    2'b01: begin                 
                        dispense_next = 1'b1;
                        chg5_next = 1'b0;
                        next_state = T0;
                    end
                    2'b10: begin                 
                        dispense_next = 1'b1;
                        chg5_next = 1'b1;
                        next_state = T0;
                    end
                    default: next_state = T15;
                endcase
            end

            default: begin
                next_state = T0;
                dispense_next = 1'b0;
                chg5_next = 1'b0;
            end
        endcase
    end

endmodule
