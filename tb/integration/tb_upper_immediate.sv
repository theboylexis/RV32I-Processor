
`timescale 1ns/1ps

module tb_upper_immediate;

    logic clk = 0;
    logic rst = 1;

    always #5 clk = ~clk;

    single_cycle_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    // U-type instruction encoder
    function automatic [31:0] encode_u(
        input logic [19:0] imm20,
        input logic [4:0] rd,
        input logic [6:0] opcode
    );
        encode_u = {imm20, rd, opcode};
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
        // Initialize instruction memory with NOPs
        for (int i = 0; i < 256; i++)
            dut.imem.memory[i] = 32'h00000013;

        // LUI opcode = 0110111
        // AUIPC opcode = 0010111

        dut.imem.memory[0] =
            encode_u(20'h12345, 5'd1, 7'b0110111);

        dut.imem.memory[1] =
            encode_u(20'h12345, 5'd2, 7'b0010111);

        dut.imem.memory[2] =
            encode_u(20'hFFFFF, 5'd3, 7'b0110111);

        dut.imem.memory[3] =
            encode_u(20'hFFFFF, 5'd4, 7'b0010111);

        dut.imem.memory[4] =
            encode_u(20'h00000, 5'd5, 7'b0110111);

        dut.imem.memory[5] =
            encode_u(20'h00000, 5'd6, 7'b0010111);

        // Reset PC
        @(posedge clk);
        #1;
        check(dut.pc, 32'd0, "PC reset");

        @(negedge clk);
        rst = 0;
        
        #1;

        $display("----- LUI DEBUG -----");
        $display("PC         = %h", dut.pc);
        $display("Instruction= %h", dut.instruction);
        $display("Immediate  = %h", dut.immediate);
        $display("LUI        = %b", dut.lui);
        $display("AUIPC      = %b", dut.auipc);
        $display("RegWrite   = %b", dut.reg_write);
        $display("Writeback  = %h", dut.writeback_data);
        $display("---------------------");


        // Execute six instructions
        for (int i = 0; i < 6; i++) begin
            @(posedge clk);
            #1;

            check(dut.pc, (i + 1) * 32'd4,
                  "Sequential PC");
        end

        // Verify register results
        check(dut.rf.registers[1],
              32'h12345000, "LUI positive immediate");

        check(dut.rf.registers[2],
              32'h12345004, "AUIPC nonzero PC");

        check(dut.rf.registers[3],
              32'hFFFFF000, "LUI upper bits set");

        check(dut.rf.registers[4],
              32'hFFFFF00C, "AUIPC upper bits set");

        check(dut.rf.registers[5],
              32'h00000000, "LUI zero immediate");

        check(dut.rf.registers[6],
              32'h00000014, "AUIPC zero immediate");

        $display("--------------------------------");
        $display("ALL U-TYPE INTEGRATION TESTS PASSED");
        $finish;
    end

endmodule
