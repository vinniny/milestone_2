// Simple 32x32 register file (x0 hardwired to 0)
module regfile (
    input  logic        clk,
    input  logic        we,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] wdata,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);
    logic [31:0] regs [31:0];

    // Combinational reads; x0 always 0
    assign rdata1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    assign rdata2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

    // Synchronous write; ignore writes to x0
    always_ff @(posedge clk) begin
        if (we && rd != 5'd0) begin
            regs[rd] <= wdata;
        end
    end
endmodule

