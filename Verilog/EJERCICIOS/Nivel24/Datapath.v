module Datapath(
    input clk,
    input reset,

    input       RegWrite,
    input [2:0] AluControl,

    output [6:0] opcode,
    output [2:0] funct3,
    output       funct7b5,
    output       opb5,

    output       zero,
    output       overflow
);

wire [31:0] instr;
wire [31:0] y;
wire [31:0] pc;
wire [31:0] pcnext;

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

wire [31:0] a;
wire [31:0] b;

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
    .y(y),
    .a(a),
    .b(b)
);

/* ALU */
Alu alu(
    .a(a),
    .b(b),
    .sel(AluControl),
    .y(y),
    .zero(zero),
    .overflow(overflow)
);

endmodule