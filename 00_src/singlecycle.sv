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
    logic [31:0] pc_curr, pc_next, pc_plus4;
    assign pc_plus4 = pc_curr + 32'd4;
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

    // Control unit
    logic [1:0] pc_sel;
    logic rd_wren, opa_sel;
    logic [1:0] opb_sel, wb_sel;
    logic [3:0] alu_op;
    logic mem_wren;
    logic br_un;
    control u_ctrl(
        .i_rst(rst), .i_instr(imem_rdata),
        .pc_sel(pc_sel), .rd_wren(rd_wren), .br_un(br_un), .opa_sel(opa_sel), .opb_sel(opb_sel),
        .alu_op(alu_op), .mem_wren(mem_wren), .wb_sel(wb_sel), .o_insn_vld(o_insn_vld)
    );

    // For now, compute only pc_next mux options we have
    logic [31:0] br_target, jal_target, jalr_target;
    assign br_target  = pc_curr;   // placeholder until immgen used
    assign jal_target = pc_curr;   // placeholder
    assign jalr_target= pc_curr;   // placeholder
    always_comb begin
        unique case (pc_sel)
            2'b00: pc_next = pc_plus4;
            2'b01: pc_next = br_target;
            2'b10: pc_next = jal_target;
            2'b11: pc_next = jalr_target;
            default: pc_next = pc_plus4;
        endcase
    end

    // Expose instruction fetch trace
    always_ff @(posedge i_clk) begin
        if (!rst) begin
            $display("IF PC=%08x INSTR=%08x", pc_curr, imem_rdata);
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

    // Branch comparator (stub data path for now)
    logic br_equal, br_less;
    brc u_brc (
        .i_rs1_data(rf_r1), .i_rs2_data(rf_r2), .i_br_un(br_un), .o_br_equal(br_equal), .o_br_less(br_less)
    );

    // ALU + operand muxes (placeholder wiring)
    logic [31:0] alu_a, alu_b, alu_y;
    logic alu_zero;
    assign alu_a = opa_sel ? pc_curr : rf_r1;
    assign alu_b = (opb_sel==2'b00) ? rf_r2 : (opb_sel==2'b01 ? imm_i : 32'd4);
    alu u_alu (.a(alu_a), .b(alu_b), .op(alu_op), .y(alu_y), .zero(alu_zero));

    // Load/Store Unit (memory-mapped IO + RAM). Tie address/data to ALU results for now.
    assign lsu_we    = mem_wren;
    assign lsu_re    = 1'b0; // enable when LOAD decoding connects
    assign lsu_addr  = alu_y;
    assign lsu_wdata = rf_r2;

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

    // Writeback mux (placeholder; no regfile write currently connected)
    logic [31:0] wb_data;
    always_comb begin
        unique case (wb_sel)
            2'b00: wb_data = alu_y;     // ALU
            2'b01: wb_data = lsu_rdata; // LOAD
            2'b10: wb_data = pc_plus4;  // JAL/JALR link
            2'b11: wb_data = alu_y;     // AUIPC/LUI path simplified
            default: wb_data = alu_y;
        endcase
    end

endmodule
