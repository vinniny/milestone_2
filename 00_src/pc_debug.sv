`timescale 1ns/1ps

module pc_debug(
  input  logic [31:0] i_pc,
  output logic [31:0] o_pc_debug
);
  assign o_pc_debug = i_pc;
endmodule

