.section .text
.globl _start
_start:
    addi x1, x0, 0       # x1 = 0
    addi x2, x0, 5       # loop count 5
1:
    addi x1, x1, 1       # x1++
    addi x2, x2, -1      # x2--
    bne  x2, x0, 1b      # loop until x2==0
    beq  x0, x0, 2f      # fallthrough jump
2:
    nop
