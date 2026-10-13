
`timescale 1ns/1ps

module tb_data_memory_access;

    logic clk = 0;
    logic [31:0] address;
    logic [31:0] write_data;
    logic mem_write;
    logic [2:0] funct3;
    logic [31:0] read_data;

    int tests = 0;

    always #5 clk = ~clk;

    data_memory dut (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .mem_write(mem_write),
        .funct3(funct3),
        .read_data(read_data)
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

        tests++;
        $display("PASS: %s", name);
    endtask

    task automatic store(
        input logic [31:0] addr,
        input logic [31:0] value,
        input logic [2:0] size
    );
        @(negedge clk);
        address = addr;
        write_data = value;
        funct3 = size;
        mem_write = 1'b1;

        @(posedge clk);
        #1;

        mem_write = 1'b0;
    endtask

    task automatic load_check(
        input logic [31:0] addr,
        input logic [2:0] size,
        input logic [31:0] expected,
        input string name
    );
        address = addr;
        funct3 = size;
        #1;
        check(read_data, expected, name);
    endtask

    initial begin
        address = 0;
        write_data = 0;
        mem_write = 0;
        funct3 = 0;

        // Known word:
        // Address 0 = 0x80
        // Address 1 = 0x7F
        // Address 2 = 0x34
        // Address 3 = 0x12
        dut.memory[0] = 32'h12347F80;

        // Byte loads
        load_check(0, 3'b000, 32'hFFFFFF80,
                   "LB sign extension");

        load_check(0, 3'b100, 32'h00000080,
                   "LBU zero extension");

        load_check(1, 3'b000, 32'h0000007F,
                   "LB positive byte");

        load_check(2, 3'b100, 32'h00000034,
                   "LBU byte offset 2");

        load_check(3, 3'b100, 32'h00000012,
                   "LBU byte offset 3");

        // Halfword loads
        load_check(0, 3'b001, 32'h00007F80,
                   "LH lower halfword");

        load_check(2, 3'b101, 32'h00001234,
                   "LHU upper halfword");

        // Full word
        load_check(0, 3'b010, 32'h12347F80,
                   "LW full word");

        // Byte store: replace byte at address 1
        store(1, 32'h000000AA, 3'b000);

        load_check(0, 3'b010, 32'h1234AA80,
                   "SB preserves other bytes");

        // Halfword store: replace upper 16 bits
        store(2, 32'h0000BEEF, 3'b001);

        load_check(0, 3'b010, 32'hBEEFAA80,
                   "SH preserves lower halfword");

        // Full-word store
        store(0, 32'hDEADBEEF, 3'b010);

        load_check(0, 3'b010, 32'hDEADBEEF,
                   "SW full word");

        // Alignment checks
        load_check(1, 3'b001, 32'hxxxxxxxx,
                   "Misaligned LH produces unknown");

        load_check(2, 3'b010, 32'hxxxxxxxx,
                   "Misaligned LW produces unknown");

        // Out-of-range address
        load_check(1024, 3'b010, 32'hxxxxxxxx,
                   "Out-of-range load produces unknown");

        $display("--------------------------------");
        $display("ALL %0d MEMORY ACCESS TESTS PASSED", tests);
        $finish;
    end

endmodule
