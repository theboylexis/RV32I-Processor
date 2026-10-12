
`timescale 1ns/1ps

module tb_memory;

    logic clk = 0;
    always #5 clk = ~clk;

    logic [31:0] pc_address;
    logic [31:0] instruction;

    logic        mem_write;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    int test_count = 0;

    instruction_memory imem (
        .address(pc_address),
        .instruction(instruction)
    );

    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    task automatic check(
        input logic [31:0] actual,
        input logic [31:0] expected,
        input string name
    );
        if (actual !== expected) begin
            $display("FAIL: %s", name);
            $display("Expected: %h, Actual: %h",
                     expected, actual);
            $fatal(1);
        end

        test_count++;
        $display("PASS: %s", name);
    endtask

    initial begin
        mem_write  = 0;
        address    = 0;
        write_data = 0;
        pc_address = 0;

        // Load instructions directly for unit testing
        imem.memory[0] = 32'h00A30293; // ADDI
        imem.memory[1] = 32'h007302B3; // ADD
        imem.memory[2] = 32'h00532423; // SW

        // Instruction memory tests
        #1;
        check(instruction, 32'h00A30293,
              "Instruction at byte address 0");

        pc_address = 32'h00000004;
        #1;
        check(instruction, 32'h007302B3,
              "Instruction at byte address 4");

        pc_address = 32'h00000008;
        #1;
        check(instruction, 32'h00532423,
              "Instruction at byte address 8");

        // Misaligned fetch must not alias another word
        pc_address = 32'h00000002;
        #1;
        check(instruction, 32'hxxxx_xxxx,
              "Misaligned instruction address");

        // Data memory: write 42 to byte address 0x100
        @(negedge clk);
        mem_write  = 1;
        address    = 32'h00000100;
        write_data = 32'd42;

        @(posedge clk);
        #1;
        check(read_data, 32'd42,
              "Data memory write and read");

        // Check asynchronous memory read
        @(negedge clk);
        mem_write = 0;
        address   = 32'h00000100;

        #1;
        check(read_data, 32'd42,
              "Asynchronous data read");

        // Disabled write must preserve data
        @(negedge clk);
        mem_write  = 0;
        address    = 32'h00000100;
        write_data = 32'd99;

        @(posedge clk);
        #1;
        check(read_data, 32'd42,
              "Memory write disabled");

        // Misaligned read must not return valid word
        @(negedge clk);
        address = 32'h00000102;

        #1;
        check(read_data, 32'hxxxx_xxxx,
              "Misaligned word read");

        $display("--------------------------------");
        $display("ALL %0d MEMORY TESTS PASSED",
                 test_count);
        $finish;
    end

endmodule
