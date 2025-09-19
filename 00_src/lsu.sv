`timescale 1ns/1ps

// Load/Store Unit with simple memory map per milestone
// - 0x2000–0x3FFF: 8 KiB data RAM (word-aligned)
// - 0x7000–0x700F: RED LEDs   (write-mapped)
// - 0x7010–0x701F: GREEN LEDs (write-mapped)
// - 0x7020–0x7027: Seven-seg  (stub safe)
// - 0x7030–0x703F: LCD regs   (stub)
// - 0x7800–0x780F: Switches   (read-mapped)
// - 0x7810–0x781F: Buttons    (read-mapped)
module lsu (
    input  logic        clk,
    input  logic        rst,
    // Access interface (word-aligned LW/SW only)
    input  logic        i_we,
    input  logic        i_re,
    input  logic [31:0] i_addr,
    input  logic [31:0] i_wdata,
    output logic [31:0] o_rdata,
    // IO ports
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic [31:0] o_io_lcd,
    input  logic [31:0] i_io_sw,
    input  logic [3:0]  i_io_btn
);
    // 8 KiB RAM: 2048 words mapped at 0x2000..0x3FFF
    logic [31:0] ram [0:2047];

    // Address decoding helpers (bit-slice compares; no arithmetic/range compares)
    logic in_ram, in_ledr, in_ledg, in_sw, in_btn, in_hex, in_lcd;
    assign in_ram  = (i_addr[15:13] == 3'b001); // 0x2000-0x3FFF (covers 0x2xxx & 0x3xxx)
    assign in_ledr = (i_addr[15:4]  == 12'h700); // 0x7000-0x700F
    assign in_ledg = (i_addr[15:4]  == 12'h701); // 0x7010-0x701F
    // seven-seg 0x7020-0x7027: accept writes, ignore reads
    assign in_hex  = (i_addr[15:3]  == 13'h0E04); // 0x7020..0x7027
    // lcd      0x7030-0x703F: accept writes, ignore reads
    assign in_lcd  = (i_addr[15:4]  == 12'h703);
    assign in_sw   = (i_addr[15:4]  == 12'h780); // 0x7800-0x780F
    assign in_btn  = (i_addr[15:4]  == 12'h781); // 0x7810-0x781F

    // Write side-effects occur on clock edge
    always_ff @(posedge clk) begin
        if (rst) begin
            o_io_ledr <= 32'd0;
            o_io_ledg <= 32'd0;
            o_io_hex0 <= 7'd0;
            o_io_hex1 <= 7'd0;
            o_io_hex2 <= 7'd0;
            o_io_hex3 <= 7'd0;
            o_io_hex4 <= 7'd0;
            o_io_hex5 <= 7'd0;
            o_io_hex6 <= 7'd0;
            o_io_hex7 <= 7'd0;
            o_io_lcd  <= 32'd0;
        end else if (i_we) begin
            if (in_ram) begin
                ram[i_addr[12:2]] <= i_wdata; // word-aligned within 8KiB window
            end else if (in_ledr) begin
                o_io_ledr <= i_wdata;
            end else if (in_ledg) begin
                o_io_ledg <= i_wdata;
            end else if (in_hex) begin
                // Accept writes; map lower 7 bits to hex0 by default (safe stub)
                o_io_hex0 <= i_wdata[6:0];
                o_io_hex1 <= i_wdata[14:8];
                o_io_hex2 <= i_wdata[22:16];
                o_io_hex3 <= i_wdata[30:24];
                // hex4..7 remain as previous (could extend mapping later)
            end else if (in_lcd) begin
                // Accept writes to LCD regs (stub latch)
                o_io_lcd <= i_wdata;
            end else begin
                // Seven-seg and LCD stubs: accept writes, no effect (could latch in future)
                /* verilator lint_off UNUSED */
                logic [31:0] discard;
                discard <= i_wdata;
                /* verilator lint_on UNUSED */
            end
        end
    end

    // Combinational read mux (async read)
    always_comb begin
        o_rdata = 32'd0;
        if (i_re) begin
            if (in_ram) begin
                o_rdata = ram[i_addr[12:2]]; // word-aligned within 8KiB window
            end else if (in_sw) begin
                o_rdata = i_io_sw;
            end else if (in_btn) begin
                o_rdata = {28'd0, i_io_btn};
            end else begin
                o_rdata = 32'd0; // reserved/others
            end
        end
    end

endmodule
