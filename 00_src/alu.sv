`timescale 1ns/1ps

module alu(
  input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [3:0]  op,     // 0=ADD,1=SUB,2=AND,3=OR,4=XOR,5=SLL,6=SRL,7=SRA,8=SLT,9=SLTU
  output logic [31:0] y,
  output logic        zero
);
  // shared adder for ADD/SUB and compare
  logic [31:0] b_sub = ~b;
  logic [31:0] add_in_b;
  logic        add_in_cin;
  logic [31:0] add_sum;
  logic        add_cout, add_ovf;

  // SUB uses a + (~b) + 1; ADD uses a + b + 0
  always_comb begin
    if (op==4'd1 || op==4'd8 || op==4'd9) begin
      add_in_b   = b_sub;
      add_in_cin = 1'b1;
    end else begin
      add_in_b   = b;
      add_in_cin = 1'b0;
    end
  end

  add32 u_add(.a(a), .b(add_in_b), .cin(add_in_cin), .sum(add_sum), .cout(add_cout), .ovf(add_ovf));

  // Shifts via barrel shifter
  logic [31:0] sh_y;
  logic [1:0]  sh_mode;
  assign sh_mode = (op==4'd5) ? 2'b00 :   // SLL
                   (op==4'd6) ? 2'b01 :   // SRL
                   (op==4'd7) ? 2'b10 :   // SRA
                                 2'b00;   // default
  shifter32 u_sh(.a(a), .shamt(b[4:0]), .mode(sh_mode), .y(sh_y));

  // Comparisons from subtract flags (a - b)
  // Signed less: N xor V -> add_sum[31] ^ add_ovf
  // Unsigned less: ~Cout
  logic slt  = add_sum[31] ^ add_ovf;
  logic sltu = ~add_cout;

  always_comb begin
    unique case (op)
      4'd0: y = add_sum;         // ADD
      4'd1: y = add_sum;         // SUB (via adder w/ ~b + 1)
      4'd2: y = a & b;           // AND
      4'd3: y = a | b;           // OR
      4'd4: y = a ^ b;           // XOR
      4'd5: y = sh_y;            // SLL
      4'd6: y = sh_y;            // SRL
      4'd7: y = sh_y;            // SRA
      4'd8: y = {31'd0, slt};    // SLT
      4'd9: y = {31'd0, sltu};   // SLTU
      default: y = 32'd0;
    endcase
  end

  assign zero = ~(|y);
endmodule
