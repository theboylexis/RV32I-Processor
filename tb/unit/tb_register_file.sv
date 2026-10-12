
`timescale 1ns/1ps

module tb_register_file;

    logic clk = 0;
    logic reg_write;
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rd_data;
    logic [31:0] rs1_data, rs2_data;

    register_file dut (
        .clk(clk),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;

    task automatic check(
        input logic [31:0] actual,
        input logic [31:0] expected
    );
        if (actual !== expected) begin
            $error("Expected %h, got %h", expected, actual);
            $fatal(1);
        end
    endtask

    initial begin
        reg_write = 0;
        rs1_addr  = 0;
        rs2_addr  = 0;
        rd_addr   = 0;
        rd_data   = 0;

        // Test 1: x0 always reads zero
        #1;
        check(rs1_data, 32'd0);
        check(rs2_data, 32'd0);
        $display("PASS: x0 reads zero");

        // Test 2: Write 42 into x5
        @(negedge clk);
        reg_write = 1;
        rd_addr   = 5;
        rd_data   = 42;

        @(posedge clk);
        #1;
        rs1_addr = 5;
        #1;
        check(rs1_data, 42);
        $display("PASS: Register write/read");

        // Test 3: Dual asynchronous reads
        @(negedge clk);
        rd_addr = 6;
        rd_data = 100;

        @(posedge clk);
        #1;
        rs1_addr = 5;
        rs2_addr = 6;
        #1;
        check(rs1_data, 42);
        check(rs2_data, 100);
        $display("PASS: Dual read ports");

        // Test 4: Write enable protection
        @(negedge clk);
        reg_write = 0;
        rd_addr   = 5;
        rd_data   = 999;

        @(posedge clk);
        #1;
        check(rs1_data, 42);
        $display("PASS: Write disabled");


        // Test 5: x0 write protection
        @(negedge clk);
        reg_write = 1;
        rd_addr   = 0;
        rd_data   = 123;

        @(posedge clk);
        #1;
        rs1_addr = 0;
        rs2_addr = 0;

        #1; // Allow combinational reads to settle

        check(rs1_data, 0);
        check(rs2_data, 0);
        $display("PASS: x0 write protection");


        $display("ALL REGISTER FILE TESTS PASSED");
        $finish;
    end

endmodule
