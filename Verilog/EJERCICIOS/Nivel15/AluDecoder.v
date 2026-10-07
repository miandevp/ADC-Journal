module AluDecoder(
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [2:0] ALUControl
);

always @(*) begin
    case (funct3)

        3'b000: begin
            if (funct7 == 7'b0100000)
                ALUControl = 3'b001; // SUB
            else
                ALUControl = 3'b000; // ADD
        end

        3'b010:
            ALUControl = 3'b100; // SLT

        3'b011:
            ALUControl = 3'b011; // OR

        3'b111:
            ALUControl = 3'b010; // AND

        3'b100:
            ALUControl = 3'b101; // XOR

        3'b001:
            ALUControl = 3'b110; // SLL

        3'b101:
            ALUControl = 3'b111; // SRL

        default:
            ALUControl = 3'bxxx;

    endcase
end

endmodule