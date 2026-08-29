# Verilog Comparator Circuits

This Folder contains Verilog HDL implementations and testbenches for:
## 🧮 1-bit Comparator

### Functionality:
Given two 1-bit inputs A and B:
- `o1 = 1` if A > B
- `o2 = 1` if A == B
- `o3 = 1` if A < B

### Files:
- `one_bit_comparator.v`: Module definition
- `test_bench.v`: Testbench with test cases

---

## ✅ How to Run using - **Icarus Verilog (with GTKWave)**

### Example (Icarus Verilog + GTKWave):

open folder in terminal:

```bash
# For 1-bit comparator
iverilog -o sim_out one_bit_comparator.v test_bench.v
vvp sim_out
gtkwave one_bit_comparator.vcd
