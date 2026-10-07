`timescale 1ns / 1ps

module testbench_Alu;

    reg clk;
    reg [31:0] instr;

    wire zero;
    wire overflow;

    MiniDatapath MD (
        .clk(clk),
        .instr(instr),
        .zero(zero),
        .overflow(overflow)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;

        // Estado inicial del Register File:
        //
        // x5 = 0x0000008A
        // x6 = 0x00000012
        // x7 = 0x00000000
        //
        // Ejecutaremos:
        //
        // ADD x7, x5, x6
        //
        // 0x006283B3
        //
        // Resultado esperado:
        //
        // x7 = 0x0000009C

        instr = 32'b0000000_00110_00101_000_00111_0110011;

        // Esperar algunos ciclos
        #20;
        
        $display("x5 = %h", MD.rf.RF[5]);
        $display("x6 = %h", MD.rf.RF[6]);
        $display("x7 = %h", MD.rf.RF[7]);
        
        $finish;
    end

endmodule