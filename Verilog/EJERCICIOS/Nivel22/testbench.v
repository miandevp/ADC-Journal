`timescale 1ns / 1ps

module testbench_Alu;

    reg clk;
    reg [31:0] pc;

    wire zero;
    wire overflow;

    MiniDatapath MD (
        .clk(clk),
        .pc(pc),
        .zero(zero),
        .overflow(overflow)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;

        // PC apuntando a la primera instrucción almacenada
        // en InstructionMemory.
        //
        // instructions.mem
        // Línea 0 : 0x006283B3
        //           ADD x7, x5, x6
        //
        // x5 = 0x0000008A
        // x6 = 0x00000012
        // x7 = 0x00000000
        //
        // Resultado esperado:
        // x7 = 0x0000009C

        pc = 32'b00000000000000000000000000000000;

        #20;

        // Estado del Register File tras ejecutar
        // la instrucción obtenida desde memoria.
        $display("x5 = %h", MD.rf.RF[5]);
        $display("x6 = %h", MD.rf.RF[6]);
        $display("x7 = %h", MD.rf.RF[7]);

        $finish;
    end

endmodule