# benchmark_rvx10.s
#
# This benchmark calculates the maximum absolute value from an array of 4 integers.
# It demonstrates the power of the custom RVX10 instructions (ABS and MAX),
# saving several branches and pipeline flushes per loop iteration.
#
# Array at address 64 (0x40): [-5, 10, -25, 3]
# Max absolute value: 25

    addi x3, x0, 64        # x3 = 64 (array pointer)
    addi x4, x0, 4         # x4 = 4 (loop counter)
    addi x6, x0, 0         # x6 = 0 (current max absolute value)

loop:
    lw x5, 0(x3)           # x5 = mem[x3]
    
    # Custom RVX10 Instructions - No branches required!
    ABS x5, x5             # x5 = abs(x5)
    MAX x6, x6, x5         # x6 = max(x6, x5)
    
    addi x3, x3, 4         # advance pointer
    addi x4, x4, -1        # decrement counter
    bne x4, x0, loop       # if x4 != 0, loop again
    
    sw x6, 100(x0)         # mem[100] = x6 (Stores 25, Verilator detects success)
    
done:
    beq x0, x0, done       # infinite loop
