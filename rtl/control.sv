`timescale 1ns/1ps
// Control unit decode for RV32I
module control (
    input  logic [31:0] instr,
    // Control signals (subset)
    output logic        reg_we,
    output logic        alu_src_b_imm,
    output logic [2:0]  alu_op,
    output logic        mem_we,
    output logic        mem_re,
    output logic        branch,
    output logic        jump
);
    // Stub
endmodule

