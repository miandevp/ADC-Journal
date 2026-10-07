module MainDecoder(
    input  [6:0] opcode,

    output       RegWrite,
    output       ALUSrc,
    output       ResultSrc,
    output [1:0] AluOp
);

reg [4:0] controls;

assign {RegWrite, ALUSrc, ResultSrc, AluOp} = controls;
always @(*) begin
    case(opcode)

        // R-type (add)
        7'b0110011:
            controls = 5'b1_0_0_10;

        // I-type (addi)
        7'b0010011:
            controls = 5'b1_1_0_10;

        // LW
        7'b0000011:
            controls = 5'b1_1_1_00;

        default:
            controls = 5'b0_0_0_00;

    endcase
end

endmodule