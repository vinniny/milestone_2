`timescale 1ns/1ps
// Branch comparator without '<' using subtract and XOR-reduction
module brc (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        i_br_un,      // 1: unsigned compare, 0: signed
    output logic        o_br_equal,
    output logic        o_br_less
);
    // Equality
    assign o_br_equal = ~(|(a ^ b));

    // a - b via a + ~b + 1
    logic [32:0] diff;
    assign diff = {1'b0,a} + {1'b0,~b} + 33'd1;

    // Signed less: sign of (a-b) when signs equal; when signs differ, sign of a
    logic signed_less;
    assign signed_less = (a[31] ^ b[31]) ? a[31] : diff[31];

    // Unsigned less via borrow (carry out == 0 indicates a<b)
    logic unsigned_less;
    assign unsigned_less = ~diff[32];

    assign o_br_less = i_br_un ? unsigned_less : signed_less;
endmodule
