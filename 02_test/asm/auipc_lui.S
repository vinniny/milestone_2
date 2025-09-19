.section .text
.globl _start
_start:
    auipc x5, 0x1       # x5 = PC + 0x1000 (check ALU opa=pc path)
    lui   x6, 0x12345   # x6 = 0x12345000
1:  jal   x0, 1b
