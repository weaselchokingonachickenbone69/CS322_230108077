# Problem 1 — seq_detect_mealy

Files:
- seq_detect_mealy.v
- tb_seq_detect_mealy.v

Simulate with Icarus Verilog + GTKWave:

```bash
iverilog -o sim_p1.out tb_seq_detect_mealy.v seq_detect_mealy.v
vvp sim_p1.out
gtkwave dump.vcd
