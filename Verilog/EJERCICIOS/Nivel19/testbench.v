`timescale 1ns / 1ps

module testbench_Alu;

    reg [31:0] instr;

    wire [31:0] y;
    wire zero;
    wire overflow;

    MiniDatapath MD (
        .instr(instr),
        .y(y),
        .zero(zero),
        .overflow(overflow)
    );

    initial begin

        // Precargamos nuestros dos registros disponibles
        MD.rf.x1 = 32'd5;
        MD.rf.x2 = 32'd6;

        // funct7   rs2    rs1   funct3   rd     opcode
        // 0000000  00010  00001   000    00101  0110011
        // instr = 0x002082B3
        instr = 32'b0000000_00010_00001_000_00101_0110011; // ADD x5, x1, x2

        #10;

        // funct7   rs2    rs1   funct3   rd     opcode
        // 0000000  00001  00010   000    00101  0110011
        // instr = 0x001102B3
        instr = 32'b0000000_00001_00010_000_00101_0110011; // ADD x5, x2, x1

        #10;

        $finish;

    end

endmodule