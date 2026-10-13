
module control_unit (
    input  logic [31:0] instruction,

    output logic        alu_src,
    output logic        reg_write,
    output logic        mem_write,
    output logic [1:0] result_src,
    output logic [2:0]  imm_src,
    output logic [3:0]  alu_op,
    output logic        branch_eq,
    output logic        branch_ne,
    output logic branch_lt,
    output logic branch_ge,
    output logic branch_ltu,
    output logic branch_geu,
    output logic jump_jal,
    output logic jump_jalr,
    output logic lui,
    output logic auipc,
    output logic        valid_instr
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Internal ALU operation codes
    localparam logic [3:0]
        ALU_ADD  = 4'd0,
        ALU_SUB  = 4'd1,
        ALU_AND  = 4'd2,
        ALU_OR   = 4'd3,
        ALU_XOR  = 4'd4,
        ALU_SLL  = 4'd5,
        ALU_SRL  = 4'd6,
        ALU_SRA  = 4'd7,
        ALU_SLT  = 4'd8,
        ALU_SLTU = 4'd9;

    always_comb begin
        // Safe defaults
        alu_src     = 1'b0;
        reg_write   = 1'b0;
        mem_write   = 1'b0;
        result_src = 2'b00;
        imm_src     = 3'd0;
        alu_op      = ALU_ADD;
        valid_instr = 1'b0;
        branch_eq   = 1'b0;
        branch_ne   = 1'b0;
        branch_lt  = 1'b0;
        branch_ge  = 1'b0;
        branch_ltu = 1'b0;
        branch_geu = 1'b0;
        jump_jal  = 1'b0;
        jump_jalr = 1'b0;
        lui   = 1'b0;
        auipc = 1'b0;

        case (opcode)

            // R-type arithmetic and logical instructions
            7'b0110011: begin
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}:
                        alu_op = ALU_ADD;
                    {7'b0100000, 3'b000}:
                        alu_op = ALU_SUB;
                    {7'b0000000, 3'b111}:
                        alu_op = ALU_AND;
                    {7'b0000000, 3'b110}:
                        alu_op = ALU_OR;
                    {7'b0000000, 3'b100}:
                        alu_op = ALU_XOR;
                    {7'b0000000, 3'b001}:
                        alu_op = ALU_SLL;
                    {7'b0000000, 3'b101}:
                        alu_op = ALU_SRL;
                    {7'b0100000, 3'b101}:
                        alu_op = ALU_SRA;
                    {7'b0000000, 3'b010}:
                        alu_op = ALU_SLT;
                    {7'b0000000, 3'b011}:
                        alu_op = ALU_SLTU;
                    default:
                        alu_op = ALU_ADD;
                endcase

                valid_instr = (
                    (funct7 == 7'b0000000) ||
                    (funct7 == 7'b0100000 &&
                     (funct3 == 3'b000 ||
                      funct3 == 3'b101))
                );

                reg_write = valid_instr;
            end

            // ADDI
            
            // RV32I immediate arithmetic and logical instructions
            7'b0010011: begin
                alu_src = 1'b1;
                imm_src = 3'd0; // I-type

                case (funct3)

                    3'b000: begin // ADDI
                        alu_op = ALU_ADD;
                        valid_instr = 1'b1;
                    end

                    3'b111: begin // ANDI
                        alu_op = ALU_AND;
                        valid_instr = 1'b1;
                    end

                    3'b110: begin // ORI
                        alu_op = ALU_OR;
                        valid_instr = 1'b1;
                    end

                    3'b100: begin // XORI
                        alu_op = ALU_XOR;
                        valid_instr = 1'b1;
                    end

                    3'b010: begin // SLTI
                        alu_op = ALU_SLT;
                        valid_instr = 1'b1;
                    end

                    3'b011: begin // SLTIU
                        alu_op = ALU_SLTU;
                        valid_instr = 1'b1;
                    end

                    3'b001: begin // SLLI
                        if (funct7 == 7'b0000000) begin
                            alu_op = ALU_SLL;
                            valid_instr = 1'b1;
                        end
                    end

                    3'b101: begin
                        case (funct7)
                            7'b0000000: begin // SRLI
                                alu_op = ALU_SRL;
                                valid_instr = 1'b1;
                            end

                            7'b0100000: begin // SRAI
                                alu_op = ALU_SRA;
                                valid_instr = 1'b1;
                            end

                            default: begin
                                // Invalid shift encoding
                            end
                        endcase
                    end

                    default: begin
                        // Unsupported instruction
                    end

                endcase

                reg_write = valid_instr;
            end


            // LW
            
            // RV32I load instructions
            7'b0000011: begin
                case (funct3)
                    3'b000, // LB
                    3'b001, // LH
                    3'b010, // LW
                    3'b100, // LBU
                    3'b101: begin // LHU
                        alu_src     = 1'b1;
                        alu_op      = ALU_ADD;
                        imm_src     = 3'd0;  // I-type
                        result_src  = 2'b01; // Memory data
                        reg_write   = 1'b1;
                        valid_instr = 1'b1;
                    end

                    default: begin
                        // Unsupported load encoding
                    end
                endcase
            end


            // SW
            
            // RV32I store instructions
            7'b0100011: begin
                case (funct3)
                    3'b000, // SB
                    3'b001, // SH
                    3'b010: begin // SW
                        alu_src     = 1'b1;
                        alu_op      = ALU_ADD;
                        imm_src     = 3'd1; // S-type
                        mem_write   = 1'b1;
                        valid_instr = 1'b1;
                    end

                    default: begin
                        // Unsupported store encoding
                    end
                endcase
            end


            
            // RV32I conditional branches
            7'b1100011: begin
                imm_src = 3'd2; // B-type immediate

                case (funct3)

                    // BEQ
                    3'b000: begin
                        branch_eq   = 1'b1;
                        valid_instr = 1'b1;
                    end

                    // BNE
                    3'b001: begin
                        branch_ne   = 1'b1;
                        valid_instr = 1'b1;
                    end

                    // BLT - Signed less than
                    3'b100: begin
                        branch_lt   = 1'b1;
                        valid_instr = 1'b1;
                    end

                    // BGE - Signed greater/equal
                    3'b101: begin
                        branch_ge   = 1'b1;
                        valid_instr = 1'b1;
                    end

                    // BLTU - Unsigned less than
                    3'b110: begin
                        branch_ltu  = 1'b1;
                        valid_instr = 1'b1;
                    end

                    // BGEU - Unsigned greater/equal
                    3'b111: begin
                        branch_geu  = 1'b1;
                        valid_instr = 1'b1;
                    end

                    
                    default: begin
                        // Unsupported branch encoding
                    end

                endcase
            end

            // LUI - Load Upper Immediate
            7'b0110111: begin
                lui         = 1'b1;
                reg_write   = 1'b1;
                imm_src     = 3'd3; // U-type
                valid_instr = 1'b1;
            end

            // AUIPC - Add Upper Immediate to PC
            7'b0010111: begin
                auipc       = 1'b1;
                reg_write   = 1'b1;
                imm_src     = 3'd3; // U-type
                valid_instr = 1'b1;
            end

            // JAL - Jump and Link
            7'b1101111: begin
                jump_jal    = 1'b1;
                reg_write   = 1'b1;
                result_src  = 2'b10; // PC + 4
                imm_src     = 3'd4;  // J-type
                valid_instr = 1'b1;
            end

            // JALR - Jump and Link Register
            7'b1100111: begin
                if (funct3 == 3'b000) begin
                    jump_jalr   = 1'b1;
                    reg_write   = 1'b1;
                    result_src  = 2'b10; // PC + 4
                    imm_src     = 3'd0;  // I-type
                    alu_src     = 1'b1;
                    alu_op      = ALU_ADD;
                    valid_instr = 1'b1;
                end
            end


            default: begin
                // Keep safe defaults
            end

        endcase
    end

endmodule
