.section .text
.globl _start
_start:
    # Directed branch coverage for signed vs unsigned comparisons
    li    x5, -1
    li    x6, 1
    li    x7, 0

    # Signed BLT should branch (-1 < 1)
    blt   x5, x6, 1f
    j     fail
1:
    addi  x7, x7, 1

    # Signed BGE should not branch (-1 >= 1 is false)
    bge   x5, x6, fail
    addi  x7, x7, 1

    # Unsigned BLTU should not branch (0xFFFFFFFF < 1 is false)
    bltu  x5, x6, fail
    addi  x7, x7, 1

    # Unsigned BGEU should branch (0xFFFFFFFF >= 1)
    bgeu  x5, x6, 2f
    j     fail
2:
    addi  x7, x7, 1

    # Flip operand signs to exercise the opposite polarity
    li    x5, 1
    li    x6, -1

    # Signed BLT should not branch (1 < -1 is false)
    blt   x5, x6, fail
    addi  x7, x7, 1

    # Signed BGE should branch (1 >= -1)
    bge   x5, x6, 3f
    j     fail
3:
    addi  x7, x7, 1

    # Unsigned BLTU should branch (1 < 0xFFFFFFFF)
    bltu  x5, x6, 4f
    j     fail
4:
    addi  x7, x7, 1

    # Unsigned BGEU should not branch (1 >= 0xFFFFFFFF is false)
    bgeu  x5, x6, fail
    addi  x7, x7, 1

    # All eight branch scenarios should have incremented x7
    addi  x8, x0, 8
    bne   x7, x8, fail

pass:
    # Write PASS pattern to LEDs (RED=1, GREEN=2)
    lui   x1, 0x7000>>12    # Adds PC (0x6C) via ALU path
    addi  x1, x1, -0x6C     # Back out PC contribution -> 0x00007000
    addi  x2, x1, 0x10      # 0x7010

    addi  x3, x0, 1
    sw    x3, 0(x1)         # RED LEDs = 1

    addi  x3, x0, 2
    sw    x3, 0(x2)         # GREEN LEDs = 2

    j     pass

fail:
    j     fail
