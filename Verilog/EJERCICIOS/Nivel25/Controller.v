module Controller(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7b5,
    input        opb5,

    output [1:0] AluOp,
    output [2:0] AluControl,
    output       RegWrite,
    output       ALUSrc
);

MainDecoder maindec(
    .opcode(opcode),
    .AluOp(AluOp),
    .RegWrite(RegWrite),
    .ALUSrc(ALUSrc)
);

AluDecoder dec(
    .AluOp(AluOp),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .opb5(opb5),
    .AluControl(AluControl)
);

endmodule