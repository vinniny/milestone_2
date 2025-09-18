`timescale 1ns/1ps

module cpu_tb;
    logic clk = 0;
    always #5 clk = ~clk; // 100MHz

    // Regfile wires
    logic        we;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] wdata, rdata1, rdata2;

    // DUTs
    regfile u_rf (
        .clk(clk), .we(we), .rs1(rs1), .rs2(rs2), .rd(rd), .wdata(wdata), .rdata1(rdata1), .rdata2(rdata2)
    );

    // Simple smoke: write x1=0x12345678, read back, expect PASS
    initial begin
        we = 0; rs1 = 0; rs2 = 0; rd = 0; wdata = 0;
        @(negedge clk);
        rd = 5'd1; wdata = 32'h1234_5678; we = 1;
        @(negedge clk);
        we = 0; rs1 = 5'd1; rs2 = 5'd0;
        @(posedge clk);
        if (rdata1 !== 32'h1234_5678) begin
            $display("FAIL: rdata1=%h", rdata1);
            $finish_and_return(1);
        end

        // Quick ALU check
        logic [31:0] y;
        alu u_alu(.a(32'd5), .b(32'd3), .op(3'b000), .y(y));
        #1;
        if (y !== 32'd8) begin
            $display("FAIL: ALU add gave %0d", y);
            $finish_and_return(1);
        end

        $display("PASS");
        $finish;
    end
endmodule

