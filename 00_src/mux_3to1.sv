`timescale 1ns/1ps

module mux_3to1 #(parameter W=32)(
  input  logic [W-1:0] a0,
  input  logic [W-1:0] a1,
  input  logic [W-1:0] a2,
  input  logic [1:0]   sel,
  output logic [W-1:0] y
);
  always_comb begin
    unique case (sel)
      2'd0: y = a0;
      2'd1: y = a1;
      2'd2: y = a2;
      default: y = a0;
    endcase
  end
endmodule

