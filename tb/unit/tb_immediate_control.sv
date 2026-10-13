
`timescale 1ns/1ps

module tb_immediate_control;

    logic [31:0] instruction;

    logic alu_src;
    logic reg_write;
    logic mem_write;
    logic [1:0] result_src;
    logic [2:0] imm_src;
    logic [3:0] alu_op;
    logic valid_instr;

    int test_count = 0;

    control_unit dut (
        .instruction(instruction),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .result_src(result_src),
        .imm_src(imm_src),
        .alu_op(alu_op),
        .valid_instr(valid_instr)
    );

    // Construct I-type instruction encodings
    function automatic [31:0] encode_i(
        input logic [11:0] imm,
        input logic [2:0] funct3
    );
        encode_i = {
            imm,
            5'd1,          // rs1 = x1
            funct3,
            5'd2,          // rd = x2
            7'b0010011    // OP-IMM opcode
        };
    endfunction

    task automatic check_decode(
        input logic [31:0] inst,
        input logic [3:0] expected_op,
        input logic expected_valid,
        input string name
    );
        instruction = inst;
        #1;

        if (alu_op !== expected_op ||
            valid_instr !== expected_valid ||
            reg_write !== expected_valid ||
            alu_src !== 1'b1 ||
            imm_src !== 3'd0 ||
            mem_write !== 1'b0 ||
            result_src !== 2'b00) begin

            $display("FAIL: %s", name);
            $display("Instruction=%h OP=%d Valid=%b",
                     instruction, alu_op, valid_instr);
            $fatal(1);
        end

        test_count++;
        $display("PASS: %s", name);
    endtask

    initial begin

        // Arithmetic and logical immediates
        check_decode(encode_i(12'd10, 3'b000),
                     0, 1, "ADDI");

        check_decode(encode_i(12'd15, 3'b111),
                     2, 1, "ANDI");

        check_decode(encode_i(12'd15, 3'b110),
                     3, 1, "ORI");

        check_decode(encode_i(12'd15, 3'b100),
                     4, 1, "XORI");

        // Comparisons
        check_decode(encode_i(12'd5, 3'b010),
                     8, 1, "SLTI");

        check_decode(encode_i(12'd5, 3'b011),
                     9, 1, "SLTIU");

        // Shift immediates
        check_decode(encode_i(12'h003, 3'b001),
                     5, 1, "SLLI");

        check_decode(encode_i(12'h003, 3'b101),
                     6, 1, "SRLI");

        check_decode(encode_i(12'h403, 3'b101),
                     7, 1, "SRAI");

        // Invalid shift encodings
        check_decode(encode_i(12'h403, 3'b001),
                     0, 0, "Invalid SLLI");

        check_decode(encode_i(12'h203, 3'b101),
                     0, 0, "Invalid right shift");

        $display("--------------------------------");
        $display("ALL %0d IMMEDIATE CONTROL TESTS PASSED",
                 test_count);
        $finish;

    end

endmodule
