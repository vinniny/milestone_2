module control(
  input  logic [31:0] instr,
  output logic [3:0]  alu_op,
  output logic        reg_we, mem_we, mem_re,
  output logic [2:0]  imm_sel,         // 0=I,1=S,2=B,3=U,4=J
  output logic        pc_src_branch, pc_src_jal, pc_src_jalr,
  output logic        opa_sel,         // 0=rs1, 1=pc
  output logic [1:0]  opb_sel,         // 00=rs2, 01=imm, 10=4
  output logic        br_un,
  output logic [1:0]  wb_sel,          // 00=ALU, 01=Load, 10=PC+4
  output logic        o_insn_vld,
  output logic        alu_src_b_is_imm, // compatibility (mirrors opb_sel==imm)
  output logic        rs1_zero_sel      // force rs1 read address to x0
);
  // locals for decode fields
  logic [6:0] op;
  logic [2:0] f3;
  logic [6:0] f7;

  always_comb begin : decode
    // defaults
    reg_we=0; mem_we=0; mem_re=0;
    imm_sel=3'd0; pc_src_branch=0; pc_src_jal=0; pc_src_jalr=0;
    opa_sel=0; opb_sel=2'b00; br_un=0; wb_sel=2'b00; alu_op=4'h0;
    o_insn_vld=1'b0;
    alu_src_b_is_imm = 1'b0;
    rs1_zero_sel = 1'b0;

    op = instr[6:0];
    f3 = instr[14:12];
    f7 = instr[31:25];

    if (op == 7'b1101111) begin
      // JAL
      reg_we      = 1'b1;      // rd <- PC+4
      wb_sel      = 2'b10;     // PC+4
      pc_src_jal  = 1'b1;      // next_pc = PC + J-imm
      imm_sel     = 3'd4;      // J-type
      opa_sel     = 1'b1;      // pc
      opb_sel     = 2'b01;     // imm
      alu_op      = 4'h0;      // ADD
      o_insn_vld  = 1'b1;

    end else if (op == 7'b1100111) begin
      // JALR
      reg_we=1; wb_sel=2'b10; pc_src_jalr=1; imm_sel=3'd0; opb_sel=2'b01; alu_op=4'h0; o_insn_vld=1; alu_src_b_is_imm=1;

    end else if (op == 7'b1100011) begin
      // BRANCH
      pc_src_branch=1; imm_sel=3'd2; br_un=f3[2]; o_insn_vld=1;

    end else if (op == 7'b0000011) begin
      // LOAD
      reg_we=1; mem_re=1; imm_sel=3'd0; opb_sel=2'b01; wb_sel=2'b01; alu_op=4'h0; o_insn_vld=1; alu_src_b_is_imm=1;

    end else if (op == 7'b0100011) begin
      // STORE
      mem_we=1; imm_sel=3'd1; opb_sel=2'b01; alu_op=4'h0; o_insn_vld=1; alu_src_b_is_imm=1;

    end else if (op == 7'b0010011) begin
      // I-ALU
      reg_we=1; imm_sel=3'd0; opb_sel=2'b01; o_insn_vld=1; alu_src_b_is_imm=1;
      unique case (f3)
        3'b000: alu_op=4'h0;              // ADDI
        3'b111: alu_op=4'h2;              // ANDI
        3'b110: alu_op=4'h3;              // ORI
        3'b100: alu_op=4'h4;              // XORI
        3'b001: alu_op=4'h5;              // SLLI
        3'b101: alu_op=(f7==7'b0100000)?4'h7:4'h6; // SRAI/SRLI
        3'b010: alu_op=4'h8;              // SLTI
        3'b011: alu_op=4'h9;              // SLTIU
        default: ;
      endcase

    end else if (op == 7'b0110011) begin
      // R-ALU
      reg_we=1; o_insn_vld=1;
      unique case ({f7,f3})
        {7'b0000000,3'b000}: alu_op=4'h0; // ADD
        {7'b0100000,3'b000}: alu_op=4'h1; // SUB
        {7'b0000000,3'b111}: alu_op=4'h2; // AND
        {7'b0000000,3'b110}: alu_op=4'h3; // OR
        {7'b0000000,3'b100}: alu_op=4'h4; // XOR
        {7'b0000000,3'b001}: alu_op=4'h5; // SLL
        {7'b0000000,3'b101}: alu_op=4'h6; // SRL
        {7'b0100000,3'b101}: alu_op=4'h7; // SRA
        {7'b0000000,3'b010}: alu_op=4'h8; // SLT
        {7'b0000000,3'b011}: alu_op=4'h9; // SLTU
        default: ;
      endcase

    end else if (op == 7'b0010111) begin
      // AUIPC
      reg_we=1; imm_sel=3'd3; opa_sel=1; opb_sel=2'b01; alu_op=4'h0; o_insn_vld=1; alu_src_b_is_imm=1;

    end else if (op == 7'b0110111) begin
      // LUI uses zero + U-imm
      reg_we=1; imm_sel=3'd3; opa_sel=0; opb_sel=2'b01; alu_op=4'h0; o_insn_vld=1; alu_src_b_is_imm=1; rs1_zero_sel=1;
    end
  end
endmodule
