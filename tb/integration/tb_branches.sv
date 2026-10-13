
`timescale 1ns/1ps

module tb_branches;

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

        // Set x1 = 5 and x2 = 5
        dut.imem.memory[0] = 32'h00500093;
        dut.imem.memory[1] = 32'h00500113;

        // BEQ x1, x2, 8 (taken)
        dut.imem.memory[2] = 32'h00208463;

        // Must be skipped
        dut.imem.memory[3] = 32'h06300193;

        // ADDI x3, x0, 7
        dut.imem.memory[4] = 32'h00700193;

        // BNE x1, x2, 8 (not taken)
        dut.imem.memory[5] = 32'h00209463;

        // ADDI x4, x0, 11
        dut.imem.memory[6] = 32'h00B00213;

        // Change x2 to 6
        dut.imem.memory[7] = 32'h00600113;

        // BNE x1, x2, 8 (taken)
        dut.imem.memory[8] = 32'h00209463;

        // Must be skipped
        dut.imem.memory[9] = 32'h06300213;

        // ADDI x5, x0, 13
        dut.imem.memory[10] = 32'h00D00293;

        // Reset PC
        @(posedge clk);
        #1;
        check(dut.pc, 32'd0, "PC reset");

        @(negedge clk);
        rst = 0;

        // Verify the PC after each executed instruction
        @(posedge clk); #1;
        check(dut.pc, 32'd4, "Instruction 1");

        @(posedge clk); #1;
        check(dut.pc, 32'd8, "Instruction 2");

        @(posedge clk); #1;
        check(dut.pc, 32'd16, "BEQ taken");

        @(posedge clk); #1;
        check(dut.pc, 32'd20, "Instruction after BEQ");

        @(posedge clk); #1;
        check(dut.pc, 32'd24, "BNE not taken");

        @(posedge clk); #1;
        check(dut.pc, 32'd28, "Sequential execution");

        @(posedge clk); #1;
        check(dut.pc, 32'd32, "Update x2");

        @(posedge clk); #1;
        check(dut.pc, 32'd40, "BNE taken");

        @(posedge clk); #1;
        check(dut.pc, 32'd44, "Instruction after BNE");

        // Verify final register state
        check(dut.rf.registers[1], 32'd5,  "x1");
        check(dut.rf.registers[2], 32'd6,  "x2");
        check(dut.rf.registers[3], 32'd7,  "x3");
        check(dut.rf.registers[4], 32'd11, "x4");
        check(dut.rf.registers[5], 32'd13, "x5");

        $display("--------------------------------");
        $display("ALL BRANCH INTEGRATION TESTS PASSED");
        $finish;
    end

endmodule
