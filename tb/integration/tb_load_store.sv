
`timescale 1ns/1ps

module tb_load_store;

    logic clk = 0;
    logic rst = 1;

    always #5 clk = ~clk;

    single_cycle_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    // I-type encoder: loads and ADDI
    function automatic [31:0] encode_i(
        input logic [11:0] imm,
        input logic [4:0] rs1,
        input logic [2:0] funct3,
        input logic [4:0] rd,
        input logic [6:0] opcode
    );
        encode_i = {imm, rs1, funct3, rd, opcode};
    endfunction

    // S-type encoder: stores
    function automatic [31:0] encode_s(
        input logic [11:0] imm,
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [2:0] funct3
    );
        encode_s = {
            imm[11:5],
            rs2,
            rs1,
            funct3,
            imm[4:0],
            7'b0100011
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
        // Initialize instruction memory to NOPs
        for (int i = 0; i < 256; i++)
            dut.imem.memory[i] = 32'h00000013;

        // Initialize data memory
        dut.dmem.memory[0] = 32'h12347F80;
        dut.dmem.memory[1] = 32'h00000000;

        // Load instructions
        dut.imem.memory[0] =
            encode_i(0, 0, 3'b000, 1, 7'b0000011); // LB

        dut.imem.memory[1] =
            encode_i(0, 0, 3'b100, 2, 7'b0000011); // LBU

        dut.imem.memory[2] =
            encode_i(0, 0, 3'b001, 3, 7'b0000011); // LH

        dut.imem.memory[3] =
            encode_i(2, 0, 3'b101, 4, 7'b0000011); // LHU

        dut.imem.memory[4] =
            encode_i(0, 0, 3'b010, 5, 7'b0000011); // LW

        // ADDI x6, x0, -86
        dut.imem.memory[5] =
            encode_i(12'hFAA, 0, 3'b000, 6, 7'b0010011);

        // Partial writes
        dut.imem.memory[6] =
            encode_s(1, 0, 6, 3'b000); // SB

        dut.imem.memory[7] =
            encode_s(2, 0, 6, 3'b001); // SH

        dut.imem.memory[8] =
            encode_s(4, 0, 5, 3'b010); // SW

        // Read updated memory
        dut.imem.memory[9] =
            encode_i(3, 0, 3'b100, 7, 7'b0000011); // LBU

        dut.imem.memory[10] =
            encode_i(2, 0, 3'b001, 8, 7'b0000011); // LH

        // Reset
        @(posedge clk);
        #1;
        check(dut.pc, 32'd0, "PC reset");

        @(negedge clk);
        rst = 0;

        // Execute 11 instructions
        for (int i = 0; i < 11; i++) begin
            @(posedge clk);
            #1;
            check(dut.pc, (i + 1) * 32'd4,
                  "Sequential PC");
        end

        // Verify load results
        check(dut.rf.registers[1], 32'hFFFFFF80, "LB");
        check(dut.rf.registers[2], 32'h00000080, "LBU");
        check(dut.rf.registers[3], 32'h00007F80, "LH");
        check(dut.rf.registers[4], 32'h00001234, "LHU");
        check(dut.rf.registers[5], 32'h12347F80, "LW");

        // Verify partial writes
        check(dut.dmem.memory[0], 32'hFFAAAA80,
              "SB and SH preserve unaffected bytes");

        check(dut.dmem.memory[1], 32'h12347F80,
              "SW at second word");

        // Verify loads after stores
        check(dut.rf.registers[7], 32'h000000FF,
              "LBU after SH");

        check(dut.rf.registers[8], 32'hFFFFFFAA,
              "LH after SH");

        $display("--------------------------------");
        $display("ALL LOAD/STORE INTEGRATION TESTS PASSED");
        $finish;
    end

endmodule
