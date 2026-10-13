
`timescale 1ns/1ps

module tb_jumps;

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

        // Set up registers
        dut.imem.memory[0] = 32'h00200113; // ADDI x2,x0,2
        dut.imem.memory[1] = 32'h02500293; // ADDI x5,x0,37

        // JAL x1,12: PC=8 -> PC=20, x1=12
        dut.imem.memory[2] = 32'h00C000EF;

        // Instructions that must be skipped
        dut.imem.memory[3] = 32'h06300113; // x2=99
        dut.imem.memory[4] = 32'h06200113; // x2=98

        // Jump destination
        dut.imem.memory[5] = 32'h00700193; // ADDI x3,x0,7

        // JALR x4,0(x5)
        // x5=37, bit 0 cleared -> target=36
        dut.imem.memory[6] = 32'h00028267;

        // Instructions that must be skipped
        dut.imem.memory[7] = 32'h06100113; // x2=97
        dut.imem.memory[8] = 32'h06000113; // x2=96

        // Final destination
        dut.imem.memory[9] = 32'h00D00393; // ADDI x7,x0,13

        // Reset
        @(posedge clk);
        #1;
        check(dut.pc, 32'd0, "PC reset");

        @(negedge clk);
        rst = 0;

        @(posedge clk); #1;
        check(dut.pc, 32'd4, "Initialize x2");

        @(posedge clk); #1;
        check(dut.pc, 32'd8, "Initialize x5");

        @(posedge clk); #1;
        check(dut.pc, 32'd20, "JAL target");

        @(posedge clk); #1;
        check(dut.pc, 32'd24, "After JAL");

        @(posedge clk); #1;
        check(dut.pc, 32'd36, "JALR target");

        @(posedge clk); #1;
        check(dut.pc, 32'd40, "After JALR");

        // Verify architectural state
        check(dut.rf.registers[1], 32'd12,
              "JAL return address");

        check(dut.rf.registers[4], 32'd28,
              "JALR return address");

        check(dut.rf.registers[2], 32'd2,
              "Skipped instructions did not execute");

        check(dut.rf.registers[3], 32'd7,
              "JAL destination executed");

        check(dut.rf.registers[7], 32'd13,
              "JALR destination executed");

        $display("--------------------------------");
        $display("ALL JUMP INTEGRATION TESTS PASSED");
        $finish;
    end

endmodule
