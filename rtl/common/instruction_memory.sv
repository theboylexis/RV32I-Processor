
module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    // 256 instructions, each 32 bits
    logic [31:0] memory [0:255];

    always_comb begin
        if ((address < 32'd1024) &&
            (address[1:0] == 2'b00))
            instruction = memory[address[9:2]];
        else
            instruction = 32'hxxxx_xxxx;
    end

endmodule
