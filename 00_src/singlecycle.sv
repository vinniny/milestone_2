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
    // New control interface
    logic mem_rden, pc_src_branch, pc_src_jal, pc_src_jalr;
    logic [2:0] imm_sel;
    // Dummy sink for optional control output
    logic unused_alu_src_imm;
    control u_ctrl(
        .instr(imem_rdata),
        .alu_op(alu_op),
        .reg_we(rd_wren), .mem_we(mem_wren), .mem_re(mem_rden),
        .imm_sel(imm_sel),
        .pc_src_branch(pc_src_branch), .pc_src_jal(pc_src_jal), .pc_src_jalr(pc_src_jalr),
        .opa_sel(opa_sel), .opb_sel(opb_sel), .br_un(br_un), .wb_sel(wb_sel),
        .o_insn_vld(o_insn_vld), .alu_src_b_is_imm(unused_alu_src_imm)
    );

    // Compute next PC via control selections
    logic [31:0] br_target, jal_target, jalr_target;
    assign br_target  = pc_curr + imm;
    assign jal_target = pc_curr + imm;
    assign jalr_target= (rf_r1 + imm) & 32'hFFFF_FFFE;
    always_comb begin
        pc_next = pc_plus4;
        if (pc_src_branch) pc_next = br_target;
        if (pc_src_jal)    pc_next = jal_target;
        if (pc_src_jalr)   pc_next = jalr_target;
    end

    // Expose instruction fetch trace
    always_ff @(posedge i_clk) begin
        if (!rst) begin
            $display("IF PC=%08x INSTR=%08x", pc_curr, imem_rdata);
        end
    end

    // Stub instances to match requested structure
    // Register file
    logic [31:0] rf_r1, rf_r2;
    wire [4:0] rs1 = imem_rdata[19:15];
    wire [4:0] rs2 = imem_rdata[24:20];
    wire [4:0] rd  = imem_rdata[11:7];
    regfile u_regfile (
        .clk(i_clk),
        .we(rd_wren),
        .rs1(rs1),
        .rs2(rs2),
        .rd (rd),
        .wdata(wb_data),
        .rdata1(rf_r1),
        .rdata2(rf_r2)
    );

    // Immediate generator
    logic [31:0] imm;
    immgen u_immgen (
        .instr(imem_rdata), .imm_sel(imm_sel), .imm(imm)
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
    assign alu_b = (opb_sel==2'b00) ? rf_r2 : (opb_sel==2'b01 ? imm : 32'd4);
    alu u_alu (.a(alu_a), .b(alu_b), .op(alu_op), .y(alu_y), .zero(alu_zero));

    // Load/Store Unit (memory-mapped IO + RAM)
    assign lsu_we    = mem_wren;
    assign lsu_re    = mem_rden;
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

    // JAL trace (optional)
    always @(posedge i_clk) if (i_rst_n && imem_rdata[6:0]==7'b1101111)
        $display("JAL @PC=%08x imm=%08x pc_src_jal=%0d", o_pc_debug, imm, pc_src_jal);

endmodule
