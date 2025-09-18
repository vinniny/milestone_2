`timescale 1ns/1ps
module cpu_tb;
  logic clk = 0, rstn = 0;
  always #5 clk = ~clk;  // 100 MHz

  logic [31:0] pc_dbg, ledr, ledg, lcd, sw = 32'd0;
  logic [3:0]  btn = 4'd0;
  logic        insn_vld;
  logic [6:0]  hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7;

  singlecycle dut(
    .i_clk(clk), .i_rst_n(rstn),
    .o_pc_debug(pc_dbg), .o_insn_vld(insn_vld),
    .o_io_ledr(ledr), .o_io_ledg(ledg),
    .o_io_hex0(hex0), .o_io_hex1(hex1), .o_io_hex2(hex2), .o_io_hex3(hex3),
    .o_io_hex4(hex4), .o_io_hex5(hex5), .o_io_hex6(hex6), .o_io_hex7(hex7),
    .o_io_lcd(lcd),
    .i_io_sw(sw), .i_io_btn(btn)
  );

  // Separate procedures (Verilator prefers timing controls at top of procedures)
  initial begin
    rstn = 0;
  end

  initial begin
    // release reset after 4 rising edges
    repeat (4) @(posedge clk);
    rstn = 1;
  end

  integer cycles = 0;
  integer seen_vld = 0;

  // One clocked process to count, sample, print, and finish
  always @(posedge clk) begin
    cycles <= cycles + 1;
    if (insn_vld) seen_vld <= 1;
    if (cycles % 100 == 0) $display("t=%0t PC=%08x insn_vld=%0d", $time, pc_dbg, insn_vld);

    if (cycles == 2000) begin
      if (!seen_vld) $display("FAIL: o_insn_vld never asserted");
      else           $display("PASS: o_insn_vld asserted");
      $finish;
    end
  end
endmodule
