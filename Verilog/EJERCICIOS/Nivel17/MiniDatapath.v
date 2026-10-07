module MiniDatapath(
    input [31:0] a,
    input [31:0] b,

    input [1:0] AluOp,
    input [2:0] funct3,
    input funct7b5,
    input opb5,

    output [31:0] y,
    output zero,
    output overflow
);

wire [2:0] AluControl;

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