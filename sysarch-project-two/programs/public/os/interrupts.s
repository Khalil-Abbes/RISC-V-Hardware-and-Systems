# Setup the exception handler
la t0, exception_handler
csrw mtvec, t0

# Enable machine external interrupts
csrr t0, mstatus
ori t0, t0, 0x8  # Set MIE bit
csrw mstatus, t0

csrr t0, mie          # Read current value of mie into t0
li t1, 0x800          # Load the hexadecimal value 0x800 directly (for MEIE bit)
or t0, t0, t1         # Perform bitwise OR to set the MEIE bit in t0
csrw mie, t0          # Write the new value back to mie

# Set mepc to start of Fibonacci program
li t0, 0x4000000      # Address of the Fibonacci function
csrw mepc, t0

# Buffer initialization
li t1, 256            # Designated buffer start address
li t2, 512            # End of buffer (256 bytes later)
sw zero, 0(t1)        # Initialize buffer area to zero
sw zero, 0(t2)        # Set end marker
li t1, 0
li t2, 0
li t0, 0
mret                  # Jump to user mode, start execution

# Exception Handler
exception_handler:
    # Save Registers
    sw ra, 4(zero)
    sw t0, 8(zero)
    sw t1, 12(zero)
    sw t2, 16(zero)
    sw t3, 20(zero)
    sw t4, 24(zero)
    sw t5, 28(zero)
    sw t6, 32(zero)
    sw a0, 36(zero)
    sw a1, 40(zero)
    sw a2, 44(zero)
    sw a3, 48(zero)
    sw a4, 52(zero)
    sw a5, 56(zero)
    sw a6, 60(zero)
    sw a7, 64(zero)

    # Check cause of the exception
    csrr t0, mcause
    beqz t0, handle_interrupt  # Check if it's an interrupt

handle_interrupt:
    # Keyboard handling
    la t3, keyboard_ready
    lbu t4, 0(t3)
    andi t4, t4, 0x1
    beqz t4, check_display

    # Read character from keyboard
    la t3, keyboard_data
    lbu a0, 0(t3)

    # Find empty spot in buffer
    li t1, 256
    li t2, 271            # End of buffer (16 bytes later)
buffer_fill:
    lbu t3, 0(t1)          # Load byte from buffer
    bnez t3, continue_fill # If not zero, continue searching
    sb a0, 0(t1)           # Store the character
    j check_display
continue_fill:
    addi t1, t1, 1         # Increment buffer address
    blt t1, t2, buffer_fill # Check if within buffer bounds

check_display:
    # Display handling
    li t1, 256
    li t2, 271
buffer_display:
    lbu a0, 0(t1)
    beqz a0, check  # If zero, buffer is empty or end reached
    j done
check:
    addi t1, t1, 1         # Increment buffer address
    blt t1, t2, buffer_display  # Check if within buffer bounds
    j finalize_interrupt

 done:
    # Display the character
    la t4, display_ready
    lbu t2, 0(t4)
    andi t2, t2, 0x1
    beqz t2, finalize_interrupt

    la t5, display_data
    sb a0, 0(t5)   # Display character
    li t3, 0
    sb t3, 0(t1)   # Clear buffer slot

finalize_interrupt:
    # Clear any pending interrupts by writing to mip
    li t1, 2048
    csrrc zero, mip, t1

    # Increment mepc by 4 to continue from the next instruction
    csrr t1, mepc
    addi t1, t1, 4
    csrw mepc, t1

    # Restore Registers and Return
    lw ra, 4(zero)
    lw t0, 8(zero)
    lw t1, 12(zero)
    lw t2, 16(zero)
    lw t3, 20(zero)
    lw t4, 24(zero)
    lw t5, 28(zero)
    lw t6, 32(zero)
    lw a0, 36(zero)
    lw a1, 40(zero)
    lw a2, 44(zero)
    lw a3, 48(zero)
    lw a4, 52(zero)
    lw a5, 56(zero)
    lw a6, 60(zero)
    lw a7, 64(zero)

    mret  # Return to the next instruction
