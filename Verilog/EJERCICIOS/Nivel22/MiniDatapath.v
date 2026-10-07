
module MiniDatapath(
    input clk,
    input [31:0] pc,

    output zero,
    output overflow
);

wire [31:0] instr;
wire [31:0] y;

// Instrucción obtenida desde la memoria
InstructionMemory imem(
    .pc(pc),
    .instr(instr)
);

wire [6:0] opcode;
wire [2:0] funct3;
wire       funct7b5;
wire       opb5;

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

wire [31:0] a;
wire [31:0] b;

wire [1:0] AluOp;
wire [2:0] AluControl;
wire       RegWrite;

// Extraer campos de la instrucción
assign opcode   = instr[6:0];
assign funct3   = instr[14:12];
assign rd       = instr[11:7];
assign rs1      = instr[19:15];
assign rs2      = instr[24:20];
assign funct7b5 = instr[30];
assign opb5     = instr[5];

// Decoder principal
MainDecoder maindec(
    .opcode(opcode),
    .AluOp(AluOp),
    .RegWrite(RegWrite)
);

// Decoder de la ALU
AluDecoder dec(
    .AluOp(AluOp),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .opb5(opb5),
    .AluControl(AluControl)
);

// Banco de registros
RegisterFile rf(
    .clk(clk),
    .we(RegWrite),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .y(y),

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
