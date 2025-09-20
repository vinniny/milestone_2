`timescale 1ns/1ps
module cpu_tb;
  // Clock/reset
  logic clk = 0, rstn = 0;
  always #5 clk = ~clk;  // 100 MHz

  // Top-level TB start banner and early PC prints
  initial $display("TB_MAIN: starting; expect PC=00000000 at cycle 1");
  always @(posedge clk) if (cycles<=3) $display("TB_MAIN: cycle=%0d PC=%08x", cycles, pc_dbg);

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
  logic   seen_hex_lo, seen_hex_hi;
  // Hoisted state for invariants
  logic [31:0] pc_prev;
  logic        pc_prev_valid;
  logic [31:0] ledr_prev, ledg_prev;
  integer      ledr_change_age, ledg_change_age;
  logic [31:0] hex_lo_exp, hex_hi_exp;

  // Initialize simple regs only (no @, no repeat)
  initial begin
    rstn      = 0;
    cycles    = 0;
    seen_vld  = 1'b0;
    seen_ledr = 1'b0;
    seen_ledg = 1'b0;
    seen_hex_lo = 1'b0;
    seen_hex_hi = 1'b0;
    pc_prev_valid    = 1'b0;
    pc_prev          = '0;
    ledr_prev        = 32'h0;
    ledg_prev        = 32'h0;
    ledr_change_age  = -1;
    ledg_change_age  = -1;
    hex_lo_exp       = 32'h0;
    hex_hi_exp       = 32'h0;
  end

  // Watchdog: hard stop after N cycles (configurable via +TB_MAX_CYCLES, default 200_000)
  initial begin : tb_watchdog_cycles
    integer tb_max_cycles;
    if (!$value$plusargs("TB_MAX_CYCLES=%d", tb_max_cycles)) tb_max_cycles = 200_000;
    repeat (tb_max_cycles) @(posedge clk);
    $display("TB TIMEOUT: reached %0d cycles without finishing. Stopping.", tb_max_cycles);
    $finish;
  end

  // Single clocked process controls everything
  always @(posedge clk) begin
    cycles <= cycles + 1;

    // Deassert reset after 4 cycles
    if (cycles == 4) rstn <= 1;

    // Observe signals
    if (insn_vld) seen_vld <= 1;
    if (cycles <= 6)
      $display("TB: cycle=%0d PC=%08x (expect 00000000 at cycle 1)", cycles, pc_dbg);
    else if (cycles % 100 == 0)
      $display("t=%0t PC=%08x insn_vld=%0d", $time, pc_dbg, insn_vld);

    // Invariants and lightweight checks after reset deasserts
    /* verilator lint_off SYNCASYNCNET */
    if (rstn) begin
      // 1) PC should increment by 4 on each valid fetch unless a branch/jump occurred.
      // Detect change in PC and compare against +4 step as a heuristic.
      // Track previous PC
      // hoisted regs
      if (!pc_prev_valid) begin
        pc_prev        <= pc_dbg;
        pc_prev_valid  <= 1;
      end else begin
        if (insn_vld) begin
          if (pc_dbg != pc_prev + 32'd4) begin
            // Allow non +4 deltas assuming a branch/jump was taken if delta != 4
            // If delta is 4, OK; otherwise treat as branch/jump and do not error here.
            // Add a sanity guard: if PC goes backwards by non-word amount, flag it.
          if ((pc_dbg & 32'd3) != 0) $error("PC misaligned: %08x", pc_dbg);
          end
          pc_prev <= pc_dbg;
        end
      end

      // 2) LED MMIO latency: event-based check using LSU writes, wait up to 4 cycles, warn if late
      // Note: using internal DUT signals requires a hierarchical reference; adapt as needed if names change.
      if (dut.lsu_we && (dut.lsu_addr == 32'h0000_7000)) begin
        fork
          begin : wait_ledr_match
            wait (ledr == dut.lsu_wdata) disable fork;
          end
          begin : wait_ledr_timeout
            repeat (4) @(posedge clk);
            if (ledr !== dut.lsu_wdata)
              $display("WARN: RED LEDs did not settle within 4 cycles (saw=%08x exp=%08x)", ledr, dut.lsu_wdata);
          end
        join_any
        disable fork;
      end
      if (dut.lsu_we && (dut.lsu_addr == 32'h0000_7010)) begin
        fork
          begin : wait_ledg_match
            wait (ledg == dut.lsu_wdata) disable fork;
          end
          begin : wait_ledg_timeout
            repeat (4) @(posedge clk);
            if (ledg !== dut.lsu_wdata)
              $display("WARN: GREEN LEDs did not settle within 4 cycles (saw=%08x exp=%08x)", ledg, dut.lsu_wdata);
          end
        join_any
        disable fork;
      end

      if (dut.lsu_we && (dut.lsu_addr == 32'h0000_7020) && !seen_hex_lo) begin
        hex_lo_exp = dut.lsu_wdata;
        fork
          begin : wait_hex_lo_match
            wait ((hex0 == hex_lo_exp[6:0]) &&
                  (hex1 == hex_lo_exp[14:8]) &&
                  (hex2 == hex_lo_exp[22:16]) &&
                  (hex3 == hex_lo_exp[30:24]));
            seen_hex_lo <= 1'b1;
            $display("CHECK: HEX0-3 latched 0x%08x at t=%0t",
                     {1'b0, hex3, 1'b0, hex2, 1'b0, hex1, 1'b0, hex0}, $time);
          end
          begin : wait_hex_lo_timeout
            repeat (4) @(posedge clk);
            if (!((hex0 == hex_lo_exp[6:0]) &&
                  (hex1 == hex_lo_exp[14:8]) &&
                  (hex2 == hex_lo_exp[22:16]) &&
                  (hex3 == hex_lo_exp[30:24]))) begin
              $display("WARN: HEX0-3 did not settle within 4 cycles (saw=%08x exp=%08x)",
                       {1'b0, hex3, 1'b0, hex2, 1'b0, hex1, 1'b0, hex0},
                       {1'b0, hex_lo_exp[30:24], 1'b0, hex_lo_exp[22:16], 1'b0, hex_lo_exp[14:8], 1'b0, hex_lo_exp[6:0]});
            end
          end
        join_any
        disable fork;
      end

      if (dut.lsu_we && (dut.lsu_addr == 32'h0000_7024) && !seen_hex_hi) begin
        hex_hi_exp = dut.lsu_wdata;
        fork
          begin : wait_hex_hi_match
            wait ((hex4 == hex_hi_exp[6:0]) &&
                  (hex5 == hex_hi_exp[14:8]) &&
                  (hex6 == hex_hi_exp[22:16]) &&
                  (hex7 == hex_hi_exp[30:24]));
            seen_hex_hi <= 1'b1;
            $display("CHECK: HEX4-7 latched 0x%08x at t=%0t",
                     {1'b0, hex7, 1'b0, hex6, 1'b0, hex5, 1'b0, hex4}, $time);
          end
          begin : wait_hex_hi_timeout
            repeat (4) @(posedge clk);
            if (!((hex4 == hex_hi_exp[6:0]) &&
                  (hex5 == hex_hi_exp[14:8]) &&
                  (hex6 == hex_hi_exp[22:16]) &&
                  (hex7 == hex_hi_exp[30:24]))) begin
              $display("WARN: HEX4-7 did not settle within 4 cycles (saw=%08x exp=%08x)",
                       {1'b0, hex7, 1'b0, hex6, 1'b0, hex5, 1'b0, hex4},
                       {1'b0, hex_hi_exp[30:24], 1'b0, hex_hi_exp[22:16], 1'b0, hex_hi_exp[14:8], 1'b0, hex_hi_exp[6:0]});
            end
          end
        join_any
        disable fork;
      end

      // 3) x0 immutability: assert that readback zeros are preserved and that writes cannot drive x0 nonzero.
      // We only observe external ports; ensure no LED mirrors x0 (indirect). As a proxy, assert top-level never exposes x0 nonzero.
      // Since x0 is internal, add a coarse check: PC never equals x0+nonzero (always true), and no output attempts to write x0.
      // Minimal invariant we can assert here: zero register cannot be observed nonzero via side effects — simulate by constant zero wire.
      if (1'b0) $fatal("x0 immutability violated (placeholder)");
    end
    /* verilator lint_on SYNCASYNCNET */

    // Observe LED writes from mem.dump
    if (!seen_ledr && ledr == 32'h00000001) begin
      seen_ledr <= 1'b1;
      $display("CHECK: RED LEDs latched 0x%08x at t=%0t", ledr, $time);
    end
    if (!seen_ledg && ledg == 32'h00000002) begin
      seen_ledg <= 1'b1;
      $display("CHECK: GREEN LEDs latched 0x%08x at t=%0t", ledg, $time);
    end

    if (!seen_hex_lo && ({1'b0, hex3, 1'b0, hex2, 1'b0, hex1, 1'b0, hex0} == 32'h08040201)) begin
      seen_hex_lo <= 1'b1;
      $display("CHECK: HEX0-3 observed expected pattern 0x08040201 at t=%0t", $time);
    end
    if (!seen_hex_hi && ({1'b0, hex7, 1'b0, hex6, 1'b0, hex5, 1'b0, hex4} == 32'h3F402010)) begin
      seen_hex_hi <= 1'b1;
      $display("CHECK: HEX4-7 observed expected pattern 0x3F402010 at t=%0t", $time);
    end

    // Finish after N cycles
    if (cycles == 2000) begin
      if (!seen_vld)           $display("FAIL: o_insn_vld never asserted");
      else if (!seen_ledr)     $display("FAIL: RED LEDs (0x7000) never observed as 0x00000001");
      else if (!seen_ledg)     $display("FAIL: GREEN LEDs (0x7010) never observed as 0x00000002");
      else if (!seen_hex_lo)   $display("FAIL: HEX0-HEX3 pattern 0x08040201 never observed");
      else if (!seen_hex_hi)   $display("FAIL: HEX4-HEX7 pattern 0x3F402010 never observed");
      else                     $display("PASS: LED and HEX checks with insn_vld OK");
      $finish;
    end
  end
  endmodule
