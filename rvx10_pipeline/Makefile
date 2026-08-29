# Makefile for RVX10 Pipeline Verilator Simulation

VERILATOR = verilator
VERILATOR_FLAGS = -Wall --cc --exe --build -Isrc
TARGET = Vtop

all: sim

sim:
	$(VERILATOR) $(VERILATOR_FLAGS) tb/tb_pipeline.cpp src/riscvpipeline.sv src/controller.sv src/datapath.sv src/hazard_unit.sv
	./obj_dir/$(TARGET)

clean:
	rm -rf obj_dir
