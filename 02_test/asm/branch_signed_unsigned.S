.section .text
.globl _start
_start:
    # rs1 = 0xFFFFFFFF (-1 signed)
    li    x5, -1
    # rs2 = 0x00000001
    li    x6, 1

    # Test BLT (signed): -1 < 1 should branch
    blt   x5, x6, 1f
    # If we get here, signed compare failed
    j     fail
1:
    # Test BLTU (unsigned): 0xFFFFFFFF < 1 should NOT branch
    bltu  x5, x6, fail

pass:
    j     pass

fail:
    j     fail
