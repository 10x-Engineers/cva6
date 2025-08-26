.text
.globl _start
_start:
     li x2, 0
     csrw tselect, x2

     // Uncomment one of the instructions below. The core will enter debug mode after counting that many number of instructions.
     //li x2, 0x30003e01    # count 15
     //li x2, 0x30000e01    # count 3

     nop
     nop
     nop
     csrw tdata1, x2  // counting starts after this

     // Dummy instructions
     csrr x7, tdata1
     csrr x7, tdata1
     csrr x7, tdata1
     csrr x7, tdata1

     li x3, 1
     nop
     nop

     li x4, 2

     li x5, 3


     li x2, 0

     nop
     li x2, 1

     nop
     li x2, 2

     nop
     li x2, 3
     li x2, 3
     nop
     nop

exit:
    li a1, 1
    la t2, tohost
    sw a1, 0(t2)
    j exit

.data
.align 4
.global tohost
tohost: .word 0
.global fromhost
fromhost: .word 0
