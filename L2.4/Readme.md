# Problem 4 — master/slave handshake

Files:
- master_fsm.v
- slave_fsm.v
- link_top.v
- tb_link_top.v

Simulation:
```bash
iverilog -o sim_p4.out tb_link_top.v master_fsm.v slave_fsm.v link_top.v
vvp sim_p4.out
gtkwave dump.vcd
