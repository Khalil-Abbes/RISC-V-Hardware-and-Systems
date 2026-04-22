# Setup the exception handler
la t0, exception_handler
csrw mtvec, t0

# Enable global machine interrupts
csrr t0, mstatus
ori t0, t0, 0x8   # Set the Machine Interrupt Enable (MIE) bit
csrw mstatus, t0 

csrr t0, mie          # Read current value of mie into t0
li t1, 0x80           # Load the hexadecimal value 0x80 directly (for MTIE bit)
or t0, t0, t1         # Perform bitwise OR to set the MTIE bit in t0
csrw mie, t0          # Write the new value back to mie


# Set MEPC to the start of the Fibonacci program
li t0, 0x4000000
csrw mepc, t0



# Enable machine timer interrupts
csrr t0, mstatus
li t1, 0x8
or t0, t0, t1
csrw mstatus, t0

# make mscratch 0
# Assume t0 holds the value you want to store (e.g., the process ID)
li t0, 0
li t1, 0x00000340          # Load address of where mscratch is supposed to be
sw t0, 0(t1)          # Store the value in t0 at address 0x340


csrr t0, mip          # Read the current value of mip into register t0
li t1, 0xFF7F         # Load the bitmask with the 7th bit cleared (0xFF7F = 1111111101111111 binary)
and t0, t0, t1        # Perform bitwise AND to clear the 7th bit
csrw mip, t0          # Write the new value back to the mip register

# Set timer to interrupt after 300 cycles
li t0, 373
la t1, mtime
lw t2, 0(t1)       # Load the lower 32 bits of current mtime
add t2, t2, t0     # Add 300 cycles
la t1, mtimecmp
sw t2, 0(t1)       # Set mtimecmp to the new value for the next interrupt
li t0, 0
li t1, 0
li t2, 0
mret







# TODO: set up exception handler
# TODO: set up mepc to point to the first instruction of the fibonacci function
# TODO: enable and set up interrupts as needed
# TODO: set up data structures for process control blocks
# TODO: execute the fibonacci function until you get an interrupt

exception_handler:
# Save all registers
#change  mscratch
sw t0, 0(zero)
sw t0, 0(zero)
sw t1, 4(zero)

# Assume t0 holds the value you want to store (e.g., the process ID)
#li t1, 0x00000340          # Load address of where mscratch is supposed to be
#sw t0, 0(t1)          # Store the value in t0 at address 0x340

#first time check 
lw t0, 260(zero)
beqz t0, first


# To toggle the process ID stored at 0x340
li t1, 0x00000340          # Load address
lw t0, 0(t1)          # Load current value
xori t0, t0, 1        # Toggle the value between 0 and 1
sw t0, 0(t1)          # Store the toggled value back to 0x340


#branch depending on number
li t1, 1
beq t1, t0 , onetozero
j zerotoone


first:





# Set MEPC to the start of the Fibonacci program
csrr t0, mepc
sw t0, 132(zero) # save mepc
li t0, 0x8000000
csrw mepc, t0
sw t0, 260(zero)


lw t0, 0(zero)
lw t1, 4(zero)
sw x1, 8(zero)   # Save ra
sw x2, 12(zero)   # Save sp
sw x3, 16(zero)   # Save gp
sw x4, 20(zero)  # Save tp
sw x5, 24(zero)  # Save t0
sw x6, 28(zero)  # Save t1
sw x7, 32(zero)  # Save t2
sw x8, 36(zero)  # Save s0/fp
sw x9, 40(zero)  # Save s1
sw x10, 44(zero) # Save a0
sw x11, 48(zero) # Save a1
sw x12, 52(zero) # Save a2
sw x13, 56(zero) # Save a3
sw x14, 60(zero) # Save a4
sw x15, 64(zero) # Save a5
sw x16, 68(zero) # Save a6
sw x17, 72(zero) # Save a7
sw x18, 76(zero) # Save s2
sw x19, 80(zero) # Save s3
sw x20, 84(zero) # Save s4
sw x21, 88(zero) # Save s5
sw x22, 92(zero) # Save s6
sw x23, 96(zero) # Save s7
sw x24, 100(zero)# Save s8
sw x25, 104(zero)# Save s9
sw x26, 108(zero)# Save s10
sw x27, 112(zero)# Save s11
sw x28, 116(zero)# Save t3
sw x29, 120(zero)# Save t4
sw x30, 124(zero)# Save t5
sw x31, 128(zero)# Save t6

csrr t0, mip          # Read the current value of mip into register t0
li t1, 0xFF7F         # Load the bitmask with the 7th bit cleared (0xFF7F = 1111111101111111 binary)
and t0, t0, t1        # Perform bitwise AND to clear the 7th bit
csrw mip, t0          # Write the new value back to the mip register

#reset values

li x1, 0    # Reset ra
li x2, 0    # Reset sp
li x3, 0    # Reset gp
li x4, 0    # Reset tp
li x5, 0    # Reset t0
li x6, 0    # Reset t1
li x7, 0    # Reset t2
li x8, 0    # Reset s0/fp
li x9, 0    # Reset s1
li x10, 0   # Reset a0
li x11, 0   # Reset a1
li x12, 0   # Reset a2
li x13, 0   # Reset a3
li x14, 0   # Reset a4
li x15, 0   # Reset a5
li x16, 0   # Reset a6
li x17, 0   # Reset a7
li x18, 0   # Reset s2
li x19, 0   # Reset s3
li x20, 0   # Reset s4
li x21, 0   # Reset s5
li x22, 0   # Reset s6
li x23, 0   # Reset s7
li x24, 0   # Reset s8
li x25, 0   # Reset s9
li x26, 0   # Reset s10
li x27, 0   # Reset s11
li x28, 0   # Reset t3
li x29, 0   # Reset t4
li x30, 0   # Reset t5
li x31, 0   # Reset t6
#Handle timer interrupt and prepare for process switching
la t0, mtime
lw t1, 0(t0)    # Load the lower 32 bits of mtime
addi t1, t1, 373
la t0, mtimecmp
sw t1, 0(t0)    # Update mtimecmp for the next interval
li t0, 0
li t1, 0
mret

onetozero:



lw t0, 0(zero)
lw t1, 4(zero)
sw x1, 136(zero)   # Save ra
sw x2, 140(zero)   # Save sp
sw x3, 144(zero)   # Save gp
sw x4, 148(zero)   # Save tp
sw x5, 152(zero)   # Save t0
sw x6, 156(zero)   # Save t1
sw x7, 160(zero)   # Save t2
sw x8, 164(zero)   # Save s0/fp
sw x9, 168(zero)   # Save s1
sw x10, 172(zero)  # Save a0
sw x11, 176(zero)  # Save a1
sw x12, 180(zero)  # Save a2
sw x13, 184(zero)  # Save a3
sw x14, 188(zero)  # Save a4
sw x15, 192(zero)  # Save a5
sw x16, 196(zero)  # Save a6
sw x17, 200(zero)  # Save a7
sw x18, 204(zero)  # Save s2
sw x19, 208(zero)  # Save s3
sw x20, 212(zero)  # Save s4
sw x21, 216(zero)  # Save s5
sw x22, 220(zero)  # Save s6
sw x23, 224(zero)  # Save s7
sw x24, 228(zero)  # Save s8
sw x25, 232(zero)  # Save s9
sw x26, 236(zero)  # Save s10
sw x27, 240(zero)  # Save s11
sw x28, 244(zero)  # Save t3
sw x29, 248(zero)  # Save t4
sw x30, 252(zero)  # Save t5
sw x31, 256(zero)  # Save t6
csrr t0, mepc
sw t0, 260(zero) # save mepc


csrr t0, mip          # Read the current value of mip into register t0
li t1, 0xFF7F         # Load the bitmask with the 7th bit cleared (0xFF7F = 1111111101111111 binary)
and t0, t0, t1        # Perform bitwise AND to clear the 7th bit
csrw mip, t0          # Write the new value back to the mip register

#Handle timer interrupt and prepare for process switching
la t0, mtime
lw t1, 0(t0)    # Load the lower 32 bits of mtime
addi t1, t1, 373
la t0, mtimecmp
sw t1, 0(t0)    # Update mtimecmp for the next interval
lw t0, 132(zero)
csrw mepc, t0
lw x1, 8(zero)   # Load ra
lw x2, 12(zero)   # Load sp
lw x3, 16(zero)   # Load gp
lw x4, 20(zero)  # Load tp
lw x5, 24(zero)  # Load t0
lw x6, 28(zero)  # Load t1
lw x7, 32(zero)  # Load t2
lw x8, 36(zero)  # Load s0/fp
lw x9, 40(zero)  # Load s1
lw x10, 44(zero) # Load a0
lw x11, 48(zero) # Load a1
lw x12, 52(zero) # Load a2
lw x13, 56(zero) # Load a3
lw x14, 60(zero) # Load a4
lw x15, 64(zero) # Load a5
lw x16, 68(zero) # Load a6
lw x17, 72(zero) # Load a7
lw x18, 76(zero) # Load s2
lw x19, 80(zero) # Load s3
lw x20, 84(zero) # Load s4
lw x21, 88(zero) # Load s5
lw x22, 92(zero) # Load s6
lw x23, 96(zero) # Load s7
lw x24, 100(zero)# Load s8
lw x25, 104(zero)# Load s9
lw x26, 108(zero)# Load s10
lw x27, 112(zero)# Load s11
lw x28, 116(zero)# Load t3
lw x29, 120(zero)# Load t4
lw x30, 124(zero)# Load t5
lw x31, 128(zero)# Load t6









mret

zerotoone:




lw t0, 0(zero)
lw t1, 4(zero)
sw x1, 8(zero)   # Save ra
sw x2, 12(zero)   # Save sp
sw x3, 16(zero)   # Save gp
sw x4, 20(zero)  # Save tp
sw x5, 24(zero)  # Save t0
sw x6, 28(zero)  # Save t1
sw x7, 32(zero)  # Save t2
sw x8, 36(zero)  # Save s0/fp
sw x9, 40(zero)  # Save s1
sw x10, 44(zero) # Save a0
sw x11, 48(zero) # Save a1
sw x12, 52(zero) # Save a2
sw x13, 56(zero) # Save a3
sw x14, 60(zero) # Save a4
sw x15, 64(zero) # Save a5
sw x16, 68(zero) # Save a6
sw x17, 72(zero) # Save a7
sw x18, 76(zero) # Save s2
sw x19, 80(zero) # Save s3
sw x20, 84(zero) # Save s4
sw x21, 88(zero) # Save s5
sw x22, 92(zero) # Save s6
sw x23, 96(zero) # Save s7
sw x24, 100(zero)# Save s8
sw x25, 104(zero)# Save s9
sw x26, 108(zero)# Save s10
sw x27, 112(zero)# Save s11
sw x28, 116(zero)# Save t3
sw x29, 120(zero)# Save t4
sw x30, 124(zero)# Save t5
sw x31, 128(zero)# Save t6
csrr t0, mepc
sw t0, 132(zero) # save mepc

lw t0, 260(zero)
csrw mepc, t0

csrr t0, mip          # Read the current value of mip into register t0
li t1, 0xFF7F         # Load the bitmask with the 7th bit cleared (0xFF7F = 1111111101111111 binary)
and t0, t0, t1        # Perform bitwise AND to clear the 7th bit
csrw mip, t0          # Write the new value back to the mip register

#Handle timer interrupt and prepare for process switching
la t0, mtime
lw t1, 0(t0)    # Load the lower 32 bits of mtime
addi t1, t1, 373
la t0, mtimecmp
sw t1, 0(t0)    # Update mtimecmp for the next interval


lw x1, 136(zero)   # Load ra
lw x2, 140(zero)   # Load sp
lw x3, 144(zero)   # Load gp
lw x4, 148(zero)   # Load tp
lw x5, 152(zero)   # Load t0
lw x6, 156(zero)   # Load t1
lw x7, 160(zero)   # Load t2
lw x8, 164(zero)   # Load s0/fp
lw x9, 168(zero)   # Load s1
lw x10, 172(zero)  # Load a0
lw x11, 176(zero)  # Load a1
lw x12, 180(zero)  # Load a2
lw x13, 184(zero)  # Load a3
lw x14, 188(zero)  # Load a4
lw x15, 192(zero)  # Load a5
lw x16, 196(zero)  # Load a6
lw x17, 200(zero)  # Load a7
lw x18, 204(zero)  # Load s2
lw x19, 208(zero)  # Load s3
lw x20, 212(zero)  # Load s4
lw x21, 216(zero)  # Load s5
lw x22, 220(zero)  # Load s6
lw x23, 224(zero)  # Load s7
lw x24, 228(zero)  # Load s8
lw x25, 232(zero)  # Load s9
lw x26, 236(zero)  # Load s10
lw x27, 240(zero)  # Load s11
lw x28, 244(zero)  # Load t3
lw x29, 248(zero)  # Load t4
lw x30, 252(zero)  # Load t5
lw x31, 256(zero)  # Load t6





#reset values:




mret  # Return to the next process's saved program counter

    # TODO: save some registers
    # TODO: set up new timer interrupt + implement process switch
    # TODO: return to user mode to continue with next process