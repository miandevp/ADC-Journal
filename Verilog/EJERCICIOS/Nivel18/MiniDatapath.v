module MiniDatapath(
    input [6:0] opcode,

    input [31:0] a,
    input [31:0] b,

    input [2:0] funct3,
    input funct7b5,

    output [31:0] y,
    output zero,
    output overflow
);

wire [2:0] AluControl;
wire [1:0] AluOp;
wire opb5;

assign opb5 = opcode[5];

MainDecoder maindec(
    .opcode(opcode),
    .AluOp(AluOp)
    );



AluDecoder dec(
    .AluOp(AluOp),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .opb5(opb5),
    .AluControl(AluControl)
);

Alu alu(
    .a(a),
    .b(b),
    .sel(AluControl),
    .y(y),
    .zero(zero),
    .overflow(overflow)
);

endmodule