
module data_memory (
    input  logic        clk,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    logic [31:0] memory [0:255];

    logic valid_address;

    assign valid_address =
        (address < 32'd1024) &&
        (address[1:0] == 2'b00);

    // Combinational word read
    always_comb begin
        if (valid_address)
            read_data = memory[address[9:2]];
        else
            read_data = 32'hxxxx_xxxx;
    end

    // Synchronous word write
    always_ff @(posedge clk) begin
        if (mem_write && valid_address)
            memory[address[9:2]] <= write_data;
    end

endmodule
