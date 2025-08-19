# Problem 2 — traffic_light (with tick prescaler)

Files:
- traffic_light.v           
- tick_prescaler.v           
- tb_traffic_light.v         

What changed:
- `tick_prescaler.v` generates a single-cycle `tick` every `DIV` clock cycles.
- The updated TB instantiates the prescaler and connects its `tick` to the `traffic_light` module.
- Leave `traffic_light.v` unchanged; it still consumes a 1-cycle-wide `tick` signal.

Default settings:
- `tick_prescaler` default DIV = 20 (i.e., 1 tick every 20 clk cycles).
- `traffic_light` phase durations: NS_G=5 ticks, NS_Y=2 ticks, EW_G=5 ticks, EW_Y=2 ticks.

Simulation (Icarus Verilog + GTKWave):
```bash
iverilog -o sim_p2_presc.out tb_traffic_light.v traffic_light.v tick_prescaler.v
vvp sim_p2_presc.out
gtkwave dump.vcd
