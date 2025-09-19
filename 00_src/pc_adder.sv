`timescale 1ns/1ps

module pc_adder(
  input  logic [31:0] i_pc,
  output logic [31:0] o_pc_plus4
);
  // Use gate-level adder (no '+') to compute PC+4
  logic unused_cout, unused_ovf;
  add32 u_add4(
    .a   (i_pc),
    .b   (32'd4),
    .cin (1'b0),
    .sum (o_pc_plus4),
    .cout(unused_cout),
    .ovf (unused_ovf)
  );
endmodule
