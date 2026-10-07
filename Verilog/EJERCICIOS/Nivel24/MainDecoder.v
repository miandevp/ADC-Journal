module MainDecoder(
    input [6:0] opcode,
    output reg [1:0] AluOp,
    output reg RegWrite
);

always @(*) begin
    case(opcode)

        // R-type
        7'b0110011: begin
            AluOp    = 2'b10;
            RegWrite = 1'b1;
        end

        // I-type (ADDI, ANDI, ORI, ...)
        7'b0010011: begin
            AluOp    = 2'b10;
            RegWrite = 1'b1;
        end

        default: begin
            AluOp    = 2'b00;
            RegWrite = 1'b0;
        end

    endcase
end

endmodule