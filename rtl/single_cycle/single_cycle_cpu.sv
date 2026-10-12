
module single_cycle_cpu (
    input logic clk,
    input logic rst
);

    // Program counter and instruction
    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] instruction;

    // Register addresses and data
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] writeback_data;

    // Immediate and ALU
    logic [31:0] immediate;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;

    // Data memory
    logic [31:0] memory_data;

    // Control signals
    logic        alu_src;
    logic        reg_write;
    logic        mem_write;
    logic        result_src;
    logic [2:0]  imm_src;
    logic [3:0]  alu_op;
    logic        valid_instr;

    // Instruction fields
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign rd_addr  = instruction[11:7];

    // Sequential PC update (temporary)
    assign next_pc = pc + 32'd4;

    program_counter pc_unit (
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .pc(pc)
    );

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );

    control_unit control (
        .instruction(instruction),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .result_src(result_src),
        .imm_src(imm_src),
        .alu_op(alu_op),
        .valid_instr(valid_instr)
    );

    register_file rf (
        .clk(clk),
        .reg_write(reg_write && !rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(writeback_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    immediate_generator imm_gen (
        .instruction(instruction),
        .imm_src(imm_src),
        .immediate(immediate)
    );

    // Select ALU second operand
    assign alu_operand_b =
        alu_src ? immediate : rs2_data;

    alu alu_unit (
        .a(rs1_data),
        .b(alu_operand_b),
        .alu_op(alu_op),
        .result(alu_result)
    );

    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write && !rst),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(memory_data)
    );

    // Select register write-back source
    assign writeback_data =
        result_src ? memory_data : alu_result;

endmodule
