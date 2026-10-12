
`timescale 1ns/1ps

module tb_program_counter;

    logic        clk;
    logic        rst;
    logic [31:0] next_pc;
    logic [31:0] pc;

    program_counter dut (
        .clk     (clk),
        .rst     (rst),
        .next_pc (next_pc),
        .pc      (pc)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check_pc(
        input logic [31:0] expected
    );
        if (pc !== expected) begin
            $error("Expected PC = %h, got %h",
                   expected, pc);
            $fatal(1);
        end
    endtask

    initial begin
        rst     = 1'b1;
        next_pc = 32'h0000_0020;

        // Test 1: Synchronous reset
        @(posedge clk);
        #1;
        check_pc(32'h0000_0000);
        $display("PASS: Reset");

        // Test 2: Sequential address
        @(negedge clk);
        rst     = 1'b0;
        next_pc = 32'h0000_0004;

        @(posedge clk);
        #1;
        check_pc(32'h0000_0004);
        $display("PASS: Sequential update");

        // Test 3: Alternative target address
        @(negedge clk);
        next_pc = 32'h0000_0100;

        @(posedge clk);
        #1;
        check_pc(32'h0000_0100);
        $display("PASS: Target address update");

        // Test 4: Hold between clock edges
        @(negedge clk);
        next_pc = 32'h0000_0200;
        #1;
        check_pc(32'h0000_0100);
        $display("PASS: Hold between edges");

        // Test 5: Reset priority
        rst     = 1'b1;
        next_pc = 32'h0000_0300;

        @(posedge clk);
        #1;
        check_pc(32'h0000_0000);
        $display("PASS: Reset priority");

        $display("ALL PC TESTS PASSED");
        $finish;
    end

endmodule
