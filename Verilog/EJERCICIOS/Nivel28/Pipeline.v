module Pipeline(
    input clk,
    input reset
);

/* =========================
   FETCH
   ========================= */

wire [31:0] pc;
wire [31:0] pcnext;
wire [31:0] instrF;

ProgramCounter PCReg(
    .clk(clk),
    .reset(reset),
    .pcnext(pcnext),
    .pc(pc)
);

PCPlus4 plus4(
    .pc(pc),
    .pcnext(pcnext)
);

InstructionMemory imem(
    .pc(pc),
    .instr(instrF)
);

/* =========================
   IF / ID
   ========================= */

wire [31:0] instrD;

IF_ID if_id(
    .clk(clk),
    .reset(reset),
    .instrF(instrF),
    .instrD(instrD)
);

/* =========================
   DECODE
   ========================= */

wire [6:0] opcode;
wire [2:0] funct3;
wire       funct7b5;
wire       opb5;

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

assign opcode   = instrD[6:0];
assign funct3   = instrD[14:12];
assign rd       = instrD[11:7];
assign rs1      = instrD[19:15];
assign rs2      = instrD[24:20];
assign funct7b5 = instrD[30];
assign opb5     = instrD[5];

wire [1:0] AluOp;

wire RegWriteD;
wire ALUSrcD;
wire ResultSrcD;
wire [2:0] AluControlD;

MainDecoder maindec(
    .opcode(opcode),
    .AluOp(AluOp),
    .RegWrite(RegWriteD),
    .ALUSrc(ALUSrcD),
    .ResultSrc(ResultSrcD)
);

AluDecoder aludec(
    .AluOp(AluOp),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .opb5(opb5),
    .AluControl(AluControlD)
);

wire [31:0] SrcA;
wire [31:0] RD2;
wire [31:0] ImmExt;

RegisterFile rf(
    .clk(clk),
    .we(RegWriteW),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rdW),

    .y(ResultW),

    .a(SrcA),
    .b(RD2)
);

Extend ext(
    .imm(instrD[31:20]),
    .immext(ImmExt)
);

/* =========================
   ID / EX
   ========================= */

wire [31:0] SrcAE;
wire [31:0] RD2E;
wire [31:0] ImmExtE;

wire [4:0] rdE;

wire RegWriteE;
wire ALUSrcE;
wire ResultSrcE;
wire [2:0] AluControlE;

ID_IE id_ie(
    .clk(clk),
    .reset(reset),

    .SrcAD(SrcA),
    .RD2D(RD2),
    .ImmExtD(ImmExt),
    .rdD(rd),

    .RegWriteD(RegWriteD),
    .ALUSrcD(ALUSrcD),
    .ResultSrcD(ResultSrcD),
    .AluControlD(AluControlD),

    .SrcAE(SrcAE),
    .RD2E(RD2E),
    .ImmExtE(ImmExtE),
    .rdE(rdE),

    .RegWriteE(RegWriteE),
    .ALUSrcE(ALUSrcE),
    .ResultSrcE(ResultSrcE),
    .AluControlE(AluControlE)
);

/* =========================
   EXECUTE
   ========================= */

wire [31:0] SrcBE;
wire [31:0] AluResultE;

Mux2 srcbmux(
    .d0(RD2E),
    .d1(ImmExtE),
    .sel(ALUSrcE),
    .y(SrcBE)
);

Alu alu(
    .a(SrcAE),
    .b(SrcBE),
    .sel(AluControlE),

    .y(AluResultE)
);

/* =========================
   EX / MEM
   ========================= */

wire [31:0] AluResultM;
wire [31:0] RD2M;

wire [4:0] rdM;

wire RegWriteM;
wire ResultSrcM;

IE_IM ie_im(
    .clk(clk),
    .reset(reset),

    .AluResultE(AluResultE),
    .RD2E(RD2E),
    .rdE(rdE),

    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),

    .AluResultM(AluResultM),
    .RD2M(RD2M),
    .rdM(rdM),

    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM)
);

/* =========================
   MEMORY
   ========================= */

wire [31:0] ReadData;

DataMemory dmem(
    .a(AluResultM),
    .rd(ReadData)
);

/* =========================
   MEM / WB
   ========================= */

wire [31:0] ReadDataW;
wire [31:0] AluResultW;

wire [4:0] rdW;

wire RegWriteW;
wire ResultSrcW;

IM_IW im_iw(
    .clk(clk),
    .reset(reset),

    .ReadDataM(ReadData),
    .AluResultM(AluResultM),
    .rdM(rdM),

    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),

    .ReadDataW(ReadDataW),
    .AluResultW(AluResultW),
    .rdW(rdW),

    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW)
);

/* =========================
   WRITE BACK
   ========================= */

wire [31:0] ResultW;

Mux2 resultmux(
    .d0(AluResultW),
    .d1(ReadDataW),
    .sel(ResultSrcW),
    .y(ResultW)
);

endmodule