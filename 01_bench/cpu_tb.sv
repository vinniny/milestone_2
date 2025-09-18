`timescale 1ns/1ps

module cpu_tb;
    // Clock/reset
    logic i_clk = 0;
    always #5 i_clk = ~i_clk; // 100MHz
    logic i_rst_n;

    // IOs
    logic [31:0] o_pc_debug;
    logic        o_insn_vld;
    logic [31:0] o_io_ledr, o_io_ledg, o_io_lcd;
    logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7;
    logic [31:0] i_io_sw = 32'd0;
    logic [3:0]  i_io_btn = 4'd0;

    // DUT
    singlecycle dut(
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .o_pc_debug(o_pc_debug), .o_insn_vld(o_insn_vld),
        .o_io_ledr(o_io_ledr), .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0), .o_io_hex1(o_io_hex1), .o_io_hex2(o_io_hex2), .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4), .o_io_hex5(o_io_hex5), .o_io_hex6(o_io_hex6), .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd),
        .i_io_sw(i_io_sw), .i_io_btn(i_io_btn)
    );

    // Stimulus
    integer vld_count;
    integer i;
    initial begin
        i_rst_n = 0;
        vld_count = 0;
        i = 0;
    end

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            i_rst_n <= 1'b1; // deassert after first posedge
        end else begin
            // periodic print handled in separate initial block
            if (o_insn_vld) vld_count <= vld_count + 1;
            i <= i + 1;
            if (i == 2000) begin
                // finish handled in separate block
            end
        end
    end

    // Periodic prints and finish checks in time-domain initial block
    initial begin
        wait(i_rst_n == 1'b1);
        forever begin
            repeat (100) @(posedge i_clk);
            $display("TB: cycle=%0d pc=%08x vld=%0d", i, o_pc_debug, o_insn_vld);
            if (i >= 2000) begin
                if (vld_count == 0) $display("FAIL: o_insn_vld never asserted");
                else $display("PASS: o_insn_vld asserted %0d times", vld_count);
                $finish;
            end
        end
    end
        if (vld_count == 0) begin
            $display("FAIL: o_insn_vld never asserted");
            $finish;
        end
        $display("PASS: o_insn_vld asserted %0d times", vld_count);
        $finish;
    end
endmodule
