`timescale 1ns/1ps

module cpu_tb;
    logic clk = 0;
    always #5 clk = ~clk; // 100MHz

    // Instantiate minimal memories
    logic [31:0] imem_addr, imem_rdata;
    logic        dmem_we, dmem_re;
    logic [31:0] dmem_addr, dmem_wdata, dmem_rdata;

    imem u_imem(
        .addr(imem_addr),
        .rdata(imem_rdata)
    );

    dmem u_dmem(
        .clk(clk), .we(dmem_we), .re(dmem_re),
        .addr(dmem_addr), .wdata(dmem_wdata), .rdata(dmem_rdata)
    );

    logic rst;
    cpu_top u_cpu(
        .clk(clk), .rst(rst),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_we(dmem_we), .dmem_re(dmem_re),
        .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata)
    );

    initial begin
        rst = 1;
        #20; rst = 0;
        #200;
        $display("TB done");
        $finish;
    end
endmodule
