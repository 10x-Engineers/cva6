.text
.globl _start
_start:
      la t0 ,trap_handler
      csrrw t1,mtvec ,t0
      addi t0,x0,1
      csrrw x3,tselect,t0
      li t0 ,3072
      csrrw x3,tdata1,t0
      csrrw x3,tdata1,t0






trap_handler:
    addi t2, x0, 222
    j write_tohost



write_tohost:
    li x1, 1
    la t0, tohost
    sw x1, 0(t0)
    j write_tohost
    
    
    
    
.data
.word 0;
.align 6;   .global tohost;   tohost:   .dword 0;
.align 6;   .global fromhost; fromhost: .dword 0;
