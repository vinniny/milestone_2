.section .text
.globl _start
_start:
    # x1 = 0x55AA55AA, x2 = 0x0F0F0F0F
    lui   x1, 0x55AA5
    addi  x1, x1, 0x5AA
    lui   x2, 0x00F0F
    addi  x2, x2, 0xF0F

    # x3 = 0x00007000 (LED base region per milestone_2 map)
    lui   x3, 0x00070

    # RED LEDs @ 0x7000
    sw    x1, 0(x3)

    # GREEN LEDs @ 0x7010
    addi  x3, x3, 0x10
    sw    x2, 0(x3)

1:  jal   x0, 1b     # tight loop

