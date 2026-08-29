// hazard_unit.sv
// Hazard Detection and Forwarding Unit

module hazard_unit(input  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
                   input  logic [4:0] RdE, 
                   input  logic       PCSrcE, 
                   input  logic [1:0] ResultSrcE,
                   input  logic [4:0] RdM, 
                   input  logic       RegWriteM,
                   input  logic [4:0] RdW, 
                   input  logic       RegWriteW,
                   output logic       StallF, StallD, FlushD, FlushE,
                   output logic [1:0] ForwardAE, ForwardBE);

  logic lwStall;

  // Forwarding Logic for ALU inputs in EX stage
  always_comb begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    // Forward from MEM stage
    if (((Rs1E == RdM) && RegWriteM) && (Rs1E != 0)) ForwardAE = 2'b10;
    // Forward from WB stage
    else if (((Rs1E == RdW) && RegWriteW) && (Rs1E != 0)) ForwardAE = 2'b01;

    // Forward from MEM stage
    if (((Rs2E == RdM) && RegWriteM) && (Rs2E != 0)) ForwardBE = 2'b10;
    // Forward from WB stage
    else if (((Rs2E == RdW) && RegWriteW) && (Rs2E != 0)) ForwardBE = 2'b01;
  end

  // Stalling Logic for Load-Use Hazard
  // If instruction in EX is a Load (ResultSrcE == 01) and destination matches ID sources
  assign lwStall = (ResultSrcE == 2'b01) && ((Rs1D == RdE) || (Rs2D == RdE)) && (RdE != 0);

  assign StallF = lwStall;
  assign StallD = lwStall;

  // Control Hazard Flushing
  // When a branch is taken (PCSrcE == 1), flush the instructions in ID and EX stages
  assign FlushD = PCSrcE;
  assign FlushE = lwStall | PCSrcE;

endmodule
