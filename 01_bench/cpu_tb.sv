`timescale 1ns/1ps
module cpu_tb;
  // Clock/reset
  logic clk = 0, rstn = 0;
  always #5 clk = ~clk;  // 100 MHz

  // DUT I/O
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

  // Use a clocked counter for reset release and stop condition.
  integer cycles = 0;
  logic   seen_vld = 1'b0;
  logic   seen_ledr, seen_ledg;

  // Initialize simple regs only (no @, no repeat)
  initial begin
    rstn      = 0;
    cycles    = 0;
    seen_vld  = 1'b0;
    seen_ledr = 1'b0;
    seen_ledg = 1'b0;
  end

  // Single clocked process controls everything
  always @(posedge clk) begin
    cycles <= cycles + 1;

    // Deassert reset after 4 cycles
    if (cycles == 4) rstn <= 1;

    // Observe signals
    if (insn_vld) seen_vld <= 1;
    if (cycles % 100 == 0) $display("t=%0t PC=%08x insn_vld=%0d", $time, pc_dbg, insn_vld);

    // Observe LED writes from mem.dump
    if (!seen_ledr && ledr == 32'h00000001) begin
      seen_ledr <= 1'b1;
      $display("CHECK: RED LEDs latched 0x%08x at t=%0t", ledr, $time);
    end
    if (!seen_ledg && ledg == 32'h00000002) begin
      seen_ledg <= 1'b1;
      $display("CHECK: GREEN LEDs latched 0x%08x at t=%0t", ledg, $time);
    end

    // Finish after N cycles
    if (cycles == 2000) begin
      if (!seen_vld)           $display("FAIL: o_insn_vld never asserted");
      else if (!seen_ledr)     $display("FAIL: RED LEDs (0x7000) never observed as 0x00000001");
      else if (!seen_ledg)     $display("FAIL: GREEN LEDs (0x7010) never observed as 0x00000002");
      else                     $display("PASS: LED checks and insn_vld OK");
      $finish;
    end
  end
endmodule
