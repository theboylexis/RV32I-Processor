
`timescale 1ns/1ps

module tb_control_unit;

    logic [31:0] instruction;

    logic alu_src;
    logic reg_write;
    logic mem_write;
    logic result_src;
    logic [2:0] imm_src;
    logic [3:0] alu_op;
    logic valid_instr;
    logic branch_eq;
    logic branch_ne;

    int test_count = 0;

    control_unit dut (.*);

    task automatic check_control(
        input logic [31:0] inst,
        input logic [3:0]  expected_op,
        input logic        expected_alu_src,
        input logic        expected_reg_write,
        input logic        expected_mem_write,
        input logic        expected_result_src,
        input logic [2:0]  expected_imm_src,
        input logic        expected_valid,
        input string       name
    );

        instruction = inst;
        #1;

        if (alu_op      !== expected_op       ||
            alu_src     !== expected_alu_src  ||
            reg_write   !== expected_reg_write ||
            mem_write   !== expected_mem_write ||
            result_src  !== expected_result_src ||
            imm_src     !== expected_imm_src  ||
            valid_instr !== expected_valid) begin

            $display("FAIL: %s", name);
            $display("Instruction: %h", instruction);
            $display("Actual: op=%d src=%b rw=%b mw=%b result=%b imm=%d valid=%b",
                     alu_op, alu_src, reg_write,
                     mem_write, result_src, imm_src,
                     valid_instr);
            $fatal(1);
        end

        test_count++;
        $display("PASS: %s", name);
    endtask

    initial begin

        // ADD x5, x6, x7
        check_control(32'h007302B3,
                      0, 0, 1, 0, 0, 0, 1, "ADD");

        // SUB x5, x6, x7
        check_control(32'h407302B3,
                      1, 0, 1, 0, 0, 0, 1, "SUB");

        // AND x5, x6, x7
        check_control(32'h007372B3,
                      2, 0, 1, 0, 0, 0, 1, "AND");

        // OR x5, x6, x7
        check_control(32'h007362B3,
                      3, 0, 1, 0, 0, 0, 1, "OR");

        // SLT x5, x6, x7
        check_control(32'h007322B3,
                      8, 0, 1, 0, 0, 0, 1, "SLT");

        // ADDI x5, x6, 10
        check_control(32'h00A30293,
                      0, 1, 1, 0, 0, 0, 1, "ADDI");

        // LW x5, 8(x6)
        check_control(32'h00832283,
                      0, 1, 1, 0, 1, 0, 1, "LW");

        // SW x5, 8(x6)
        check_control(32'h00532423,
                      0, 1, 0, 1, 0, 1, 1, "SW");

        // Unsupported instruction
        check_control(32'hFFFF_FFFF,
                      0, 0, 0, 0, 0, 0, 0, "Unsupported");

        // Unsupported R-type funct7 must not write
        check_control(32'h027302B3,
                      0, 0, 0, 0, 0, 0, 0, "Unsupported R-type");

                      
        // Valid R-type: SRA x5, x6, x7
        check_control(32'h407352B3,
                      7, 0, 1, 0, 0, 0, 1,
                      "SRA valid encoding");

        // Invalid R-type: unsupported funct7
        check_control(32'h027302B3,
                      0, 0, 0, 0, 0, 0, 0,
                      "Invalid funct7");

        // Invalid R-type: funct7=0100000 with AND funct3
        check_control(32'h407372B3,
                      0, 0, 0, 0, 0, 0, 0,
                      "Invalid funct7/funct3 combination");

        // BEQ x5, x6, 8
        instruction = 32'h00628463;
        #1;

        if (branch_eq !== 1'b1 ||
            branch_ne !== 1'b0 ||
            valid_instr !== 1'b1 ||
            imm_src !== 3'd2 ||
            reg_write !== 1'b0 ||
            mem_write !== 1'b0)
            $fatal(1, "FAIL: BEQ decoding");

        $display("PASS: BEQ decoding");

        // BNE x5, x6, 8
        instruction = 32'h00629463;
        #1;

        if (branch_eq !== 1'b0 ||
            branch_ne !== 1'b1 ||
            valid_instr !== 1'b1 ||
            imm_src !== 3'd2 ||
            reg_write !== 1'b0 ||
            mem_write !== 1'b0)
            $fatal(1, "FAIL: BNE decoding");

        $display("PASS: BNE decoding");


        $display("--------------------------------");
        $display("ALL %0d CONTROL TESTS PASSED", test_count);
        $finish;

    end

endmodule
