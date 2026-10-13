
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
    logic [1:0] result_src;
    logic [2:0]  imm_src;
    logic [3:0]  alu_op;
    logic        valid_instr;
    logic branch_eq;
    logic branch_ne;
    logic branch_lt;
    logic branch_ge;
    logic branch_ltu;
    logic branch_geu;
    logic branch_taken;
    logic [31:0] branch_target;
    logic jump_jal;
    logic jump_jalr;
    logic [31:0] pc_plus4;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    logic lui;
    logic auipc;

    logic [31:0] upper_immediate_result;

    // Instruction fields
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign rd_addr  = instruction[11:7];

    // Sequential PC update (temporary)
    // Evaluate branch conditions
    
    assign branch_taken =
        (branch_eq  && (rs1_data == rs2_data)) ||
        (branch_ne  && (rs1_data != rs2_data)) ||
        (branch_lt  && ($signed(rs1_data) < $signed(rs2_data))) ||
        (branch_ge  && ($signed(rs1_data) >= $signed(rs2_data))) ||
        (branch_ltu && (rs1_data < rs2_data)) ||
        (branch_geu && (rs1_data >= rs2_data));


    
    // Sequential instruction address
    assign pc_plus4 = pc + 32'd4;

    // Conditional branch target
    assign branch_target = pc + immediate;

    // JAL uses PC-relative addressing
    assign jal_target = pc + immediate;

    // JALR uses register-relative addressing
    // and requires bit 0 to be cleared
    assign jalr_target =
        {alu_result[31:1], 1'b0};

    // Next-PC selection
    always_comb begin
        if (jump_jal)
            next_pc = jal_target;
        else if (jump_jalr)
            next_pc = jalr_target;
        else if (branch_taken)
            next_pc = branch_target;
        else
            next_pc = pc_plus4;
    end


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
        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .branch_lt  (branch_lt),
        .branch_ge  (branch_ge),
        .branch_ltu (branch_ltu),
        .branch_geu (branch_geu),
        .jump_jal  (jump_jal),
        .jump_jalr (jump_jalr),
        .lui   (lui),
        .auipc (auipc),
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

    assign upper_immediate_result =
    auipc ? (pc + immediate) : immediate;

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
        .funct3     (instruction[14:12]),
        .read_data(memory_data)
    );

    // Select register write-back source
    
    // Three-way register write-back selection
    
always_comb begin
    if (lui || auipc) begin
        writeback_data = upper_immediate_result;
    end
    else begin
        case (result_src)
            2'b00:
                writeback_data = alu_result;

            2'b01:
                writeback_data = memory_data;

            2'b10:
                writeback_data = pc_plus4;

            default:
                writeback_data = 32'b0;
        endcase
    end
end



endmodule
