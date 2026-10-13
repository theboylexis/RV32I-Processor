
`timescale 1ns/1ps

module tb_branch_comparisons;

    logic clk = 0;
    logic rst = 1;

    always #5 clk = ~clk;

    single_cycle_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    task automatic check_pc(
        input logic [31:0] expected,
        input string name
    );
        if (dut.pc !== expected) begin
            $display("FAIL: %s", name);
            $display("Expected PC=%h, Actual PC=%h",
                     expected, dut.pc);
            $fatal(1);
        end

        $display("PASS: %s", name);
    endtask

    initial begin
        // Initialize instruction memory with NOPs
        for (int i = 0; i < 256; i++)
            dut.imem.memory[i] = 32'h00000013;

        // x1 = -1, x2 = 1
        dut.imem.memory[0] = 32'hFFF00093; // ADDI x1,x0,-1
        dut.imem.memory[1] = 32'h00100113; // ADDI x2,x0,1

        // BLT x1,x2,+8 (taken)
        dut.imem.memory[2] = 32'h0020C463;

        // BGE x1,x2,+8 (not taken)
        dut.imem.memory[4] = 32'h0020D463;

        // BLTU x1,x2,+8 (not taken)
        dut.imem.memory[5] = 32'h0020E463;

        // BGEU x1,x2,+8 (taken)
        dut.imem.memory[6] = 32'h0020F463;

        // Skipped when BGEU is taken
        dut.imem.memory[7] = 32'h06300193;

        // Final instruction
        dut.imem.memory[8] = 32'h00700193; // ADDI x3,x0,7

        // Apply reset
        @(posedge clk);
        #1;
        check_pc(32'd0, "Reset");

        @(negedge clk);
        rst = 0;

        @(posedge clk); #1;
        check_pc(32'd4, "Initialize x1");

        @(posedge clk); #1;
        check_pc(32'd8, "Initialize x2");

        @(posedge clk); #1;
        check_pc(32'd16, "BLT taken");

        @(posedge clk); #1;
        check_pc(32'd20, "BGE not taken");

        @(posedge clk); #1;
        check_pc(32'd24, "BLTU not taken");

        @(posedge clk); #1;
        check_pc(32'd32, "BGEU taken");

        @(posedge clk); #1;
        check_pc(32'd36, "Final instruction");

        if (dut.rf.registers[3] !== 32'd7)
            $fatal(1, "FAIL: Final register value");

        $display("PASS: Final register value");
        $display("--------------------------------");
        $display("ALL BRANCH COMPARISON TESTS PASSED");
        $finish;
    end

endmodule
