`timescale 1ns/1ps
// Instruction memory ROM: 8 KiB (2048 words)
module imem (
    input  logic [31:0] addr,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:2047];

    // Load from default path, allow +HEX= override via plusarg
    initial begin
        string path;
        if ($value$plusargs("HEX=%s", path)) begin
            $display("IMEM: loading hex from +HEX=%0s", path);
            $readmemh(path, mem);
        end else begin
            $display("IMEM: loading hex from default 02_test/dump/mem.dump");
            $readmemh("02_test/dump/mem.dump", mem);
        end
    end

    // Word-aligned read; 8 KiB -> use bits [12:2] (2^11 entries)
    assign rdata = mem[addr[12:2]];
endmodule
