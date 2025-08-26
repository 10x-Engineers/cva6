.text
.globl _start
_start:
    la t0, trap_handler
    csrw mtvec, t0

    li t1, 0x8
    csrs mstatus, t1

    li x2, 0
    csrw tselect, x2

    // Any valid riscv exception code can be loaded here
    li x3, 0x00000008  // breakpoint exception
    csrw tdata2, x3

    li x4, 0x50000201
    csrw tdata1, x4  // core starts checking for trigger after this

    csrr x5, tdata2
    csrr x6, tdata1
    nop
    ebreak  // trigger match here

    nop
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
    csrr t3, mcause
    csrr t4, mepc
    addi t4, t4, 4
    csrw mepc, t4
    mret

.data
.align 4
.global tohost
tohost: .word 0
.global fromhost
fromhost: .word 0
