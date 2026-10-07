module Datapath(
    input clk,
    input reset,

    /* Señales provenientes del Controller */
    input       RegWrite,
    input       ALUSrc,
    input [2:0] AluControl,

    /* Campos enviados al Controller */
    output [6:0] opcode,
    output [2:0] funct3,
    output       funct7b5,
    output       opb5

    // Puedes volver a sacar zero si luego lo necesitas para beq
    // output zero
);

wire [31:0] instr;

/* Program Counter */
wire [31:0] pc;
wire [31:0] pcnext;

/* Register File */
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

wire [31:0] SrcA;
wire [31:0] RD2;

/* Immediate */
wire [31:0] ImmExt;

/* ALU */
wire [31:0] SrcB;
wire [31:0] AluResult;

/* Señales internas */
wire zero;
wire overflow;


/* Program Counter */
ProgramCounter PCReg(
    .clk(clk),
    .reset(reset),
    .pcnext(pcnext),
    .pc(pc)
);

/* PC + 4 */
PCPlus4 plus4(
    .pc(pc),
    .pcnext(pcnext)
);

/* Instruction Memory */
InstructionMemory imem(
    .pc(pc),
    .instr(instr)
);

/* Extraer campos */
assign opcode   = instr[6:0];
assign funct3   = instr[14:12];
assign rd       = instr[11:7];
assign rs1      = instr[19:15];
assign rs2      = instr[24:20];
assign funct7b5 = instr[30];
assign opb5     = instr[5];

/* Register File */
RegisterFile rf(
    .clk(clk),
    .we(RegWrite),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),

    .y(AluResult),

    .a(SrcA),
    .b(RD2)
);

/* I-Type Immediate Extend */
Extend ext(
    .imm(instr[31:20]),
    .immext(ImmExt)
);



Mux2 srcbmux(
    .d0(RD2),
    .d1(ImmExt),
    .sel(ALUSrc),
    .y(SrcB)
);

/* ALU */
Alu alu(
    .a(SrcA),
    .b(SrcB),
    .sel(AluControl),

    .y(AluResult),

    .zero(zero),
    .overflow(overflow)
);

endmodule