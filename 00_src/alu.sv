`timescale 1ns/1ps
// ALU without use of '-', '<', '>', '<<', '>>'
// Supports: ADD, SUB (via add a+~b+1), AND, OR, XOR,
//           SLT/SLTU via subtract sign/borrow,
//           SLL/SRL/SRA via 5-stage barrel shifter built from muxes.
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  op,   // 0000=ADD,0001=SUB,0010=AND,0011=OR,0100=XOR,0101=SLL,0110=SRL,0111=SRA,1000=SLT,1001=SLTU
    output logic [31:0] y
);
    // 32-bit adder
    function automatic [32:0] add32(input logic [31:0] x, input logic [31:0] y, input logic cin);
        logic [32:0] sum;
        sum = {1'b0,x} + {1'b0,y} + cin;
        return sum;
    endfunction

    // SUB = a + ~b + 1
    logic [32:0] add_res;
    logic [31:0] sub_b;
    assign sub_b = ~b;
    
    // Shifter: build left/right/arithmetic via mux stages (no shifts)
    logic [4:0] shamt;
    assign shamt = b[4:0];
    
    function automatic [31:0] shift_left(input logic [31:0] x, input logic [4:0] s);
        logic [31:0] st0, st1, st2, st3, st4;
        // by 1
        st0 = s[0] ? {x[30:0], 1'b0} : x;
        // by 2
        st1 = s[1] ? {st0[29:0], 2'b00} : st0;
        // by 4
        st2 = s[2] ? {st1[27:0], 4'h0} : st1;
        // by 8
        st3 = s[3] ? {st2[23:0], 8'h00} : st2;
        // by 16
        st4 = s[4] ? {st3[15:0], 16'h0000} : st3;
        return st4;
    endfunction

    function automatic [31:0] shift_right_logical(input logic [31:0] x, input logic [4:0] s);
        logic [31:0] st0, st1, st2, st3, st4;
        st0 = s[0] ? {1'b0, x[31:1]} : x;
        st1 = s[1] ? {2'b00, st0[31:2]} : st0;
        st2 = s[2] ? {4'h0, st1[31:4]} : st1;
        st3 = s[3] ? {8'h00, st2[31:8]} : st2;
        st4 = s[4] ? {16'h0000, st3[31:16]} : st3;
        return st4;
    endfunction

    function automatic [31:0] shift_right_arith(input logic [31:0] x, input logic [4:0] s);
        logic fill;
        fill = x[31];
        logic [31:0] st0, st1, st2, st3, st4;
        st0 = s[0] ? {fill, x[31:1]} : x;
        st1 = s[1] ? {{2{fill}}, st0[31:2]} : st0;
        st2 = s[2] ? {{4{fill}}, st1[31:4]} : st1;
        st3 = s[3] ? {{8{fill}}, st2[31:8]} : st2;
        st4 = s[4] ? {{16{fill}}, st3[31:16]} : st3;
        return st4;
    endfunction

    // Perform add/sub
    always_comb begin
        add_res = add32(a, (op==4'b0001 || op==4'b1000 || op==4'b1001) ? sub_b : b, (op==4'b0001 || op==4'b1000 || op==4'b1001));
    end

    // SLT/SLTU from subtract result
    logic sub_neg;      // sign of (a-b)
    logic sub_borrow;   // invert of carry out for a + ~b + 1
    assign sub_neg    = add_res[31];
    assign sub_borrow = ~add_res[32];

    // Equality by XOR-reduction
    logic eq;
    assign eq = ~(|(a ^ b));

    always_comb begin
        unique case (op)
            4'b0000: y = add_res[31:0];                 // ADD
            4'b0001: y = add_res[31:0];                 // SUB via add
            4'b0010: y = a & b;                         // AND
            4'b0011: y = a | b;                         // OR
            4'b0100: y = a ^ b;                         // XOR
            4'b0101: y = shift_left(a, shamt);          // SLL
            4'b0110: y = shift_right_logical(a, shamt); // SRL
            4'b0111: y = shift_right_arith(a, shamt);   // SRA
            4'b1000: y = {31'd0, (a[31] ^ b[31]) ? a[31] : sub_neg}; // SLT signed
            4'b1001: y = {31'd0, sub_borrow};           // SLTU unsigned
            default: y = 32'hDEADBEEF;
        endcase
    end
endmodule
