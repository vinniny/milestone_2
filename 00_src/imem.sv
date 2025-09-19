`timescale 1ns/1ps
// Instruction memory ROM: 8 KiB (2048 words)
module imem (
    input  logic [31:0] addr,
    output logic [31:0] rdata
);
    // 8 KiB = 2048 words
    localparam int MEM_WORDS = 2048;
    logic [31:0] mem [0:MEM_WORDS-1];

    // Load from +HEX or default; sanity-check load
    string hex_path;
    initial begin
        if ($value$plusargs("HEX=%s", hex_path))
            $display("IMEM_MAIN: +HEX=%s", hex_path);
        else begin
            hex_path = "02_test/dump/mem.dump";
            $display("IMEM_MAIN: default HEX=%s", hex_path);
        end
        $readmemh(hex_path, mem);
        if (^mem[0] === 1'bX) begin
            $display("FATAL: IMEM mem[0] is X @ %s", hex_path);
            $finish;
        end
    end

    // Word-aligned read; index by PC[12:2] with bounds guard
    logic [10:0] word_idx;
    assign word_idx = addr[12:2];
    always_comb begin
        if ({21'd0,word_idx} < MEM_WORDS) rdata = mem[word_idx];
        else                      rdata = 32'h00000013; // NOP if out-of-range
    end
endmodule
