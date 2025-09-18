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
    // Stub
endmodule

