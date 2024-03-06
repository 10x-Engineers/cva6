.text
.globl _start
_start:
la a0, rvtest_data
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)

addi a0,a0,2047
addi a0,a0,2047
addi a0,a0,2
lw a1, 0(a0)



exit:
    j write_tohost

write_tohost:
   li   x1, 1
   la   t0, tohost
   sw   x1, 0(t0)
   j    write_tohost

.data

.align 4
rvtest_data:
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444
.word 0x55555555
.word 0x66666666
.word 0x77777777
.word 0x88888888
.word 0x99999999
.word 0xaaaaaaaa
.word 0xbbbbbbbb
.word 0xcccccccc
.word 0xdddddddd
.word 0xeeeeeeee
.word 0xffffffff
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444
.word 0x55555555
.word 0x66666666
.word 0x77777777
.word 0x88888888
.word 0x99999999
.word 0xaaaaaaaa
.word 0xbbbbbbbb
.word 0xcccccccc
.word 0xdddddddd
.word 0xeeeeeeee
.word 0xffffffff
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444
.word 0x55555555
.word 0x66666666
.word 0x77777777
.word 0x88888888
.word 0x99999999
.word 0xaaaaaaaa
.word 0xbbbbbbbb
.word 0xcccccccc
.word 0xdddddddd
.word 0xeeeeeeee
.word 0xffffffff
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444
.word 0x55555555
.word 0x66666666
.word 0x77777777
.word 0x88888888
.word 0x99999999
.word 0xaaaaaaaa
.word 0xbbbbbbbb
.word 0xcccccccc
.word 0xdddddddd
.word 0xeeeeeeee
.word 0xffffffff
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444
.word 0x55555555
.word 0x66666666
.word 0x77777777
.word 0x88888888
.word 0x99999999
.word 0xaaaaaaaa
.word 0xbbbbbbbb
.word 0xcccccccc
.word 0xdddddddd
.word 0xeeeeeeee
.word 0xffffffff
.word 0x11111111
.word 0x22222222
.word 0x33333333
.word 0x44444444
.word 0x55555555
.word 0x66666666
.word 0x77777777
.word 0x88888888
.word 0x99999999
.word 0xaaaaaaaa
.word 0xbbbbbbbb
.word 0xcccccccc
.word 0xdddddddd
.word 0xeeeeeeee
.word 0xffffffff




.align 4;   .global tohost;   tohost:   .dword 0;
.align 4;   .global fromhost; fromhost: .dword 0;
