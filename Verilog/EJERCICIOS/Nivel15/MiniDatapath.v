

module MiniDatapath(
    input [31:0] a,
    input [31:0] b,
    input [2:0] funct3,
    input [6:0] funct7b5,

    output [31:0] y,
    output zero,
    output overflow
);

wire [2:0] AluControl;

AluDecoder dec(
    .funct3(funct3),
    .funct7b5(funct7b5),
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
