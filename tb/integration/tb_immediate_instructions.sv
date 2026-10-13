
`timescale 1ns/1ps

module tb_immediate_instructions;

    logic clk = 0;
    logic rst = 1;

    always #5 clk = ~clk;

    single_cycle_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    // Construct an I-type instruction
    function automatic [31:0] encode_i(
        input logic [11:0] imm,
        input logic [4:0] rs1,
        input logic [2:0] funct3,
        input logic [4:0] rd
    );
        encode_i = {
            imm, rs1, funct3, rd, 7'b0010011
        };
    endfunction

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
        // Initialize instruction memory to NOP
        for (int i = 0; i < 256; i++)
            dut.imem.memory[i] = 32'h00000013;

        // Initialize operands
        dut.imem.memory[0] =
            encode_i(12'hFFF, 0, 3'b000, 1);

        dut.imem.memory[1] =
            encode_i(12'd1, 0, 3'b000, 2);

        // ANDI, ORI, XORI
        dut.imem.memory[2] =
            encode_i(12'd15, 1, 3'b111, 3);

        dut.imem.memory[3] =
            encode_i(12'd8, 2, 3'b110, 4);

        dut.imem.memory[4] =
            encode_i(12'd15, 1, 3'b100, 5);

        // SLTI and SLTIU
        dut.imem.memory[5] =
            encode_i(12'd1, 1, 3'b010, 6);

        dut.imem.memory[6] =
            encode_i(12'd1, 1, 3'b011, 7);

        // SLLI, SRLI, SRAI
        dut.imem.memory[7] =
            encode_i(12'h003, 2, 3'b001, 8);

        dut.imem.memory[8] =
            encode_i(12'h004, 1, 3'b101, 9);

        dut.imem.memory[9] =
            encode_i(12'h404, 1, 3'b101, 10);

        // Negative immediate tests
        dut.imem.memory[10] =
            encode_i(12'hFFE, 2, 3'b000, 11);

        dut.imem.memory[11] =
            encode_i(12'hFFF, 2, 3'b011, 12);

        // Reset program counter
        @(posedge clk);
        #1;
        check(dut.pc, 32'd0, "PC reset");

        @(negedge clk);
        rst = 0;

        // Execute 12 instructions
        for (int i = 0; i < 12; i++) begin
            @(posedge clk);
            #1;

            if (dut.pc !== (i + 1) * 4)
                $fatal(1, "PC mismatch at instruction %0d", i);
        end

        // Verify architectural results
        check(dut.rf.registers[1], 32'hFFFFFFFF, "x1 = -1");
        check(dut.rf.registers[2], 32'd1, "x2 = 1");
        check(dut.rf.registers[3], 32'd15, "ANDI");
        check(dut.rf.registers[4], 32'd9, "ORI");
        check(dut.rf.registers[5], 32'hFFFFFFF0, "XORI");
        check(dut.rf.registers[6], 32'd1, "SLTI");
        check(dut.rf.registers[7], 32'd0, "SLTIU");
        check(dut.rf.registers[8], 32'd8, "SLLI");
        check(dut.rf.registers[9], 32'h0FFFFFFF, "SRLI");
        check(dut.rf.registers[10], 32'hFFFFFFFF, "SRAI");
        check(dut.rf.registers[11], 32'hFFFFFFFF, "ADDI negative");
        check(dut.rf.registers[12], 32'd1, "SLTIU negative immediate");

        $display("--------------------------------");
        $display("ALL IMMEDIATE INTEGRATION TESTS PASSED");
        $finish;
    end

endmodule
