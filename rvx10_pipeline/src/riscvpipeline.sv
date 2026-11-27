// riscvpipeline.sv
// 5-Stage Pipelined RISC-V Processor with RVX10 Custom Instructions

module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

  logic [31:0] PCF, InstrF, ReadDataM;
  
  // instantiate processor and memories
  riscvpipeline rvp(clk, reset, PCF, InstrF, MemWrite, DataAdr, 
                    WriteData, ReadDataM);
  imem imem(PCF, InstrF);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadDataM);
endmodule

module riscvpipeline(input  logic        clk, reset,
                     output logic [31:0] PCF,
                     input  logic [31:0] InstrF,
                     output logic        MemWriteM,
                     output logic [31:0] ALUResultM, WriteDataM,
                     input  logic [31:0] ReadDataM);

  // Control signals ID stage
  logic       RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
  logic [1:0] ResultSrcD, ImmSrcD;
  logic [4:0] ALUControlD;
  logic [6:0] opD;
  logic [2:0] funct3D;
  logic [6:0] funct7D;

  // Control signals EX stage
  logic       RegWriteE, MemWriteE, JumpE, BranchE, BranchInvE, ALUSrcE;
  logic [1:0] ResultSrcE;
  logic [4:0] ALUControlE;

  // Control signals MEM stage
  logic       RegWriteM;
  logic [1:0] ResultSrcM;

  // Control signals WB stage
  logic       RegWriteW;
  logic [1:0] ResultSrcW;

  // Hazard signals
  logic       StallF, StallD, FlushD, FlushE;
  logic [1:0] ForwardAE, ForwardBE;
  logic       PCSrcE; // From datapath branch evaluation

  // Instruction Decode fields needed for Controller
  logic [31:0] InstrD;
  assign opD = InstrD[6:0];
  assign funct3D = InstrD[14:12];
  assign funct7D = InstrD[31:25];

  // Hazard unit register addresses
  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;

  controller c(clk, reset, opD, funct3D, funct7D,
               FlushE, // Clear EX control signals on flush
               ResultSrcD, MemWriteD, BranchD,
               ALUSrcD, RegWriteD, JumpD,
               ImmSrcD, ALUControlD,
               ResultSrcE, MemWriteE, BranchE, BranchInvE, ALUSrcE, RegWriteE, JumpE, ALUControlE,
               ResultSrcM, MemWriteM, RegWriteM,
               ResultSrcW, RegWriteW);

  datapath dp(clk, reset,
              // Hazard unit interface
              StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE,
              Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
              // ID Stage
              ResultSrcW, RegWriteW, ImmSrcD,
              // EX Stage
              BranchE, BranchInvE, JumpE, PCSrcE, ALUSrcE, ALUControlE,
              // MEM Stage
              ResultSrcM,
              // External Memory Interface
              PCF, InstrF, InstrD, ALUResultM, WriteDataM, ReadDataM);

  hazard_unit hu(Rs1D, Rs2D, Rs1E, Rs2E, RdE, PCSrcE, ResultSrcE,
                 RdM, RegWriteM,
                 RdW, RegWriteW,
                 StallF, StallD, FlushD, FlushE,
                 ForwardAE, ForwardBE);

endmodule

// Helper modules (Memories)
/* verilator lint_off UNUSED */
module imem(input  logic [31:0] a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];
  initial begin
    for (int i = 0; i < 64; i++)
      RAM[i] = 32'h00000013; // Initialize with NOP (addi x0, x0, 0)
    $readmemh("tests/rvx10_pipeline.hex", RAM);
  end
  assign rd = RAM[a[7:2]]; // word aligned
endmodule

module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];
  initial begin
    for (int i = 0; i < 64; i++)
      RAM[i] = 32'h00000000;
    // Initialize benchmark array at byte address 64 (0x40): [-5, 10, -25, 3]
    RAM[16] = 32'hFFFF_FFFB; // -5
    RAM[17] = 32'd10;        //  10
    RAM[18] = 32'hFFFF_FFE7; // -25
    RAM[19] = 32'd3;         //  3
  end
  assign rd = RAM[a[7:2]]; // word aligned
  always_ff @(posedge clk)
    if (we) RAM[a[7:2]] <= wd;
endmodule
/* verilator lint_on UNUSED */
