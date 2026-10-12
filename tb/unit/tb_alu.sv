
`timescale 1ns/1ps

module tb_alu;

    logic [31:0] a, b;
    logic [3:0]  alu_op;
    logic [31:0] result;

    int test_count = 0;

    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result)
    );

    task automatic check_alu(
        input logic [3:0]  operation,
        input logic [31:0] operand_a,
        input logic [31:0] operand_b,
        input logic [31:0] expected,
        input string       test_name
    );
        begin
            alu_op = operation;
            a      = operand_a;
            b      = operand_b;

            #1;  // Allow combinational logic to settle

            if (result !== expected) begin
                $display("FAIL: %s", test_name);
                $display("A=%h B=%h OP=%d", a, b, alu_op);
                $display("Expected=%h Actual=%h",
                         expected, result);
                $fatal(1);
            end

            test_count++;
            $display("PASS: %s", test_name);
        end
    endtask

    initial begin

        // ADD
        check_alu(0, 10, 20, 30, "ADD basic");
        check_alu(0, 32'hFFFF_FFFF, 1, 0,
                  "ADD overflow wraparound");

        // SUB
        check_alu(1, 20, 8, 12, "SUB basic");
        check_alu(1, 5, 5, 0, "SUB equal");
        check_alu(1, 3, 5, 32'hFFFF_FFFE,
                  "SUB negative result");

        // AND, OR, XOR
        check_alu(2, 32'hF0F0_0000, 32'hFF00_FF00,
                  32'hF000_0000, "AND");

        check_alu(3, 32'hF0F0_0000, 32'hFF00_FF00,
                  32'hFFF0_FF00, "OR");

        check_alu(4, 32'hF0F0_0000, 32'hFF00_FF00,
                  32'h0FF0_FF00, "XOR");

        // Logical shifts
        check_alu(5, 1, 4, 16, "SLL");
        check_alu(6, 32'h8000_0000, 4,
                  32'h0800_0000, "SRL");

        // Arithmetic right shifts
        check_alu(7, 32'h8000_0000, 4,
                  32'hF800_0000, "SRA negative");

        check_alu(7, 32'h0000_0080, 4,
                  32'h0000_0008, "SRA positive");

        // Only lower five shift bits are used
        check_alu(5, 1, 32, 1,
                  "SLL shift amount masking");

        check_alu(5, 1, 31, 32'h8000_0000,
                  "SLL maximum shift");

        // Signed comparisons
        check_alu(8, 32'hFFFF_FFFF, 1, 1,
                  "SLT negative less than positive");

        check_alu(8, 5, 3, 0,
                  "SLT greater than");

        check_alu(8, 5, 5, 0,
                  "SLT equal");

        // Unsigned comparisons
        check_alu(9, 32'hFFFF_FFFF, 1, 0,
                  "SLTU large unsigned value");

        check_alu(9, 1, 2, 1,
                  "SLTU less than");

        // Unsupported ALU operation
        check_alu(15, 10, 20, 0,
                  "Default operation");

        $display("--------------------------------");
        $display("ALL %0d ALU TESTS PASSED",
                 test_count);
        $finish;

    end

endmodule
