# 5-Stage Pipelined RISC-V Core (RVX10-P)

This repository contains the RTL implementation of a 5-stage pipelined RISC-V soft-core processor (RV32I), extended with 10 custom hardware instructions for improved performance on specific workloads.

## Project Overview

The core is designed in SystemVerilog and features a classic 5-stage pipeline (`Instruction Fetch`, `Instruction Decode`, `Execute`, `Memory Access`, and `Write Back`).

### Key Architectural Features:
- **Full Hazard Handling**: Includes a hazard unit that implements data forwarding (bypassing) from the MEM and WB stages to the EX stage to prevent data hazards.
- **Pipeline Stalls & Flushes**: Implements load-use hazard detection that inserts 1-cycle stalls. Handles control hazards by evaluating branch conditions in the EX stage and flushing the pipeline on taken branches.
- **Custom Instruction Set (RVX10)**: The ALU and control logic were extended to decode and execute 10 custom single-cycle operations natively in hardware, bypassing the need for multi-instruction software equivalents.

### Custom Instructions Implemented
The RVX10 extension adds native support for mathematical and bitwise operations, accelerating specific algorithms without relying on branches. 
- `ABS` (Absolute Value)
- `MIN` / `MAX` (Signed Minimum / Maximum)
- `MINU` / `MAXU` (Unsigned Minimum / Maximum)
- `ANDN` / `ORN` / `XNOR` (Inverted Bitwise Operations)
- `ROL` / `ROR` (Rotate Left / Right)

## Verification and Benchmarking

Instead of relying solely on traditional HDL simulators, the verification environment is written in **C++** using **Verilator**. This bridges hardware architecture with systems software engineering.

### The Benchmark
A custom assembly benchmark (`rvx10_pipeline/tests/benchmark_rvx10.s`) demonstrates the performance advantage of the custom instruction set. The benchmark calculates the maximum absolute value from an array of integers.

**Standard RV32I approach**: Requires conditional branches (`bge`, etc.) to find the absolute value and compare maximums. In a pipeline, taken branches cause pipeline flushes, significantly degrading IPC (Instructions Per Cycle).

**RVX10 approach**: Uses the custom `ABS` and `MAX` instructions, replacing branch logic with single-cycle datapath operations. This eliminates branch misprediction penalties and pipeline flushes, resulting in heavily optimized execution throughput.

## How to Run

1. Ensure [Verilator](https://www.veripool.org/verilator/) and `make` are installed.
2. Navigate to the pipeline directory:
   ```bash
   cd rvx10_pipeline
   ```
3. Run the simulation:
   ```bash
   make sim
   ```
This compiles the Verilog files to C++, builds the testbench, and simulates the core running the benchmark code.
