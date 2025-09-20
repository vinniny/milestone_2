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

    // PC logic split into core/adder/debug
    logic [31:0] pc_q, pc_plus4, pc_next;
    pc_core  u_pc   (.i_clk(i_clk), .i_rst_n(i_rst_n), .i_pc_next(pc_next), .o_pc(pc_q));
    pc_adder u_pca  (.i_pc(pc_q), .o_pc_plus4(pc_plus4));
    // Inline pc_debug: expose PC directly
    assign o_pc_debug = pc_q;

    // Instruction memory
    logic [31:0] imem_rdata;
    imem u_imem (
        .addr (pc_q),
        .rdata(imem_rdata)
    );

    // LSU wires
    logic        lsu_we, lsu_re;
    logic [31:0] lsu_addr, lsu_wdata, lsu_rdata;

    // PC register
    // pc_core instance declared above

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
    logic rs1_zero_sel;
    control u_ctrl(
        .instr(imem_rdata),
        .alu_op(alu_op),
        .reg_we(rd_wren), .mem_we(mem_wren), .mem_re(mem_rden),
        .imm_sel(imm_sel),
        .pc_src_branch(pc_src_branch), .pc_src_jal(pc_src_jal), .pc_src_jalr(pc_src_jalr),
        .opa_sel(opa_sel), .opb_sel(opb_sel), .br_un(br_un), .wb_sel(wb_sel),
        .o_insn_vld(o_insn_vld), .alu_src_b_is_imm(unused_alu_src_imm), .rs1_zero_sel(rs1_zero_sel)
    );

    // Local JAL detect for fail-safe next_pc selection during bring-up
    logic jal_detect;
    assign jal_detect = (imem_rdata[6:0] == 7'b1101111);

    // Register file
    logic [31:0] rf_r1, rf_r2;
    logic [31:0] rf_wd;
    logic [4:0] rs1_addr_raw;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    assign rs1_addr_raw = imem_rdata[19:15];
    assign rs2_addr     = imem_rdata[24:20];
    assign rd_addr      = imem_rdata[11:7];
    assign rs1_addr     = rs1_zero_sel ? 5'd0 : rs1_addr_raw;
    regfile u_regfile (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_rs1_addr(rs1_addr), .i_rs2_addr(rs2_addr),
        .i_rd_addr(rd_addr), .i_rd_wren(rd_wren), .i_rd_data(rf_wd),
        .o_rs1_data(rf_r1), .o_rs2_data(rf_r2)
    );

    // Immediate generator
    logic [31:0] imm;
    immgen u_immgen (
        .instr(imem_rdata), .imm_sel(imm_sel), .imm(imm)
    );

    // Compute next PC via control selections only (no '+')
    logic [31:0] br_target, jal_target, jalr_target;
    logic [31:0] sum_pc_imm, sum_r1_imm;
    logic        _cout0, _ovf0, _cout1, _ovf1;
    add32 u_add_pc_imm(
        .a(pc_q), .b(imm), .cin(1'b0), .sum(sum_pc_imm), .cout(_cout0), .ovf(_ovf0)
    );
    add32 u_add_r1_imm(
        .a(rf_r1), .b(imm), .cin(1'b0), .sum(sum_r1_imm), .cout(_cout1), .ovf(_ovf1)
    );
    assign br_target   = sum_pc_imm;
    assign jal_target  = sum_pc_imm;
    assign jalr_target = sum_r1_imm & 32'hFFFF_FFFE;
    always_comb begin
        pc_next = pc_plus4;
        if (take_branch)               pc_next = br_target;
        if (pc_src_jal  || jal_detect) pc_next = jal_target; // fail-safe JAL
        if (pc_src_jalr)               pc_next = jalr_target;
    end

    // Expose instruction fetch trace
    always_ff @(posedge i_clk) begin
        if (!rst) begin
            $display("IF PC=%08x INSTR=%08x", pc_q, imem_rdata);
        end
    end

    // Optional extra JAL trace tied to clock
    always @(posedge i_clk) begin
        if (imem_rdata[6:0] == 7'b1101111) begin
            $display("TRACE JAL @PC=%08x pc_src_jal=%0d", o_pc_debug, pc_src_jal);
        end
    end

    // Branch comparator (stub data path for now)
    logic br_equal, br_less;
    brc u_brc (
        .i_rs1_data(rf_r1), .i_rs2_data(rf_r2), .i_br_un(br_un), .o_br_equal(br_equal), .o_br_less(br_less)
    );

    // Take branch when control requests branch and condition matches funct3
    // Keep existing funct3-based cases but gate by pc_src_branch
    logic take_branch;
    always_comb begin
        take_branch = 1'b0;
        if (pc_src_branch) begin
            unique case (imem_rdata[14:12])
                3'b000: take_branch = br_equal;       // BEQ
                3'b001: take_branch = ~br_equal;      // BNE
                3'b100: take_branch = br_less;        // BLT
                3'b101: take_branch = ~br_less;       // BGE
                3'b110: take_branch = br_less;        // BLTU (using br_un in BRC)
                3'b111: take_branch = ~br_less;       // BGEU
                default: take_branch = 1'b0;
            endcase
        end
    end

    // ALU + operand muxes (placeholder wiring)
    logic [31:0] alu_a, alu_b, alu_y;
    logic alu_zero;
    assign alu_a = opa_sel ? pc_q : rf_r1;
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

    // Writeback mux: select regfile write data
    assign rf_wd = (wb_sel==2'b01) ? lsu_rdata :
                   (wb_sel==2'b10) ? pc_plus4  :
                                     alu_y;

    // Trace: opcode vs control select sanity prints
    // Local opcode decodes only for tracing (not used for functionality)
    logic is_jal_op, is_jalr_op, is_branch_op;
    assign is_jal_op    = (imem_rdata[6:0] == 7'b1101111);
    assign is_jalr_op   = (imem_rdata[6:0] == 7'b1100111);
    assign is_branch_op = (imem_rdata[6:0] == 7'b1100011);

    always_ff @(posedge i_clk) if (i_rst_n) begin
        if (is_jal_op)    $display("TRACE JAL   @PC=%08x ctrl_pc_src_jal=%0d",   o_pc_debug, pc_src_jal);
        if (is_jalr_op)   $display("TRACE JALR  @PC=%08x ctrl_pc_src_jalr=%0d",  o_pc_debug, pc_src_jalr);
        if (is_branch_op) $display("TRACE BR    @PC=%08x ctrl_pc_src_branch=%0d", o_pc_debug, pc_src_branch);
        if (is_jal_op && !pc_src_jal)
            $display("SANITY MISMATCH: JAL opcode seen but pc_src_jal=0 @PC=%08x", o_pc_debug);
        if (is_jalr_op && !pc_src_jalr)
            $display("SANITY MISMATCH: JALR opcode seen but pc_src_jalr=0 @PC=%08x", o_pc_debug);
        if (is_branch_op && !pc_src_branch)
            $display("SANITY MISMATCH: BRANCH opcode seen but pc_src_branch=0 @PC=%08x", o_pc_debug);
    end

endmodule
