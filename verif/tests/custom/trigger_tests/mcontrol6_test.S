.text
.globl _start
_start:
    # # select 0 = address,  select 1 = data
    # action = 1 debug
    li x2, 0
    csrw tselect, x2

    li x5, 0x80003000 ## test address
    li x6, 0x12345678 ## test data

    li x3, 0x80000030  // tdata2 will hold whatever needs to be matched i.e. data or address
    csrw tdata2, x3

    ## Test 1): store with data
    # li x4, 0x60201042
    # csrw tdata1, x4
    # nop
    # nop
    # nop
    # nop
    # sw x6, 0(x5)

    ## Test 2): load with data
#     li x4, 0x60201041
#     csrw tdata1, x4
#     nop
#     nop
#     nop
#     nop
#     nop
#     lw x7, 0(x5)

    ## Test 3): store with address
    # li x4, 0x60001042
    # csrw tdata1, x4
    # sw x6, 4(x5)
    # nop
    # nop
    # nop
    
    ## Test 4): load with address
    # li x4, 0x60001041
    # csrw tdata1, x4
    # lw x7, 4(x5)
    #  nop
    #  nop
    #  nop

    ## Test 5): execute with insruction
    # li x4, 0x60201044
    # csrw tdata1, x4
    # add x8, x2, x3
    # nop
    # nop

    ## Test 6): execute with address
    li x4, 0x60001044
    csrw tdata1, x4
    csrr x7, tdata1
    nop
    nop        // this instructions address is supposed to be the trigger point
    nop
    nop
    nop
    nop

exit:
    li x1, 1
    la t0, tohost
    sw x1, 0(t0)
    j exit

.data
.align 4
.global tohost
tohost: .word 0
.global fromhost
fromhost: .word 0