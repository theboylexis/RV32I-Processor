
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_op,
    output logic [31:0] result
);

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

    logic        sub;
    logic [31:0] arithmetic_result;

    // Shared addition/subtraction hardware
    assign sub = (alu_op == ALU_SUB);

    assign arithmetic_result =
        a + (b ^ {32{sub}}) + {31'b0, sub};

    always_comb begin
        result = 32'b0;

        case (alu_op)
            ALU_ADD, ALU_SUB:
                result = arithmetic_result;

            ALU_AND:
                result = a & b;

            ALU_OR:
                result = a | b;

            ALU_XOR:
                result = a ^ b;

            ALU_SLL:
                result = a << b[4:0];

            ALU_SRL:
                result = a >> b[4:0];

            ALU_SRA:
                result = $signed(a) >>> b[4:0];

            ALU_SLT:
                result = {31'b0, ($signed(a) < $signed(b))};

            ALU_SLTU:
                result = {31'b0, (a < b)};

            default:
                result = 32'b0;
        endcase
    end

endmodule
