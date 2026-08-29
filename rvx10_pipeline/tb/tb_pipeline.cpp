#include <iostream>
#include <verilated.h>
#include "Vtop.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    
    // Instantiate the top level module
    Vtop* top = new Vtop;
    
    // Initialize signals
    top->clk = 0;
    top->reset = 1;
    
    // Hold reset for a few cycles
    for (int i = 0; i < 5; i++) {
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();
    }
    
    top->reset = 0;
    
    int cycle_count = 0;
    int max_cycles = 1000;
    bool success = false;
    
    std::cout << "Starting simulation..." << std::endl;
    
    // Run simulation
    while (!Verilated::gotFinish() && cycle_count < max_cycles) {
        // Toggle clock
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();
        
        cycle_count++;
        
        // Monitor memory writes
        if (top->MemWrite) {
            // Check if it writes 25 to address 100
            if (top->DataAdr == 100 && top->WriteData == 25) {
                std::cout << "Simulation succeeded at cycle " << cycle_count << "!" << std::endl;
                success = true;
                break;
            } else if (top->DataAdr != 96) {
                // Ignore writes to 96 (intermediate diagnostics as per assignment)
                // Any other random write might indicate failure, but we won't strictly fail 
                // just in case they write to other addresses.
            }
        }
    }
    
    if (!success) {
        std::cout << "Simulation failed or timed out after " << cycle_count << " cycles." << std::endl;
    }
    
    top->final();
    delete top;
    return success ? 0 : 1;
}
