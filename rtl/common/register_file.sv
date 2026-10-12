
module register_file (
    input  logic        clk,
    input  logic        reg_write,
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] registers [0:31];

    // Asynchronous register reads
    assign rs1_data = (rs1_addr == 5'd0)
                    ? 32'b0 : registers[rs1_addr];

    assign rs2_data = (rs2_addr == 5'd0)
                    ? 32'b0 : registers[rs2_addr];

    // Synchronous register write
    always_ff @(posedge clk) begin
        if (reg_write && rd_addr != 5'd0)
            registers[rd_addr] <= rd_data;
    end

endmodule
