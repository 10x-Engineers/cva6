.text
.globl _start
_start:
    li t0, -1
    csrw pmpaddr0, t0  // set pmp region for S-mode
    li t0, 0x8F
    csrw pmpcfg0, t0
    la t0, trap_handler
    csrw mtvec, t0
    csrw stvec, t0
    li t0, 0x800    
    csrrw t1,mstatus,t0 // write mstatus perivous privl bits as S user 
    csrrs t1,mstatus,x0
    la t0, s_mode
    csrw mepc, t0
    addi t0, x0, 0
    lui t3, 0x6fe80
    addi t3, t3, -1

    //mret //testing in s mode // exception should occur 


csr_access:
    AUIPC t3, 0

    // sdtrigger csrs writing test, it will not generate exception 
    // if hart in m or in debug mode and trigger regs are implemented
    csrw tselect, t0
    csrw tdata1, t2
    csrw tdata2, t3
    csrw tdata3, t0

    // sdtrig read csr 
    csrrs t4, tdata1, x0
    csrrs t4, tdata2, x0
    csrrs t4, tdata3, x0
    csrrs t4, tselect, x0

    // exit the loop if tselect is not written as t0 as it is WARL
    beq t4, t0, increment_t0
    addi a1, a1, 100
    j exit

increment_t0:
    addi t0, t0, 1
    j csr_access

exit:
    j write_tohost

write_tohost:
    li x1, 1
    la t0, tohost
    sw x1, 0(t0)
    j write_tohost

.align 4
s_mode:
    j csr_access

.align 4
trap_handler:
    addi t2, x0, 222
    j exit


.data
.word 0;
.align 6;   .global tohost;   tohost:   .dword 0;
.align 6;   .global fromhost; fromhost: .dword 0;
