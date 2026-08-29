# Problem 3 — vending_mealy

Files:
- vending_mealy.v
- tb_vending_mealy.v

Simulation:
```bash
iverilog -o sim_p3.out tb_vending_mealy.v vending_mealy.v
vvp sim_p3.out
gtkwave dump.vcd
