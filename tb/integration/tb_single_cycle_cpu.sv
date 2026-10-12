
`timescale 1ns/1ps

module tb_single_cycle_cpu;

    logic clk = 0;
    logic rst = 1;

    always #5 clk = ~clk;

    single_cycle_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    task automatic check(
        input logic [31:0] actual,
        input logic [31:0] expected,
        input string name
    );
        if (actual !== expected) begin
            $display("FAIL: %s", name);
            $display("Expected=%h Actual=%h",
                     expected, actual);
            $fatal(1);
        end

        $display("PASS: %s", name);
    endtask

    initial begin
        // Initialize instruction memory with NOPs
        for (int i = 0; i < 256; i++)
            dut.imem.memory[i] = 32'h00000013;

        // Load the test program
        dut.imem.memory[0] = 32'h01000093; // ADDI x1,x0,16
        dut.imem.memory[1] = 32'h00700113; // ADDI x2,x0,7
        dut.imem.memory[2] = 32'h002081B3; // ADD x3,x1,x2
        dut.imem.memory[3] = 32'h00302023; // SW x3,0(x0)
        dut.imem.memory[4] = 32'h00002203; // LW x4,0(x0)
        dut.imem.memory[5] = 32'h002202B3; // ADD x5,x4,x2

        // Apply synchronous reset
        @(posedge clk);
        #1;
        check(dut.pc, 32'd0, "PC reset");

        @(negedge clk);
        rst = 0;

        // Execute six instructions
        for (int i = 0; i < 6; i++) begin
            @(posedge clk);
            #1;

            check(dut.pc, 32'((i + 1) * 4),
                  "PC advancement");

            $display("Completed instruction %0d", i + 1);
        end

        // Check architectural results
        check(dut.rf.registers[1], 32'd16, "x1 = 16");
        check(dut.rf.registers[2], 32'd7,  "x2 = 7");
        check(dut.rf.registers[3], 32'd23, "x3 = 23");
        check(dut.rf.registers[4], 32'd23, "x4 = 23");
        check(dut.rf.registers[5], 32'd30, "x5 = 30");

        check(dut.dmem.memory[0], 32'd23,
              "Memory[0] = 23");

        $display("--------------------------------");
        $display("FIRST INTEGRATED CPU PROGRAM PASSED");
        $finish;
    end

endmodule
