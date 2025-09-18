.section .text
.globl _start
_start:
    # x1 = LEDR, x2 = LEDG base addresses
    lui x1, 0x70000>>12     # 0x7000
    addi x1, x1, 0          # 0x7000
    addi x2, x1, 0x10       # 0x7010

    # Write patterns
    lui x3, 0xDEADB>>12
    addi x3, x3, 0xEEF
    sw  x3, 0(x1)           # RED LEDs
    lui x4, 0xCAFEB>>12
    addi x4, x4, 0xABE
    sw  x4, 0(x2)           # GREEN LEDs

    # Read switches at 0x7800
    lui x5, 0x78000>>12     # 0x7800
    lw  x6, 0(x5)

    # If switches non-zero, branch to loop
    beq x6, x0, 1f
    j   2f
1:
    j   3f
2:
    j   3f
3:
    j   3b                 # tight loop here
