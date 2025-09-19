`timescale 1ns/1ps

module pc_adder(
  input  logic [31:0] i_pc,
  output logic [31:0] o_pc_plus4
);
  assign o_pc_plus4 = i_pc + 32'd4;
endmodule

