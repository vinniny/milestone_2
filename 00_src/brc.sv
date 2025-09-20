`timescale 1ns/1ps

module brc(
  input  logic [31:0] i_rs1_data,
  input  logic [31:0] i_rs2_data,
  input  logic        i_br_un,     // 1 selects signed compare (BLT/BGE), 0 selects unsigned (BLTU/BGEU)
  output logic        o_br_less,
  output logic        o_br_equal
);
  // Equality: ~| (a ^ b)
  assign o_br_equal = ~(|(i_rs1_data ^ i_rs2_data));

  // Compute a - b using the shared adder trick (a + ~b + 1)
  logic [31:0] sum;
  logic        cout, ovf;
  add32 u_sub(.a(i_rs1_data), .b(~i_rs2_data), .cin(1'b1), .sum(sum), .cout(cout), .ovf(ovf));

  // Signed less: N xor V = sum[31] ^ ovf
  // Unsigned less: ~Cout
  wire less_s  = sum[31] ^ ovf;
  wire less_u  = ~cout;

  assign o_br_less = i_br_un ? less_s : less_u;
endmodule
