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
    // Minimal: PC increments by 4; expose IF via display
    logic [31:0] pc_curr, pc_next;

    // Next PC is +4 always
    assign pc_next  = pc_curr + 32'd4;
    assign imem_addr = pc_curr;

    // DMem default idle
    assign dmem_we   = 1'b0;
    assign dmem_re   = 1'b0;
    assign dmem_addr = 32'd0;
    assign dmem_wdata= 32'd0;

    // PC register using pc_core
    pc_core u_pc(.i_clk(clk), .i_rst_n(~rst), .i_pc_next(pc_next), .o_pc(pc_curr));

    // Trace
    always_ff @(posedge clk) begin
        if (!rst) begin
            $display("IF PC=%08x INSTR=%08x", pc_curr, imem_rdata);
        end
    end
endmodule
