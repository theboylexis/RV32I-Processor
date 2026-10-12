
`timescale 1ns/1ps

module tb_immediate_generator;

    logic [31:0] instruction;
    logic [2:0]  imm_src;
    logic [31:0] immediate;

    int test_count = 0;

    immediate_generator dut (
        .instruction(instruction),
        .imm_src(imm_src),
        .immediate(immediate)
    );

    task automatic check_imm(
        input logic [31:0] inst,
        input logic [2:0]  format_sel,
        input logic [31:0] expected,
        input string       test_name
    );
        instruction = inst;
        imm_src     = format_sel;

        #1;

        if (immediate !== expected) begin
            $display("FAIL: %s", test_name);
            $display("Instruction: %h", instruction);
            $display("Expected: %h", expected);
            $display("Actual:   %h", immediate);
            $fatal(1);
        end

        test_count++;
        $display("PASS: %s", test_name);
    endtask

    initial begin

        // I-type
        // ADDI x5, x6, 10
        check_imm(32'h00A30293, 0,
                  32'd10, "I-type positive");

        // ADDI x5, x6, -1
        check_imm(32'hFFF30293, 0,
                  32'hFFFFFFFF, "I-type negative");

        // I-type minimum signed immediate
        check_imm(32'h80030293, 0,
                  32'hFFFFF800, "I-type minimum");

        // S-type
        // SW x5, 8(x6)
        check_imm(32'h00532423, 1,
                  32'd8, "S-type positive");

        // SW x5, -8(x6)
        check_imm(32'hFE532C23, 1,
                  32'hFFFFFFF8, "S-type negative");

        // B-type
        // BEQ x5, x6, 8
        check_imm(32'h00628463, 2,
                  32'd8, "B-type positive");

        // BEQ x5, x6, -4
        check_imm(32'hFE628EE3, 2,
                  32'hFFFFFFFC, "B-type negative");

        // U-type
        // LUI x5, 0x12345
        check_imm(32'h123452B7, 3,
                  32'h12345000, "U-type");

        // U-type high bit set
        check_imm(32'hFFFFF2B7, 3,
                  32'hFFFFF000, "U-type upper bits");

        // J-type
        // JAL x1, 12
        check_imm(32'h00C000EF, 4,
                  32'd12, "J-type positive");

        // JAL x1, -4
        check_imm(32'hFFDFF0EF, 4,
                  32'hFFFFFFFC, "J-type negative");

        // Unsupported selection
        check_imm(32'h00000000, 7,
                  32'd0, "Default selection");

        $display("--------------------------------");
        $display("ALL %0d IMMEDIATE TESTS PASSED",
                 test_count);
        $finish;

    end

endmodule
