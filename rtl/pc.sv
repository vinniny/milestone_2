`timescale 1ns/1ps
// Program counter register
module pc (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] pc_next,
    output logic [31:0] pc_curr
);
    always_ff @(posedge clk) begin
        if (rst) pc_curr <= 32'd0;
        else     pc_curr <= pc_next;
    end
endmodule
