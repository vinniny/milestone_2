`timescale 1ns/1ps
module cpu_tb;
  logic clk = 0, rstn = 0;
  always #5 clk = ~clk;  // 100 MHz

  // Use the project’s top with exact Milestone-2 ports
  logic [31:0] pc_dbg;
  logic        insn_vld;
  logic [31:0] ledr, ledg, lcd;
  logic [6:0]  hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7;
  logic [31:0] sw = 32'd0;
  logic [3:0]  btn = 4'd0;

  singlecycle dut (
    .i_clk(clk), .i_rst_n(rstn),
    .o_pc_debug(pc_dbg),
    .o_insn_vld(insn_vld),
    .o_io_ledr(ledr), .o_io_ledg(ledg),
    .o_io_hex0(hex0), .o_io_hex1(hex1), .o_io_hex2(hex2), .o_io_hex3(hex3),
    .o_io_hex4(hex4), .o_io_hex5(hex5), .o_io_hex6(hex6), .o_io_hex7(hex7),
    .o_io_lcd(lcd),
    .i_io_sw(sw), .i_io_btn(btn)
  );

  integer k, seen_vld;
  initial begin
    seen_vld = 0;
    rstn = 0; repeat (4) @(posedge clk); rstn = 1;
    for (k = 0; k < 2000; k = k + 1) begin
      @(posedge clk);
      if (insn_vld) seen_vld = 1;
      if (k % 100 == 0) $display("t=%0t PC=%08x insn_vld=%0d", $time, pc_dbg, insn_vld);
    end
    if (!seen_vld) $display("FAIL: o_insn_vld never asserted");
    else           $display("PASS: o_insn_vld asserted");
    $finish;
  end
endmodule
