.section .text
.globl _start
_start:
    la t0, trap_handler
    csrw mtvec, t0

    li t1, 0x8  # for software interrupt
    csrs mie, t1
    csrs mstatus, t1

    li x2, 1
    csrw tselect, x2

    li x3, 0x00000008  // trigger match on software interrupt code
    csrw tdata2, x3

    li x4, 0x40000201
    csrw tdata1, x4   // trigger setup

    csrr x5, tdata1

    // we are forcing a software interrupt here to see if trigger matches on it
    li t2, 0x02000000   # msip (clint) base address
    li t3, 1
    sw t3, 0(t2)       # Set msip = 1 → triggers IRQ 3
    fence

    wfi
    
    nop
    nop
    nop
    nop

exit:
    li a1, 1
    la t2, tohost
    sw a1, 0(t2)
    j exit

trap_handler:
    csrr a0, mcause
    csrr a1, mepc
    li t0, 0x02000000     # clear MSIP (for software interrupt)
    sw zero, 0(t0)
    fence
    mret

.data
.align 4
.global tohost
tohost: .word 0
.global fromhost
fromhost: .word 0
