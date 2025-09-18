`timescale 1ns/1ps

module shifter32(
  input  logic [31:0]  a,
  input  logic [4:0]   shamt,
  input  logic [1:0]   mode,   // 00=SLL, 01=SRL, 10=SRA
  output logic [31:0]  y
);
  // Stage 0: shift by 1
  logic [31:0] s0_l, s0_r, s0_ra;
  assign s0_l  = {a[30:0], 1'b0};
  assign s0_r  = {1'b0, a[31:1]};
  assign s0_ra = {a[31], a[31:1]};

  logic [31:0] st0 = (mode==2'b00) ? ((shamt[0]? s0_l  : a)) :
                     (mode==2'b01) ? ((shamt[0]? s0_r  : a)) :
                                     ((shamt[0]? s0_ra : a));

  // Stage 1: shift by 2
  logic [31:0] s1_l, s1_r, s1_ra;
  assign s1_l  = {st0[29:0], 2'b00};
  assign s1_r  = {2'b00, st0[31:2]};
  assign s1_ra = {{2{st0[31]}}, st0[31:2]};

  logic [31:0] st1 = (mode==2'b00) ? ((shamt[1]? s1_l  : st0)) :
                     (mode==2'b01) ? ((shamt[1]? s1_r  : st0)) :
                                     ((shamt[1]? s1_ra : st0));

  // Stage 2: shift by 4
  logic [31:0] s2_l, s2_r, s2_ra;
  assign s2_l  = {st1[27:0], 4'b0000};
  assign s2_r  = {4'b0000, st1[31:4]};
  assign s2_ra = {{4{st1[31]}}, st1[31:4]};

  logic [31:0] st2 = (mode==2'b00) ? ((shamt[2]? s2_l  : st1)) :
                     (mode==2'b01) ? ((shamt[2]? s2_r  : st1)) :
                                     ((shamt[2]? s2_ra : st1));

  // Stage 3: shift by 8
  logic [31:0] s3_l, s3_r, s3_ra;
  assign s3_l  = {st2[23:0], 8'h00};
  assign s3_r  = {8'h00, st2[31:8]};
  assign s3_ra = {{8{st2[31]}}, st2[31:8]};

  logic [31:0] st3 = (mode==2'b00) ? ((shamt[3]? s3_l  : st2)) :
                     (mode==2'b01) ? ((shamt[3]? s3_r  : st2)) :
                                     ((shamt[3]? s3_ra : st2));

  // Stage 4: shift by 16
  logic [31:0] s4_l, s4_r, s4_ra;
  assign s4_l  = {st3[15:0], 16'h0000};
  assign s4_r  = {16'h0000, st3[31:16]};
  assign s4_ra = {{16{st3[31]}}, st3[31:16]};

  assign y = (mode==2'b00) ? ((shamt[4]? s4_l  : st3)) :
             (mode==2'b01) ? ((shamt[4]? s4_r  : st3)) :
                             ((shamt[4]? s4_ra : st3));
endmodule

