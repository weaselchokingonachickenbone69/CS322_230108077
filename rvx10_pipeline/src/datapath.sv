// datapath.sv
// Pipelined Datapath for RV32I + RVX10

module datapath(input  logic        clk, reset,
                // Hazard unit interface
                input  logic        StallF, StallD, FlushD, FlushE,
                input  logic [1:0]  ForwardAE, ForwardBE,
                output logic [4:0]  Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
                // ID Stage
                input  logic [1:0]  ResultSrcW, 
                input  logic        RegWriteW,
                input  logic [1:0]  ImmSrcD,
                // EX Stage
                input  logic        BranchE,
                input  logic        BranchInvE,
                input  logic        JumpE,
                output logic        PCSrcE,
                input  logic        ALUSrcE,
                input  logic [4:0]  ALUControlE,
                // MEM Stage
                input  logic [1:0]  ResultSrcM,
                // External Memory Interface
                output logic [31:0] PCF,
                input  logic [31:0] InstrF,
                output logic [31:0] InstrD,
                output logic [31:0] ALUResultM, WriteDataM,
                input  logic [31:0] ReadDataM);

  // --- Fetch Stage ---
  logic [31:0] PCNextF, PCPlus4F;
  logic [31:0] PCTargetE;

  mux2 #(32) pcmux(PCPlus4F, PCTargetE, PCSrcE, PCNextF);
  
  flopenr #(32) pcreg(clk, reset, ~StallF, PCNextF, PCF);
  adder pcadd4(PCF, 32'd4, PCPlus4F);

  // --- Decode Stage ---
  logic [31:0] PCD, PCPlus4D;
  flopenrc #(96) ifid_reg(clk, reset, ~StallD, FlushD,
                          {InstrF, PCF, PCPlus4F},
                          {InstrD, PCD, PCPlus4D});

  logic [31:0] RD1D, RD2D;
  logic [31:0] ImmExtD;
  logic [4:0]  RdD;
  logic [31:0] ResultW;

  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];

  regfile rf(clk, RegWriteW, Rs1D, Rs2D, RdW, ResultW, RD1D, RD2D);
  extend ext(InstrD[31:7], ImmSrcD, ImmExtD);

  // --- Execute Stage ---
  logic [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E;

  floprc #(175) idex_reg(clk, reset, FlushE,
                         {RD1D, RD2D, PCD, ImmExtD, PCPlus4D, Rs1D, Rs2D, RdD},
                         {RD1E, RD2E, PCE, ImmExtE, PCPlus4E, Rs1E, Rs2E, RdE});

  logic [31:0] SrcAE, SrcBE, WriteDataE;
  logic [31:0] ALUResultE;
  logic [31:0] ForwardDataM;
  logic        ZeroE, BranchTakenE;

  mux3 #(32) forwardamux(RD1E, ResultW, ForwardDataM, ForwardAE, SrcAE);
  mux3 #(32) forwardbmux(RD2E, ResultW, ForwardDataM, ForwardBE, WriteDataE);

  mux2 #(32) srcbmux(WriteDataE, ImmExtE, ALUSrcE, SrcBE);

  alu alu(SrcAE, SrcBE, ALUControlE, ALUResultE, ZeroE);

  adder pcaddbranch(PCE, ImmExtE, PCTargetE);
  assign BranchTakenE = BranchE & (BranchInvE ? ~ZeroE : ZeroE);
  assign PCSrcE = BranchTakenE | JumpE;

  // --- MEM Stage ---
  logic [31:0] PCPlus4M;

  flopr #(101) exmem_reg(clk, reset,
                         {ALUResultE, WriteDataE, RdE, PCPlus4E},
                         {ALUResultM, WriteDataM, RdM, PCPlus4M});

  // Forward PCPlus4M when MEM holds a jal instruction (ResultSrcM == 2'b10)
  assign ForwardDataM = (ResultSrcM == 2'b10) ? PCPlus4M : ALUResultM;

  // --- WB Stage ---
  logic [31:0] ALUResultW, ReadDataW, PCPlus4W;

  flopr #(101) memwb_reg(clk, reset,
                         {ALUResultM, ReadDataM, RdM, PCPlus4M},
                         {ALUResultW, ReadDataW, RdW, PCPlus4W});

  mux3 #(32) resultmux(ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, ResultW);

endmodule

// Helper Modules
module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [ 4:0] a1, a2, a3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];
  always_ff @(negedge clk) // write on negative edge to avoid forwarding issues in some simple designs, or use forwarding
    if (we3 && a3 != 0) rf[a3] <= wd3;	

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(input  [31:0] a, b,
             output [31:0] y);
  assign y = a + b;
endmodule

module extend(input  logic [31:7] instr,
              input  logic [1:0]  immsrc,
              output logic [31:0] immext);
  always_comb
    case(immsrc) 
      2'b00:   immext = {{20{instr[31]}}, instr[31:20]};  
      2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
      2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
      2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 
      default: immext = 32'bx;
    endcase             
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);
  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
               (input  logic             clk, reset, en,
                input  logic [WIDTH-1:0] d, 
                output logic [WIDTH-1:0] q);
  always_ff @(posedge clk, posedge reset)
    if (reset)   q <= 0;
    else if (en) q <= d;
endmodule

module floprc #(parameter WIDTH = 8)
               (input  logic             clk, reset, clear,
                input  logic [WIDTH-1:0] d, 
                output logic [WIDTH-1:0] q);
  always_ff @(posedge clk, posedge reset)
    if (reset)     q <= 0;
    else if (clear) q <= 0;
    else           q <= d;
endmodule

module flopenrc #(parameter WIDTH = 8)
                 (input  logic             clk, reset, en, clear,
                  input  logic [WIDTH-1:0] d, 
                  output logic [WIDTH-1:0] q);
  always_ff @(posedge clk, posedge reset)
    if (reset)       q <= 0;
    else if (clear)  q <= 0;
    else if (en)     q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);
  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);
  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module alu(input  logic [31:0] a, b,
           input  logic [4:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  logic [4:0] inv_shamt;
  assign inv_shamt = 5'd0 - b[4:0]; // 32 - b[4:0] mod 32 when b[4:0] != 0

  always_comb begin
    case (alucontrol)
      // Base RV32I Ops
      5'b00000: result = a + b;           // add
      5'b00001: result = a - b;           // sub
      5'b00010: result = a & b;           // and
      5'b00011: result = a | b;           // or
      5'b00100: result = a ^ b;           // xor
      5'b00101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // slt
      
      // RVX10 Custom Ops
      5'b01000: result = a & ~b;          // ANDN
      5'b01001: result = a | ~b;          // ORN
      5'b01010: result = ~(a ^ b);        // XNOR
      5'b01011: result = ($signed(a) < $signed(b)) ? a : b; // MIN
      5'b01100: result = ($signed(a) > $signed(b)) ? a : b; // MAX
      5'b01101: result = (a < b) ? a : b; // MINU (unsigned)
      5'b01110: result = (a > b) ? a : b; // MAXU (unsigned)
      5'b01111: result = (b[4:0] == 5'd0) ? a : ((a << b[4:0]) | (a >> inv_shamt)); // ROL
      5'b10000: result = (b[4:0] == 5'd0) ? a : ((a >> b[4:0]) | (a << inv_shamt)); // ROR
      5'b10001: result = ($signed(a) >= 0) ? a : (32'd0 - a); // ABS
      
      default:  result = 32'd0;
    endcase
  end
  
  assign zero = (result == 32'b0);
endmodule
