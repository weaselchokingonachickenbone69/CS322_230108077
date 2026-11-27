// controller.sv
// Pipelined Controller for RV32I + RVX10

module controller(input  logic       clk, reset,
                  input  logic [6:0] opD,
                  input  logic [2:0] funct3D,
                  input  logic [6:0] funct7D,
                  input  logic       FlushE,
                  
                  output logic [1:0] ResultSrcD,
                  output logic       MemWriteD,
                  output logic       BranchD,
                  output logic       ALUSrcD,
                  output logic       RegWriteD,
                  output logic       JumpD,
                  output logic [1:0] ImmSrcD,
                  output logic [4:0] ALUControlD,

                  output logic [1:0] ResultSrcE,
                  output logic       MemWriteE,
                  output logic       BranchE,
                  output logic       BranchInvE,
                  output logic       ALUSrcE,
                  output logic       RegWriteE,
                  output logic       JumpE,
                  output logic [4:0] ALUControlE,

                  output logic [1:0] ResultSrcM,
                  output logic       MemWriteM,
                  output logic       RegWriteM,

                  output logic [1:0] ResultSrcW,
                  output logic       RegWriteW);

  logic [1:0] ALUOpD;
  logic       BranchInvD;

  maindec md(opD, ResultSrcD, MemWriteD, BranchD,
             ALUSrcD, RegWriteD, JumpD, ImmSrcD, ALUOpD);
  aludec  ad(opD[5], funct3D, funct7D, ALUOpD, ALUControlD);

  assign BranchInvD = (funct3D == 3'b001); // bne when BranchD is asserted

  // Pipeline Registers
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      ResultSrcE  <= 2'b00;
      MemWriteE   <= 1'b0;
      BranchE     <= 1'b0;
      BranchInvE  <= 1'b0;
      ALUSrcE     <= 1'b0;
      RegWriteE   <= 1'b0;
      JumpE       <= 1'b0;
      ALUControlE <= 5'b00000;
    end else if (FlushE) begin
      ResultSrcE  <= 2'b00;
      MemWriteE   <= 1'b0;
      BranchE     <= 1'b0;
      BranchInvE  <= 1'b0;
      ALUSrcE     <= 1'b0;
      RegWriteE   <= 1'b0;
      JumpE       <= 1'b0;
      ALUControlE <= 5'b00000;
    end else begin
      ResultSrcE  <= ResultSrcD;
      MemWriteE   <= MemWriteD;
      BranchE     <= BranchD;
      BranchInvE  <= BranchInvD;
      ALUSrcE     <= ALUSrcD;
      RegWriteE   <= RegWriteD;
      JumpE       <= JumpD;
      ALUControlE <= ALUControlD;
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      ResultSrcM <= 2'b00;
      MemWriteM  <= 1'b0;
      RegWriteM  <= 1'b0;
    end else begin
      ResultSrcM <= ResultSrcE;
      MemWriteM  <= MemWriteE;
      RegWriteM  <= RegWriteE;
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      ResultSrcW <= 2'b00;
      RegWriteW  <= 1'b0;
    end else begin
      ResultSrcW <= ResultSrcM;
      RegWriteW  <= RegWriteM;
    end
  end

endmodule

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic       MemWrite,
               output logic       Branch, ALUSrc,
               output logic       RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp);

  logic [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case(op)
    // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_00_0_0_00_0_10_0; // R-type
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq / bne
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0001011: controls = 11'b1_00_0_0_00_0_11_0; // RVX10 (Custom-0) R-type
      default:    controls = 11'b0_00_0_0_00_0_00_0; // safe NOP for unimplemented ops
    endcase
endmodule

module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic [6:0] funct7, 
              input  logic [1:0] ALUOp,
              output logic [4:0] ALUControl);

  logic  RtypeSub;
  assign RtypeSub = funct7[5] & opb5;  // TRUE for R-type subtract instruction (if not RVX10)

  always_comb
    case(ALUOp)
      2'b00:                ALUControl = 5'b00000; // addition (lw/sw)
      2'b01:                ALUControl = 5'b00001; // subtraction (beq/bne)
      2'b10: case(funct3) // RV32I R-type or I-type ALU
                 3'b000:  if (RtypeSub) 
                            ALUControl = 5'b00001; // sub
                          else          
                            ALUControl = 5'b00000; // add, addi
                 3'b010:    ALUControl = 5'b00101; // slt, slti
                 3'b100:    ALUControl = 5'b00100; // xor, xori
                 3'b110:    ALUControl = 5'b00011; // or, ori
                 3'b111:    ALUControl = 5'b00010; // and, andi
                 default:   ALUControl = 5'b00000;
               endcase
      2'b11: case({funct7, funct3}) // RVX10 ops
                 10'b0000000_000: ALUControl = 5'b01000; // ANDN
                 10'b0000000_001: ALUControl = 5'b01001; // ORN
                 10'b0000000_010: ALUControl = 5'b01010; // XNOR
                 10'b0000001_000: ALUControl = 5'b01011; // MIN
                 10'b0000001_001: ALUControl = 5'b01100; // MAX
                 10'b0000001_010: ALUControl = 5'b01101; // MINU
                 10'b0000001_011: ALUControl = 5'b01110; // MAXU
                 10'b0000010_000: ALUControl = 5'b01111; // ROL
                 10'b0000010_001: ALUControl = 5'b10000; // ROR
                 10'b0000011_000: ALUControl = 5'b10001; // ABS
                 default:         ALUControl = 5'b00000;
               endcase
    endcase
endmodule
