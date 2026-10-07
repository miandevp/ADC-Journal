module MainDecoder(
    input  [6:0] opcode,

    output       RegWrite,
    output       ALUSrc,
    output [1:0] AluOp
);

reg [3:0] controls;

assign {RegWrite, ALUSrc, AluOp} = controls;

always @(*) begin
    case(opcode)

        // R-type
        7'b0110011:
            controls = 4'b1_0_10;

        // I-type (ADDI)
        7'b0010011:
            controls = 4'b1_1_10;

        default:
            controls = 4'b0_0_00;

    endcase
end

endmodule