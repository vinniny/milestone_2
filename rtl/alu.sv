// Minimal ALU supporting ADD, SUB, AND, OR, XOR
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [2:0]  op,   // 000=ADD,001=SUB,010=AND,011=OR,100=XOR
    output logic [31:0] y
);
    always_comb begin
        unique case (op)
            3'b000: y = a + b;
            3'b001: y = a - b;
            3'b010: y = a & b;
            3'b011: y = a | b;
            3'b100: y = a ^ b;
            default: y = 32'hDEADBEEF;
        endcase
    end
endmodule

