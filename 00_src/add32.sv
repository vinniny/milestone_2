`timescale 1ns/1ps

module add32(
  input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic        cin,
  output logic [31:0] sum,
  output logic        cout,
  output logic        ovf
);
  // Carry chain
  logic c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,
        c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32;
  assign c0 = cin;

  // Bit 0
  wire p0 = a[0] ^ b[0];
  wire g0 = a[0] & b[0];
  assign sum[0] = p0 ^ c0;
  assign c1     = g0 | (p0 & c0);

  // Bit 1
  wire p1 = a[1] ^ b[1];
  wire g1 = a[1] & b[1];
  assign sum[1] = p1 ^ c1;
  assign c2     = g1 | (p1 & c1);

  // Bit 2
  wire p2 = a[2] ^ b[2];
  wire g2 = a[2] & b[2];
  assign sum[2] = p2 ^ c2;
  assign c3     = g2 | (p2 & c2);

  // Bit 3
  wire p3 = a[3] ^ b[3];
  wire g3 = a[3] & b[3];
  assign sum[3] = p3 ^ c3;
  assign c4     = g3 | (p3 & c3);

  // Bit 4
  wire p4 = a[4] ^ b[4];
  wire g4 = a[4] & b[4];
  assign sum[4] = p4 ^ c4;
  assign c5     = g4 | (p4 & c4);

  // Bit 5
  wire p5 = a[5] ^ b[5];
  wire g5 = a[5] & b[5];
  assign sum[5] = p5 ^ c5;
  assign c6     = g5 | (p5 & c5);

  // Bit 6
  wire p6 = a[6] ^ b[6];
  wire g6 = a[6] & b[6];
  assign sum[6] = p6 ^ c6;
  assign c7     = g6 | (p6 & c6);

  // Bit 7
  wire p7 = a[7] ^ b[7];
  wire g7 = a[7] & b[7];
  assign sum[7] = p7 ^ c7;
  assign c8     = g7 | (p7 & c7);

  // Bit 8
  wire p8 = a[8] ^ b[8];
  wire g8 = a[8] & b[8];
  assign sum[8] = p8 ^ c8;
  assign c9     = g8 | (p8 & c8);

  // Bit 9
  wire p9 = a[9] ^ b[9];
  wire g9 = a[9] & b[9];
  assign sum[9] = p9 ^ c9;
  assign c10    = g9 | (p9 & c9);

  // Bit 10
  wire p10 = a[10] ^ b[10];
  wire g10 = a[10] & b[10];
  assign sum[10] = p10 ^ c10;
  assign c11     = g10 | (p10 & c10);

  // Bit 11
  wire p11 = a[11] ^ b[11];
  wire g11 = a[11] & b[11];
  assign sum[11] = p11 ^ c11;
  assign c12     = g11 | (p11 & c11);

  // Bit 12
  wire p12 = a[12] ^ b[12];
  wire g12 = a[12] & b[12];
  assign sum[12] = p12 ^ c12;
  assign c13     = g12 | (p12 & c12);

  // Bit 13
  wire p13 = a[13] ^ b[13];
  wire g13 = a[13] & b[13];
  assign sum[13] = p13 ^ c13;
  assign c14     = g13 | (p13 & c13);

  // Bit 14
  wire p14 = a[14] ^ b[14];
  wire g14 = a[14] & b[14];
  assign sum[14] = p14 ^ c14;
  assign c15     = g14 | (p14 & c14);

  // Bit 15
  wire p15 = a[15] ^ b[15];
  wire g15 = a[15] & b[15];
  assign sum[15] = p15 ^ c15;
  assign c16     = g15 | (p15 & c15);

  // Bit 16
  wire p16 = a[16] ^ b[16];
  wire g16 = a[16] & b[16];
  assign sum[16] = p16 ^ c16;
  assign c17     = g16 | (p16 & c16);

  // Bit 17
  wire p17 = a[17] ^ b[17];
  wire g17 = a[17] & b[17];
  assign sum[17] = p17 ^ c17;
  assign c18     = g17 | (p17 & c17);

  // Bit 18
  wire p18 = a[18] ^ b[18];
  wire g18 = a[18] & b[18];
  assign sum[18] = p18 ^ c18;
  assign c19     = g18 | (p18 & c18);

  // Bit 19
  wire p19 = a[19] ^ b[19];
  wire g19 = a[19] & b[19];
  assign sum[19] = p19 ^ c19;
  assign c20     = g19 | (p19 & c19);

  // Bit 20
  wire p20 = a[20] ^ b[20];
  wire g20 = a[20] & b[20];
  assign sum[20] = p20 ^ c20;
  assign c21     = g20 | (p20 & c20);

  // Bit 21
  wire p21 = a[21] ^ b[21];
  wire g21 = a[21] & b[21];
  assign sum[21] = p21 ^ c21;
  assign c22     = g21 | (p21 & c21);

  // Bit 22
  wire p22 = a[22] ^ b[22];
  wire g22 = a[22] & b[22];
  assign sum[22] = p22 ^ c22;
  assign c23     = g22 | (p22 & c22);

  // Bit 23
  wire p23 = a[23] ^ b[23];
  wire g23 = a[23] & b[23];
  assign sum[23] = p23 ^ c23;
  assign c24     = g23 | (p23 & c23);

  // Bit 24
  wire p24 = a[24] ^ b[24];
  wire g24 = a[24] & b[24];
  assign sum[24] = p24 ^ c24;
  assign c25     = g24 | (p24 & c24);

  // Bit 25
  wire p25 = a[25] ^ b[25];
  wire g25 = a[25] & b[25];
  assign sum[25] = p25 ^ c25;
  assign c26     = g25 | (p25 & c25);

  // Bit 26
  wire p26 = a[26] ^ b[26];
  wire g26 = a[26] & b[26];
  assign sum[26] = p26 ^ c26;
  assign c27     = g26 | (p26 & c26);

  // Bit 27
  wire p27 = a[27] ^ b[27];
  wire g27 = a[27] & b[27];
  assign sum[27] = p27 ^ c27;
  assign c28     = g27 | (p27 & c27);

  // Bit 28
  wire p28 = a[28] ^ b[28];
  wire g28 = a[28] & b[28];
  assign sum[28] = p28 ^ c28;
  assign c29     = g28 | (p28 & c28);

  // Bit 29
  wire p29 = a[29] ^ b[29];
  wire g29 = a[29] & b[29];
  assign sum[29] = p29 ^ c29;
  assign c30     = g29 | (p29 & c29);

  // Bit 30
  wire p30 = a[30] ^ b[30];
  wire g30 = a[30] & b[30];
  assign sum[30] = p30 ^ c30;
  assign c31     = g30 | (p30 & c30);

  // Bit 31
  wire p31 = a[31] ^ b[31];
  wire g31 = a[31] & b[31];
  assign sum[31] = p31 ^ c31;
  assign c32     = g31 | (p31 & c31);

  assign cout = c32;
  // signed overflow: carry into MSB xor carry out of MSB
  assign ovf  = c31 ^ c32;
endmodule
