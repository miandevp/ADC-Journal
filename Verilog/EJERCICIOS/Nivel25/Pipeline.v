module Pipeline(
    input clk,
    input reset
);

wire [6:0] opcode;
wire [2:0] funct3;
wire       funct7b5;
wire       opb5;

wire [1:0] AluOp;
wire        ALUSrc;
wire [2:0] AluControl;
wire       RegWrite;

Controller controller(
    .opcode(opcode),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .opb5(opb5),
    .AluOp(AluOp),
    .ALUSrc(ALUSSrc),
    .AluControl(AluControl),
    .RegWrite(RegWrite)
);

Datapath datapath(
    .clk(clk),
    .reset(reset),
    .RegWrite(RegWrite),
    .AluControl(AluControl),
    .ALUSrc(ALUSSrc),

    .opcode(opcode),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .opb5(opb5)
);

endmodule