module MiniDatapath(
    input [31:0] instr,

    output [31:0] y,
    output zero,
    output overflow
);

wire [6:0] opcode;
wire [2:0] funct3;
wire funct7b5;
wire opb5;

wire [4:0] rs1;
wire [4:0] rs2;

wire [31:0] a;
wire [31:0] b;

wire [1:0] AluOp;
wire [2:0] AluControl;


// Extraer campos de la instrucción
assign opcode   = instr[6:0];
assign funct3   = instr[14:12];
assign rs1      = instr[19:15];
assign rs2      = instr[24:20];
assign funct7b5 = instr[30];
assign opb5     = instr[5];


// Main Controller
MainDecoder maindec(
    .opcode(opcode),
    .AluOp(AluOp)
);


// ALU Decoder
AluDecoder dec(
    .AluOp(AluOp),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .opb5(opb5),
    .AluControl(AluControl)
);


// Register File limitado (solo x1 y x2)
RegisterFile rf(
    .rs1(rs1),
    .rs2(rs2),
    .a(a),
    .b(b)
);


// ALU
Alu alu(
    .a(a),
    .b(b),
    .sel(AluControl),
    .y(y),
    .zero(zero),
    .overflow(overflow)
);

endmodule