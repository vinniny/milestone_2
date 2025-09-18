`timescale 1ns/1ps

// Top-level single-cycle RV32I CPU with exact I/O ports
module singlecycle (
    input  logic        i_clk,
    input  logic        i_rst_n,
    output logic [31:0] o_pc_debug,
    output logic        o_insn_vld,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic [31:0] o_io_lcd,
    input  logic [31:0] i_io_sw,
    input  logic [3:0]  i_io_btn
);
    // Minimal functionality identical to previous cpu_top: PC increments by 4
    // and fetches from instruction memory. Data memory/IO are idle.

    // Active-low reset converted to active-high
    logic rst;
    assign rst = ~i_rst_n;

    // PC logic
    logic [31:0] pc_curr, pc_next;
    assign pc_next = pc_curr + 32'd4;
    assign o_pc_debug = pc_curr;

    // Instruction memory
    logic [31:0] imem_rdata;
    imem u_imem (
        .addr(pc_curr),
        .rdata(imem_rdata)
    );

    // LSU wires
    logic        lsu_we, lsu_re;
    logic [31:0] lsu_addr, lsu_wdata, lsu_rdata;

    // PC register
    pc u_pc (
        .clk(i_clk), .rst(rst), .pc_next(pc_next), .pc_curr(pc_curr)
    );

    // Expose instruction fetch valid each cycle after reset deasserted
    always_ff @(posedge i_clk) begin
        if (!rst) begin
            o_insn_vld <= 1'b1;
            $display("IF PC=%08x INSTR=%08x", pc_curr, imem_rdata);
        end else begin
            o_insn_vld <= 1'b0;
        end
    end

    // Stub instances to match requested structure
    // Register file (unused here)
    logic [31:0] rf_r1, rf_r2;
    regfile u_regfile (
        .clk(i_clk), .we(1'b0), .rs1(5'd0), .rs2(5'd0), .rd(5'd0), .wdata(32'd0),
        .rdata1(rf_r1), .rdata2(rf_r2)
    );

    // Immediate generator (unused)
    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    immgen u_immgen (
        .instr(imem_rdata), .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b), .imm_u(imm_u), .imm_j(imm_j)
    );

    // Branch comparator (stub wiring)
    logic br_equal, br_less;
    logic br_un;
    assign br_un = 1'b0;
    brc u_brc (
        .a(32'd0), .b(32'd0), .i_br_un(br_un), .o_br_equal(br_equal), .o_br_less(br_less)
    );

    // ALU (unused)
    logic [31:0] alu_y;
    alu u_alu (
        .a(32'd0), .b(32'd0), .op(3'd0), .y(alu_y)
    );

    // Load/Store Unit (memory-mapped IO + RAM). Currently idle (no real core decode),
    // but instantiated and wired to IOs.
    assign lsu_we    = 1'b0;
    assign lsu_re    = 1'b0;
    assign lsu_addr  = 32'd0;
    assign lsu_wdata = 32'd0;

    lsu u_lsu (
        .clk(i_clk), .rst(rst),
        .i_we(lsu_we), .i_re(lsu_re), .i_addr(lsu_addr), .i_wdata(lsu_wdata), .o_rdata(lsu_rdata),
        .o_io_ledr(o_io_ledr), .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0), .o_io_hex1(o_io_hex1), .o_io_hex2(o_io_hex2), .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4), .o_io_hex5(o_io_hex5), .o_io_hex6(o_io_hex6), .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd),
        .i_io_sw(i_io_sw), .i_io_btn(i_io_btn)
    );

    // Simple ControlUnit stub (not implemented; signals unused)
    // If a ControlUnit module exists later, instantiate and wire here.

    // IO now driven by LSU instance

    // Unused inputs
    logic unused;
    assign unused = ^{i_io_sw, i_io_btn};

endmodule
