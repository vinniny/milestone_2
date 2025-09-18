`timescale 1ns/1ps
// RV32I Control Unit (minimal decode)
module control (
    input  logic        i_rst,
    input  logic [31:0] i_instr,
    output logic [1:0]  pc_sel,     // 00:+4, 01:branch, 10:jal, 11:jalr
    output logic        rd_wren,
    output logic        br_un,
    output logic        opa_sel,    // 0:rs1, 1:PC
    output logic [1:0]  opb_sel,    // 00:rs2, 01:imm, 10:4 (for AUIPC/JAL)
    output logic [3:0]  alu_op,     // matches ALU op enc in alu.sv
    output logic        mem_wren,
    output logic [1:0]  wb_sel,     // 00:ALU, 01:LOAD, 10:PC+4, 11:AUIPC
    output logic        o_insn_vld
);
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    assign opcode = i_instr[6:0];
    assign funct3 = i_instr[14:12];
    assign funct7 = i_instr[31:25];

    // Defaults
    always_comb begin
        pc_sel    = 2'b00;
        rd_wren   = 1'b0;
        br_un     = 1'b0;
        opa_sel   = 1'b0;
        opb_sel   = 2'b00;
        alu_op    = 4'b0000; // ADD
        mem_wren  = 1'b0;
        wb_sel    = 2'b00;   // ALU
        o_insn_vld= 1'b0;
        if (!i_rst) begin
            unique case (opcode)
                7'b0110011: begin // R-type
                    rd_wren = 1'b1;
                    opa_sel = 1'b0; // rs1
                    opb_sel = 2'b00; // rs2
                    // ALU op from funct7/funct3
                    unique case ({funct7,funct3})
                        10'b0000000_000: alu_op = 4'b0000; // ADD
                        10'b0100000_000: alu_op = 4'b0001; // SUB
                        10'b0000000_111: alu_op = 4'b0010; // AND
                        10'b0000000_110: alu_op = 4'b0011; // OR
                        10'b0000000_100: alu_op = 4'b0100; // XOR
                        10'b0000000_001: alu_op = 4'b0101; // SLL
                        10'b0000000_101: alu_op = 4'b0110; // SRL
                        10'b0100000_101: alu_op = 4'b0111; // SRA
                        10'b0000000_010: alu_op = 4'b1000; // SLT
                        10'b0000000_011: alu_op = 4'b1001; // SLTU
                        default: alu_op = 4'b0000;
                    endcase
                    o_insn_vld = 1'b1;
                end
                7'b0010011: begin // I-type (ALU imm)
                    rd_wren = 1'b1; opa_sel=1'b0; opb_sel=2'b01; // imm
                    unique case (funct3)
                        3'b000: alu_op = 4'b0000; // ADDI
                        3'b010: alu_op = 4'b1000; // SLTI
                        3'b011: alu_op = 4'b1001; // SLTIU
                        3'b100: alu_op = 4'b0100; // XORI
                        3'b110: alu_op = 4'b0011; // ORI
                        3'b111: alu_op = 4'b0010; // ANDI
                        3'b001: alu_op = 4'b0101; // SLLI
                        3'b101: alu_op = (funct7==7'b0100000) ? 4'b0111 : 4'b0110; // SRAI/SRLI
                        default: alu_op = 4'b0000;
                    endcase
                    o_insn_vld = 1'b1;
                end
                7'b0000011: begin // LOAD (LW)
                    rd_wren = 1'b1; mem_wren=1'b0; opa_sel=1'b0; opb_sel=2'b01; // rs1 + imm
                    alu_op  = 4'b0000; // ADD addr
                    wb_sel  = 2'b01;   // from LSU
                    o_insn_vld = 1'b1;
                end
                7'b0100011: begin // STORE (SW)
                    rd_wren = 1'b0; mem_wren=1'b1; opa_sel=1'b0; opb_sel=2'b01; // rs1 + imm
                    alu_op  = 4'b0000; // ADD addr
                    o_insn_vld = 1'b1;
                end
                7'b1100011: begin // BRANCH
                    rd_wren = 1'b0; pc_sel=2'b01; // branch target selection external
                    // br_un from funct3: BLTU/BGEU use unsigned
                    br_un = (funct3==3'b110 || funct3==3'b111);
                    o_insn_vld = 1'b1;
                end
                7'b1101111: begin // JAL
                    rd_wren = 1'b1; pc_sel=2'b10; wb_sel=2'b10; // write PC+4
                    opa_sel = 1'b1; opb_sel=2'b10; // use PC and +4 for AUIPC-like calc if needed
                    o_insn_vld = 1'b1;
                end
                7'b1100111: begin // JALR
                    rd_wren = 1'b1; pc_sel=2'b11; wb_sel=2'b10; // write PC+4
                    opb_sel = 2'b01; // use imm
                    o_insn_vld = 1'b1;
                end
                7'b0110111: begin // LUI
                    rd_wren = 1'b1; wb_sel=2'b11; // treat as AUIPC path for now (to be refined)
                    o_insn_vld = 1'b1;
                end
                7'b0010111: begin // AUIPC
                    rd_wren = 1'b1; opa_sel=1'b1; opb_sel=2'b01; // PC + imm
                    alu_op  = 4'b0000; wb_sel=2'b11; // write result (AUIPC path)
                    o_insn_vld = 1'b1;
                end
                default: begin
                    // unsupported -> invalid
                end
            endcase
        end
    end
endmodule
