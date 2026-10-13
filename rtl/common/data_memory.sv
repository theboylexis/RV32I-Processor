
module data_memory (
    input  logic        clk,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    input  logic        mem_write,
    input  logic [2:0]  funct3,
    output logic [31:0] read_data
);

    logic [31:0] memory [0:255];

    logic [7:0] selected_byte;
    logic [15:0] selected_halfword;

    wire [7:0] word_index = address[9:2];
    wire [1:0] byte_offset = address[1:0];

    wire valid_address = (address < 32'd1024);

    // Asynchronous read
    always_comb begin
        selected_byte = 8'b0;
        selected_halfword = 16'b0;
        read_data = 32'bx;

        if (valid_address) begin

            selected_byte =
                memory[word_index][8*byte_offset +: 8];

            case (byte_offset)
                2'd0:
                    selected_halfword =
                        memory[word_index][15:0];

                2'd2:
                    selected_halfword =
                        memory[word_index][31:16];

                default:
                    selected_halfword = 16'b0;
            endcase

            case (funct3)

                3'b000: // LB
                    read_data = {
                        {24{selected_byte[7]}},
                        selected_byte
                    };

                3'b100: // LBU
                    read_data = {24'b0, selected_byte};

                3'b001: begin // LH
                    if (byte_offset[0] == 1'b0)
                        read_data = {
                            {16{selected_halfword[15]}},
                            selected_halfword
                        };
                end

                3'b101: begin // LHU
                    if (byte_offset[0] == 1'b0)
                        read_data = {
                            16'b0,
                            selected_halfword
                        };
                end

                3'b010: begin // LW
                    if (byte_offset == 2'b00)
                        read_data = memory[word_index];
                end

                default:
                    read_data = 32'bx;

            endcase
        end
    end

    // Synchronous write
    always_ff @(posedge clk) begin
        if (mem_write && valid_address) begin

            case (funct3)

                3'b000: begin // SB
                    memory[word_index][8*byte_offset +: 8]
                        <= write_data[7:0];
                end

                3'b001: begin // SH
                    if (byte_offset[0] == 1'b0)
                        memory[word_index][8*byte_offset +: 16]
                            <= write_data[15:0];
                end

                3'b010: begin // SW
                    if (byte_offset == 2'b00)
                        memory[word_index] <= write_data;
                end

                default: begin
                    // Unsupported store encoding
                end

            endcase
        end
    end

endmodule
