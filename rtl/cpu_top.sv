`timescale 1ns/1ps
// Top-level single-cycle RV32I CPU (stub)
module cpu_top (
    input  logic        clk,
    input  logic        rst,
    // Instruction memory
    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,
    // Data memory
    output logic        dmem_we,
    output logic        dmem_re,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    input  logic [31:0] dmem_rdata
);
    // Stub
endmodule

