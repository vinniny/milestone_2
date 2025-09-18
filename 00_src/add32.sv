`timescale 1ns/1ps

module add32(
  input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic        cin,
  output logic [31:0] sum,
  output logic        cout,
  output logic        ovf
);
  logic [31:0] p, g;
  logic [32:0] c;
  assign c[0] = cin;
  genvar i;
  generate
    for (i=0;i<32;i++) begin : ADD
      assign p[i]   = a[i] ^ b[i];      // propagate
      assign g[i]   = a[i] & b[i];      // generate
      assign sum[i] = p[i] ^ c[i];
      assign c[i+1] = g[i] | (p[i] & c[i]);
    end
  endgenerate
  assign cout = c[32];
  // signed overflow: carry into MSB xor carry out of MSB
  assign ovf  = c[31] ^ c[32];
endmodule

