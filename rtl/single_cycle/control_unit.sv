
module control_unit (
    input  logic [31:0] instruction,

    output logic        alu_src,
    output logic        reg_write,
    output logic        mem_write,
    output logic        result_src,
    output logic [2:0]  imm_src,
    output logic [3:0]  alu_op,
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
        result_src  = 1'b0;
        imm_src     = 3'd0;
        alu_op      = ALU_ADD;
        valid_instr = 1'b0;

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
            7'b0010011: begin
                if (funct3 == 3'b000) begin
                    valid_instr = 1'b1;
                    reg_write   = 1'b1;
                    alu_src     = 1'b1;
                    imm_src     = 3'd0; // I-type
                    alu_op      = ALU_ADD;
                end
            end

            // LW
            7'b0000011: begin
                if (funct3 == 3'b010) begin
                    valid_instr = 1'b1;
                    reg_write   = 1'b1;
                    alu_src     = 1'b1;
                    result_src  = 1'b1;
                    imm_src     = 3'd0; // I-type
                    alu_op      = ALU_ADD;
                end
            end

            // SW
            7'b0100011: begin
                if (funct3 == 3'b010) begin
                    valid_instr = 1'b1;
                    mem_write   = 1'b1;
                    alu_src     = 1'b1;
                    imm_src     = 3'd1; // S-type
                    alu_op      = ALU_ADD;
                end
            end

            default: begin
                // Keep safe defaults
            end

        endcase
    end

endmodule
