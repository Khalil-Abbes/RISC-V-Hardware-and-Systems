# Main polling loop
polling_loop:
    # Load the address of the keyboard ready register into a register
    la t2, keyboard_ready
    # Wait for keyboard input to be ready
wait_for_keyboard_input:
    lbu t0, 0(t2)                  # Load the status from keyboard ready register
    andi t0, t0, 0x01              # Isolate the least significant bit (ready bit)
    beqz t0, wait_for_keyboard_input  # If not ready, keep polling

    # Load the address of the keyboard data register into a register
    la t3, keyboard_data
    # Read the keyboard input
    lbu t1, 0(t3)                  # Load the key pressed from keyboard data register

    # Load the address of the display ready register into a register
    la t4, display_ready
    # Wait for the display to be ready
wait_for_display_ready:
    lbu t0, 0(t4)                  # Load the status from display ready register
    andi t0, t0, 0x01              # Isolate the least significant bit (ready bit)
    beqz t0, wait_for_display_ready  # If not ready, keep polling

    # Load the address of the display data register into a register
    la t5, display_data
    # Print the keyboard input to the display
    sb t1, 0(t5)                   # Store the character into display data register

    # Jump back to start of the polling loop to handle the next character
    j polling_loop                    # Loop indefinitely











# TODO: wait for keyboard input
# TODO: read keyboard input
# TODO: wait for display ready
# TODO: print keyboard input to display
# TODO: start again
