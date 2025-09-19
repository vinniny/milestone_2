`timescale 1ns/1ps
module immgen(
  input  logic [31:0] instr,
  input  logic [2:0]  imm_sel,  // 0=I,1=S,2=B,3=U,4=J
  output logic [31:0] imm
);
  // Precompute each immediate form
  logic [31:0] imm_i; // I-type: [31:20]
  logic [31:0] imm_s; // S-type: [31:25|11:7]
  logic [31:0] imm_b; // B-type: [31|7|30:25|11:8] << 1
  logic [31:0] imm_u; // U-type: [31:12] << 12
  logic [31:0] imm_j; // J-type: [31|19:12|20|30:21] << 1

  assign imm_i = {{20{instr[31]}}, instr[31:20]};
  assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
  assign imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  assign imm_u = {instr[31:12], 12'b0};
  assign imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

  always_comb begin
    // Safe default to avoid X propagation
    imm = 32'b0;
    unique case (imm_sel)
      3'd0: imm = imm_i;
      3'd1: imm = imm_s;
      3'd2: imm = imm_b;
      3'd3: imm = imm_u;
      3'd4: imm = imm_j;
      default: imm = 32'd0;
    endcase
  end
endmodule
