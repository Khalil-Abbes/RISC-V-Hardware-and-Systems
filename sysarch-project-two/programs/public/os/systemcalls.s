# bootup
_start: 
    la t0, exception_handler        # Load the address of the exception handler into t0
    csrw mtvec, t0                  # Set mtvec to point to the exception handler

    li t1, 0x4000000                # Load the starting address of user_systemcalls into t1
    csrw mepc, t1                   # Set mepc to point to the start of user_systemcalls

    mret                            # Return to user mode, will jump to user_systemcalls

exception_handler:
    # Setup a base register for saving registers in a specific memory range
    li t0, 0x00                      # Assume t0 is now the base for our special memory range

    # Save necessary registers using t0 as the base
    sw ra, 0(t0)                    # Save return address at address 0x0
    sw a0, 4(t0)                    # Save a0 at address 0x4
    sw a1, 8(t0)                    # Save a1 at address 0x8
    sw a2, 12(t0)                   # Save a2 at address 0xc
    sw a3, 16(t0)                   # Save a3 at address 0x10
    sw a4, 20(t0)                   # Save a4 at address 0x14
    sw a5, 24(t0)                   # Save a5 at address 0x18

    # Check the cause of the exception
    csrr a0, mcause                 # Read mcause into a0 to check the cause of the exception
    li t1, 8                        # Load the exception code for system calls
    bne a0, t1, not_a_syscall       # Branch if not a system call

    # If it's a system call, read system call number from a7
    lw a0, 4(t0)                    # Reload original a0 from address 0x4
    lw a1, 8(t0)                    # Reload original a1 from address 0x8
    li t2, 11
    beq a7, t2, handle_syscall_11
    li t2, 4
    beq a7, t2, handle_syscall_4

not_a_syscall:
    j restore_and_exit             # Could handle other types of exceptions if needed

handle_syscall_11:
    # Wait for the display to be ready
wait_for_ready_11:
    la t2, display_ready            # Load the address of display_ready into register t2
    lbu t0, 0(t2)                   # Load the byte at address contained in t2 into t0
    andi t0, t0, 0x01               # Isolate the least significant bit (ready bit)
    beqz t0, wait_for_ready_11      # If ready bit is 0, loop

    # Send the character to the display
    la t3, display_data             # Load the address of display_data into t3
    sb a0, 0(t3)                    # Store the byte from a0 to display_data address
    j restore_and_exit              # Jump to general register restore and exit routine

handle_syscall_4:
    # Begin a loop to process each character of the string
print_string_loop:
    lbu t1, 0(a0)                   # Load the byte at the address in a0 into t1
    beqz t1, restore_and_exit       # If the character is zero (null terminator), exit the loop

    # Wait for the display to be ready
wait_for_ready_4:
    la t2, display_ready            # Load the address of display_ready into register t2
    lbu t0, 0(t2)                   # Load the byte at address contained in t2 into t0
    andi t0, t0, 0x01               # Isolate the least significant bit (ready bit)
    beqz t0, wait_for_ready_4       # If ready bit is 0, loop

    # Send the character to the display
    la t3, display_data             # Load the address of display_data into t3
    sb t1, 0(t3)                    # Store the byte from t1 to display_data address
    addi a0, a0, 1                  # Increment the address pointer a0 to the next character
    j print_string_loop             # Jump back to start of loop to print the next character

restore_and_exit:
    # Reinitialize t0 to the base of the special memory range before restoring registers
    li t0, 0x00                      # Reset t0 to point to 0x0, the start of the reserved memory range

    # Restore registers from the special memory range
    lw ra, 0(t0)                    # Restore return address from address 0x0
    lw a0, 4(t0)                    # Restore a0 from address 0x4
    lw a1, 8(t0)                    # Restore a1 from address 0x8
    lw a2, 12(t0)                   # Restore a2 from address 0xc
    lw a3, 16(t0)                   # Restore a3 from address 0x10
    lw a4, 20(t0)                   # Restore a4 from address 0x14
    lw a5, 24(t0)                   # Restore a5 from address 0x18

    # Increment the mepc by 4 to point to the instruction after the ecall
    csrr t1, mepc                   # Read the current value of mepc into t1
    addi t1, t1, 4                  # Increment mepc by 4
    csrw mepc, t1                   # Write the updated value back to mepc

    mret                            # Return to user mode

