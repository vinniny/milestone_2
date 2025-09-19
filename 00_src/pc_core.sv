`timescale 1ns/1ps

module pc_core(
  input  logic        i_clk,
  input  logic        i_rst_n,
  input  logic [31:0] i_pc_next,
  output logic [31:0] o_pc
);
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) o_pc <= 32'd0;
    else          o_pc <= i_pc_next;
  end

  // Optional one-shot print to confirm reset/start PC (simulation friendly)
  // Using an always block with event controls to satisfy stricter linters.
  // One-shot print on first clock after reset deassertion
  logic printed;
  initial printed = 1'b0;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      printed <= 1'b0;
    end else if (!printed) begin
      printed <= 1'b1;
      $display("PC DEBUG: after reset, PC=%08x (expect 00000000)", o_pc);
    end
  end
endmodule
