# TODO: setup exception handler
# TODO: setup mepc to point to the first instruction of the selfcloning function
# TODO: enable and setup interrupts as needed
# TODO: jump to user mode

#make initial process 
#0x00 is count for processes
# 0x04 is the current process
#0x08 to store t1 temporarily
#0x12 to store t2 temporarily
#0x16 - 1A - ... ( mepc 1 - mepc 2 - mepc 3 - ...) - 0x36
#40 - 42 - 44 - 46 - 48 - 4A - 4C - 4E (process active or not) 1 or 0
li t1, 1
sw t1, 0(zero)
sw t1, 4(zero)
sw t1, 0x40(zero)
li t1, 0

# Initial setup for timer interrupts and process start
li t0, 0x4000000
csrw mepc, t0  # Start of cloneprogram

# Setup the exception handler
la t0, exception_handler
csrw mtvec, t0

# Enable machine mode interrupts
csrr t0, mstatus
ori t0, t0, 0x8
csrw mstatus, t0

#enable timer interrupts

csrr t0, mie          # Read current value of mie into t0
li t1, 0x80           # Load the hexadecimal value 0x80 directly (for MTIE bit)
or t0, t0, t1         # Perform bitwise OR to set the MTIE bit in t0
csrw mie, t0          # Write the new value back to mie



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
exception_handler:
sw t1, 0x08(zero)
sw t2, 0x12(zero)


# Clear any pending interrupts by writing to mip
    li t1, 2048
    csrrc zero, mip, t1


 # Check the cause of the exception
    csrr t1, mcause                 # Read mcause into a0 to check the cause of the exception
    li t2, 8                        # Load the exception code for system calls
    bne t1, t2, handle_interrupt       # Branch if not a system call
handle_ecall:

    # TODO: check which system call is requested and jump to the corresponding handler
    # If it's a system call, read system call number from a7
    li t2, 220
    beq a7, t2, clone_process
    li t2, 172
    beq a7, t2, return_pid
    #if not 220 or 172
    # Increment the mepc by 4 to point to the instruction after the ecall
    csrr t1, mepc                   # Read the current value of mepc into t1
    addi t1, t1, 4                  # Increment mepc by 4
    csrw mepc, t1  
    lw t1, 0x08(zero)
    lw t2, 0x12(zero)                 # Write the updated value back to mepc
    mret


return_pid:
# Increment mepc by 4 to continue from the next instruction


    csrr t1, mepc
    addi t1, t1, 4
    csrw mepc, t1
    lw t1, 0x08(zero)
    lw a0, 0x04(zero)
    lw t2, 0x12(zero)
mret



handle_overflow:
 csrr t1, mepc
    addi t1, t1, 4
    csrw mepc, t1
  li a0, -1  # Return -1 on failure to clone more processes
  lw t1, 0x08(zero)
  lw t2, 0x12(zero)
  mret

clone_process:



# Check if new PID exceeds max processes (8 processes, so max PID is 8)
  li t1, 8
  lw t2, 0(zero)
  bge t2, t1, handle_overflow  # Handle overflow if trying to clone more than allowed
  addi t2, t2, 1  # Increment process count
  sw t2, 0(zero) #store new count



# Read global process count
    lw t2, 4(zero)  # current
    li t1, 1
    beq t2, t1, segment_2
    addi t1, t1, 1
    beq t2, t1, segment_3
    addi t1, t1, 1
    beq t2, t1, segment_4
    addi t1, t1, 1
    beq t2, t1, segment_5
    addi t1, t1, 1
    beq t2, t1, segment_6
    addi t1, t1, 1
    beq t2, t1, segment_7
    addi t1, t1, 1
    beq t2, t1, segment_8

    

# Segment 2
segment_2:
    lw t1, 0x08(zero)
    lw t2, 0x12(zero) # t2
    sw x7, 0x238(t2)  # Save t2
    li t2, 2
    sw t2, 0x144(zero) # Save a0 parent
    lw a0, 0x144(zero)
    csrr t2, mepc
    addi t2, t2, 4
    sw t2, 0x16(zero) # save mepc
    sw t2, 0x1A(zero)
    csrw mepc, t2
    li t2, 1
    sw t2, 0x42(zero)
    li t2, 0x200
    j store_registers

# Segment 3
segment_3:
   lw t1, 0x08(zero)
    lw t2, 0x12(zero)
    sw x7, 0x338(t2)  # Save t2
    li t2, 3
    sw t2, 0x244(zero) # Save a0 parent
    lw a0, 0x244(zero)
    csrr t2, mepc
    addi t2, t2, 4
    sw t2, 0x1A(zero) # save mepc
    sw t2, 0x1E(zero)
    csrw mepc, t2
    li t2, 1
    sw t2, 0x44(zero)
    li t2, 0x300
    j store_registers

# Segment 4
segment_4:
    lw t1, 0x08(zero)
    lw t2, 0x12(zero)
    sw x7, 0x438(t2)  # Save t2
    li t2, 4
    sw t2, 0x344(zero) # Save a0 parent
    lw a0, 0x344(zero)
    csrr t2, mepc
    addi t2, t2, 4
    sw t2, 0x1E(zero) # save mepc
    sw t2, 0x26(zero)
    csrw mepc, t2
    li t2, 1
    sw t2, 0x46(zero)
    li t2, 0x400
    j store_registers

# Segment 5
segment_5:
    lw t1, 0x08(zero)
    lw t2, 0x12(zero)
    sw x7, 0x538(t2)  # Save t2
    li t2, 5
    sw t2, 0x444(zero) # Save a0 parent
    lw a0, 0x444(zero)
    csrr t2, mepc
    addi t2, t2, 4
    sw t2, 0x26(zero) # save mepc
    sw t2, 0x2A(zero)
    csrw mepc, t2
    li t2, 1
    sw t2, 0x48(zero)
    li t2, 0x500
    j store_registers

# Segment 6
segment_6:
    lw t1, 0x08(zero)
    lw t2, 0x12(zero)
    sw x7, 0x638(t2)  # Save t2
    li t2, 6
    sw t2, 0x544(zero) # Save a0 parent
    lw a0, 0x544(zero)
    csrr t2, mepc
    addi t2, t2, 4
    sw t2, 0x2A(zero) # save mepc
    sw t2, 0x2E(zero)
    csrw mepc, t2
    li t2, 1
    sw t2, 0x4A(zero)
    li t2, 0x600
    j store_registers

# Segment 7
segment_7:
    lw t1, 0x08(zero)
    lw t2, 0x12(zero)
    sw x7, 0x738(t2)  # Save t2
    li t2, 7
    sw t2, 0x644(zero) # Save a0 parent
    lw a0, 0x644(zero)
    csrr t2, mepc
    addi t2, t2, 4
    sw t2, 0x2E(zero) # save mepc
    sw t2, 0x32(zero)
    csrw mepc, t2
    li t2, 1
    sw t2, 0x4C(zero)
    li t2, 0x700
    j store_registers

# Segment 8
segment_8:
    lw t1, 0x08(zero)
    lw t2, 0x12(zero)
    sw x7, 0x838(t2)  # Save t2
    li t2, 8
    sw t2, 0x744(zero) # Save a0 parent
    lw a0, 0x744(zero)
    csrr t2, mepc
    addi t2, t2, 4
    sw t2, 0x32(zero) # save mepc
    sw t2, 0x36(zero)
    csrw mepc, t2
    li t2, 1
    sw t2, 0x4E(zero)
    li t2, 0x800

# Store registers
store_registers:
     
sw x1, 0x20(t2)   # Save ra
sw x2, 0x24(t2)   # Save sp
sw x3, 0x28(t2)   # Save gp
sw x4, 0x2C(t2)  # Save tp
sw x5, 0x30(t2)  # Save t0
sw x6, 0x34(t2)  # Save t1
sw x8, 0x3C(t2)  # Save s0/fp
sw x9, 0x40(t2)  # Save s1
sw zero, 0x44(t2) # Save a0 #child
sw x11, 0x48(t2) # Save a1
sw x12, 0x4C(t2) # Save a2
sw x13, 0x50(t2) # Save a3
sw x14, 0x54(t2) # Save a4
sw x15, 0x58(t2) # Save a5
sw x16, 0x5C(t2) # Save a6
sw x17, 0x60(t2) # Save a7
sw x18, 0x64(t2) # Save s2
sw x19, 0x68(t2) # Save s3
sw x20, 0x6C(t2) # Save s4
sw x21, 0x70(t2) # Save s5
sw x22, 0x74(t2) # Save s6
sw x23, 0x78(t2) # Save s7
sw x24, 0x7C(t2) # Save s8
sw x25, 0x80(t2) # Save s9
sw x26, 0x84(t2) # Save s10
sw x27, 0x88(t2) # Save s11
sw x28, 0x8C(t2) # Save t3
sw x29, 0x90(t2) # Save t4
sw x30, 0x94(t2) # Save t5
sw x31, 0x98(t2) # Save t6




lw t1, 0x08(zero)
lw t2, 0x12(zero)
mret


    

    # TODO: save some registers
    # TODO: check the cause of the exception: ecall or timer interrupt




#time exception_handler
handle_interrupt:

lw t1, 0x00(zero)
li t2, 8   # checks if all processes are used up
beq t1, t2, skipcheck

lw t1, 0x04(zero) # laod current
addi t1, t1, 1 #current + 1
li t2, 2    
mul t2, t1, t2  # current times 2   ###checks if full bit is 1 or no
addi t2, t2, 0x3E
#andi t1, t1, 0xFFFF  # Apply mask to keep only the lower 16 bits
lw t1, 0(t2)

beqz t1, backtoone

skipcheck:
lw t1, 4(zero)    # Load the current segment/process ID
li t2, 1          # Set comparison start value

beq t1, t2, segment__one
addi t2, t2, 1
beq t1, t2, segment__two
addi t2, t2, 1
beq t1, t2, segment__three
addi t2, t2, 1
beq t1, t2, segment__four
addi t2, t2, 1
beq t1, t2, segment__five
addi t2, t2, 1
beq t1, t2, segment__six
addi t2, t2, 1
beq t1, t2, segment__seven
addi t2, t2, 1
beq t1, t2, segment__eight



backtoone:
lw t2, 4(zero)  # current
li t1, 1
    beq t2, t1, oneto1
addi t1, t1, 1
    beq t2, t1, twoto1
addi t1, t1, 1
    beq t2, t1, threeto1
addi t1, t1, 1
    beq t2, t1, fourto1
addi t1, t1, 1
    beq t2, t1, fiveto1
addi t1, t1, 1
    beq t2, t1, sixto1
addi t1, t1, 1
    beq t2, t1, sevento1
    addi t1, t1, 1
    beq t2, t1, eightto1


oneto1:

#Handle timer interrupt and prepare for process switching
la t1, mtime
lw t2, 0(t1)    # Load the lower 32 bits of mtime
addi t2, t2, 373
la t1, mtimecmp
sw t2, 0(t1)    # Update mtimecmp for the next interval
lw t1, 0x08(zero)
lw t2, 0x12(zero)
mret




     savesegment:

sw x1, 0x20(t2)   # Save ra
sw x2, 0x24(t2)   # Save sp
sw x3, 0x28(t2)   # Save gp
sw x4, 0x2C(t2)  # Save tp
sw x5, 0x30(t2)  # Save t0
sw x6, 0x34(t2)  # Save t1
sw x8, 0x3C(t2)  # Save s0/fp
sw x9, 0x40(t2)  # Save s1
sw x10, 0x44(t2) # Save a0 #child
sw x11, 0x48(t2) # Save a1
sw x12, 0x4C(t2) # Save a2
sw x13, 0x50(t2) # Save a3
sw x14, 0x54(t2) # Save a4
sw x15, 0x58(t2) # Save a5
sw x16, 0x5C(t2) # Save a6
sw x17, 0x60(t2) # Save a7
sw x18, 0x64(t2) # Save s2
sw x19, 0x68(t2) # Save s3
sw x20, 0x6C(t2) # Save s4
sw x21, 0x70(t2) # Save s5
sw x22, 0x74(t2) # Save s6
sw x23, 0x78(t2) # Save s7
sw x24, 0x7C(t2) # Save s8
sw x25, 0x80(t2) # Save s9
sw x26, 0x84(t2) # Save s10
sw x27, 0x88(t2) # Save s11
sw x28, 0x8C(t2) # Save t3
sw x29, 0x90(t2) # Save t4
sw x30, 0x94(t2) # Save t5
sw x31, 0x98(t2) # Save t6


csrr t0, mepc
sw t0, 0x1A(zero) # save old mepc

lw t0, 0x16(zero)
csrw mepc, t0   # write new mepc

li t1, 1
sw t1, 0x04(zero)

#Handle timer interrupt and prepare for process switching
la t1, mtime
lw t2, 0(t1)    # Load the lower 32 bits of mtime
addi t2, t2, 373
la t1, mtimecmp
sw t2, 0(t1)    # Update mtimecmp for the next interval

j tooneend

tooneend:
lw x1, 0x120(zero)   # Load ra
lw x2, 0x124(zero)   # Load sp
lw x3, 0x128(zero)   # Load gp
lw x4, 0x12C(zero)   # Load tp
lw x5, 0x130(zero)   # Load t0
lw x6, 0x134(zero)   # Load t1
lw x7, 0x138(zero)   # Load t2
lw x8, 0x13C(zero)   # Load s0/fp
lw x9, 0x140(zero)   # Load s1
lw x10, 0x144(zero)  # Load a0
lw x11, 0x148(zero)  # Load a1
lw x12, 0x14C(zero)  # Load a2
lw x13, 0x150(zero)  # Load a3
lw x14, 0x154(zero)  # Load a4
lw x15, 0x158(zero)  # Load a5
lw x16, 0x15C(zero)  # Load a6
lw x17, 0x160(zero)  # Load a7
lw x18, 0x164(zero)  # Load s2
lw x19, 0x168(zero)  # Load s3
lw x20, 0x16C(zero)  # Load s4
lw x21, 0x170(zero)  # Load s5
lw x22, 0x174(zero)  # Load s6
lw x23, 0x178(zero)  # Load s7
lw x24, 0x17C(zero)  # Load s8
lw x25, 0x180(zero)  # Load s9
lw x26, 0x184(zero)  # Load s10
lw x27, 0x188(zero)  # Load s11
lw x28, 0x18C(zero)  # Load t3
lw x29, 0x190(zero)  # Load t4
lw x30, 0x194(zero)  # Load t5
lw x31, 0x198(zero)  # Load t6

mret

twoto1:
    lw t2, 0x12(zero) # t2
    sw x7, 0x238(t2)  # Save t2
    li t2, 0x200
    lw t1, 0x08(zero)
    j savesegment


threeto1:
lw t2, 0x12(zero) # t2
    sw x7, 0x338(t2)  # Save t2
    li t2, 0x300
    lw t1, 0x08(zero)
    j savesegment

 fourto1:
lw t2, 0x12(zero) # t2
    sw x7, 0x438(t2)  # Save t2
    li t2, 0x400
    lw t1, 0x08(zero)
    j savesegment

 fiveto1:
lw t2, 0x12(zero) # t2
    sw x7, 0x538(t2)  # Save t2
    li t2, 0x500
    lw t1, 0x08(zero)
    j savesegment

 sixto1:
lw t2, 0x12(zero) # t2
    sw x7, 0x638(t2)  # Save t2
    li t2, 0x600
    lw t1, 0x08(zero)
    j savesegment

j tooneend

 sevento1:
lw t2, 0x12(zero) # t2
    sw x7, 0x738(t2)  # Save t2
    li t2, 0x700
    lw t1, 0x08(zero)
    j savesegment

 eightto1:
lw t2, 0x12(zero) # t2
    sw x7, 0x838(t2)  # Save t2
    li t2, 0x800
    lw t1, 0x08(zero)
    j savesegment


savesegmentnormal:

sw x1, 0x20(t2)   # Save ra
sw x2, 0x24(t2)   # Save sp
sw x3, 0x28(t2)   # Save gp
sw x4, 0x2C(t2)  # Save tp
sw x5, 0x30(t2)  # Save t0
sw x6, 0x34(t2)  # Save t1
sw x8, 0x3C(t2)  # Save s0/fp
sw x9, 0x40(t2)  # Save s1
sw x10, 0x44(t2) # Save a0 #child
sw x11, 0x48(t2) # Save a1
sw x12, 0x4C(t2) # Save a2
sw x13, 0x50(t2) # Save a3
sw x14, 0x54(t2) # Save a4
sw x15, 0x58(t2) # Save a5
sw x16, 0x5C(t2) # Save a6
sw x17, 0x60(t2) # Save a7
sw x18, 0x64(t2) # Save s2
sw x19, 0x68(t2) # Save s3
sw x20, 0x6C(t2) # Save s4
sw x21, 0x70(t2) # Save s5
sw x22, 0x74(t2) # Save s6
sw x23, 0x78(t2) # Save s7
sw x24, 0x7C(t2) # Save s8
sw x25, 0x80(t2) # Save s9
sw x26, 0x84(t2) # Save s10
sw x27, 0x88(t2) # Save s11
sw x28, 0x8C(t2) # Save t3
sw x29, 0x90(t2) # Save t4
sw x30, 0x94(t2) # Save t5
sw x31, 0x98(t2) # Save t6


csrr t0, mepc
sw t0, 0x1A(zero) # save old mepc

lw t0, 0x16(zero)
csrw mepc, t0   # write new mepc


lw t1, 0x04(zero)
addi t1, t1, 1
addi t1, t1, -9
beqz  t1, currenttoone
addi t1, t1, 9

sw t1, 0x04(zero)
j skip
currenttoone:
li t1, 1
sw t1, 0x04(zero)

skip:
#Handle timer interrupt and prepare for process switching
la t1, mtime
lw t3, 0(t1)    # Load the lower 32 bits of mtime
addi t3, t3, 373
la t1, mtimecmp
sw t3, 0(t1)    # Update mtimecmp for the next interval
addi t2, t2, 0x100
li t3, 0x900
beq t2, t3,  tooneend
j normalload


segment__one:
 lw t2, 0x12(zero) # t2
    sw x7, 0x138(t2)  # Save t2
    li t2, 0x100
    lw t1, 0x08(zero)
    j savesegmentnormal

segment__two:
 lw t2, 0x12(zero) # t2
    sw x7, 0x238(t2)  # Save t2
    li t2, 0x200
    lw t1, 0x08(zero)
    j savesegmentnormal

segment__three:
 lw t2, 0x12(zero) # t2
    sw x7, 0x338(t2)  # Save t2
    li t2, 0x300
    lw t1, 0x08(zero)
    j savesegmentnormal
segment__four:
 lw t2, 0x12(zero) # t2
    sw x7, 0x438(t2)  # Save t2
    li t2, 0x400
    lw t1, 0x08(zero)
    j savesegmentnormal
segment__five:
 lw t2, 0x12(zero) # t2
    sw x7, 0x538(t2)  # Save t2
    li t2, 0x500
    lw t1, 0x08(zero)
    j savesegmentnormal
segment__six:
 lw t2, 0x12(zero) # t2
    sw x7, 0x638(t2)  # Save t2
    li t2, 0x600
    lw t1, 0x08(zero)
    j savesegmentnormal
segment__seven:
 lw t2, 0x12(zero) # t2
    sw x7, 0x738(t2)  # Save t2
    li t2, 0x700
    lw t1, 0x08(zero)
    j savesegmentnormal
segment__eight:
 lw t2, 0x12(zero) # t2
    sw x7, 0x838(t2)  # Save t2
    li t2, 0x800
    lw t1, 0x08(zero)
    j savesegmentnormal



  normalload:

lw x1, 0x20(t2)   # Load ra
lw x2, 0x24(t2)   # Load sp
lw x3, 0x28(t2)   # Load gp
lw x4, 0x2C(t2)   # Load tp
lw x5, 0x30(t2)   # Load t0
lw x6, 0x34(t2)   # Load t1

lw x8, 0x3C(t2)   # Load s0/fp
lw x9, 0x40(t2)   # Load s1
lw x10, 0x44(t2) # Load a0 #child
lw x11, 0x48(t2)  # Load a1
lw x12, 0x4C(t2)  # Load a2
lw x13, 0x50(t2)  # Load a3
lw x14, 0x54(t2)  # Load a4
lw x15, 0x58(t2)  # Load a5
lw x16, 0x5C(t2)  # Load a6
lw x17, 0x60(t2)  # Load a7
lw x18, 0x64(t2)  # Load s2
lw x19, 0x68(t2)  # Load s3
lw x20, 0x6C(t2)  # Load s4
lw x21, 0x70(t2)  # Load s5
lw x22, 0x74(t2)  # Load s6
lw x23, 0x78(t2)  # Load s7
lw x24, 0x7C(t2)  # Load s8
lw x25, 0x80(t2)  # Load s9
lw x26, 0x84(t2)  # Load s10
lw x27, 0x88(t2)  # Load s11
lw x28, 0x8C(t2)  # Load t3
lw x29, 0x90(t2)  # Load t4
lw x30, 0x94(t2)  # Load t5
lw x31, 0x98(t2)  # Load t6
lw x7, 0x38(t2)
mret

   