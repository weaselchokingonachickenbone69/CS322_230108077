# Verilog Comparator Circuits

This folder contains Verilog HDL implementations and testbenches for:

## 🧮 4-bit Equality Comparator

### Functionality:
Compares two 4-bit binary inputs A and B:
- `equal = 1` if A == B

### Files:
- `fout_bit_equality.v`: Module definition
- `test_bench`: Testbench with test cases

---

## ✅ How to Run using **Icarus Verilog (with GTKWave)**

### Example (Icarus Verilog + GTKWave):

open folder in terminal
```bash
iverilog -o sim_out four_bit_equality.v test_bench.v
vvp sim_out
gtkwave wave.vcd
