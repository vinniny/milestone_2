`timescale 1ns/1ps
// Data memory interface (simple SRAM-like)
module dmem (
    input  logic        clk,
    input  logic        we,
    input  logic        re,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:255]; // 1KB (256 words)

    always_ff @(posedge clk) begin
        if (we) mem[addr[9:2]] <= wdata;
    end

    always_comb begin
        rdata = re ? mem[addr[9:2]] : 32'd0;
    end
endmodule
