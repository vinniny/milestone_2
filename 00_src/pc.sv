`timescale 1ns/1ps
// Program counter register
module pc (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] pc_next,
    output logic [31:0] pc_curr
);
    // Single clocked block with async active-low reset
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_curr <= 32'd0;
        end else begin
            pc_curr <= pc_next;
        end
    end
endmodule
