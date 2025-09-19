`timescale 1ns/1ps

module mux_2to1 #(parameter W=32)(
  input  logic [W-1:0] a,
  input  logic [W-1:0] b,
  input  logic         sel,
  output logic [W-1:0] y
);
  always_comb begin
    unique case (sel)
      1'b0: y = a;
      1'b1: y = b;
    endcase
  end
endmodule

