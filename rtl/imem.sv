`timescale 1ns/1ps
// Instruction memory interface (simple ROM-like)
module imem (
    input  logic [31:0] addr,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:255]; // 1KB (256 words)

    initial $readmemh("asm/prog.hex", mem);

    assign rdata = mem[addr[9:2]]; // word aligned
endmodule
