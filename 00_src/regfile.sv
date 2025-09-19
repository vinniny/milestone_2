`timescale 1ns/1ps
module regfile(
  input  logic        i_clk, i_rst_n,
  input  logic [4:0]  i_rs1_addr,
  input  logic [4:0]  i_rs2_addr,
  input  logic [4:0]  i_rd_addr,
  input  logic        i_rd_wren,
  input  logic [31:0] i_rd_data,
  output logic [31:0] o_rs1_data,
  output logic [31:0] o_rs2_data
);
  logic [31:0] r [31:0];

  // reads: x0 is hardwired zero
  assign o_rs1_data = (i_rs1_addr == 5'd0) ? 32'd0 : r[i_rs1_addr];
  assign o_rs2_data = (i_rs2_addr == 5'd0) ? 32'd0 : r[i_rs2_addr];

  // writes: ignore if rd==0; loop-free reset
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      r[ 0]<=0; r[ 1]<=0; r[ 2]<=0; r[ 3]<=0; r[ 4]<=0; r[ 5]<=0; r[ 6]<=0; r[ 7]<=0;
      r[ 8]<=0; r[ 9]<=0; r[10]<=0; r[11]<=0; r[12]<=0; r[13]<=0; r[14]<=0; r[15]<=0;
      r[16]<=0; r[17]<=0; r[18]<=0; r[19]<=0; r[20]<=0; r[21]<=0; r[22]<=0; r[23]<=0;
      r[24]<=0; r[25]<=0; r[26]<=0; r[27]<=0; r[28]<=0; r[29]<=0; r[30]<=0; r[31]<=0;
    end else if (i_rd_wren && (i_rd_addr != 5'd0)) begin
      r[i_rd_addr] <= i_rd_data;
    end
  end
endmodule
