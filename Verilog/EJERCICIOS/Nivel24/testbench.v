`timescale 1ns / 1ps

module testbench_Alu;

    reg clk;
    reg reset;

    wire zero;
    wire overflow;

    // Antes:
    // MiniDatapath MD (...)

    // Ahora:
    Pipeline MD (
        .clk(clk),
        .reset(reset),
        .zero(zero),
        .overflow(overflow)
    );

    // Generación del reloj
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;

        // Reiniciar el Program Counter
        #10;
        reset = 0;

        // Programa ejecutado desde instructions.mem:
        //
        // PC = 0
        // ADD x7, x5, x6
        // 138 + 18 = 156
        // x7 = 0000009C
        //
        // PC = 4
        // SUB x8, x1, x2
        // 10 - 5 = 5
        // x8 = 00000005
        //
        // PC = 8
        // SUB x5, x2, x2
        // 5 - 5 = 0
        // x5 = 00000000
        //
        // PC = 12
        // ADD x5, x3, x4
        // 7FFFFFFF + 1 = 80000000
        // x5 = 80000000
        //
        // PC = 16
        // SUB x6, x3, x4
        // 7FFFFFFF - 1 = 7FFFFFFE
        // x6 = 7FFFFFFE

        // Esperar la ejecución de las 5 instrucciones
        #50;

        $display("x5  = %h (esperado: 80000000)",
                 MD.datapath.rf.RF[5]);

        $display("x6  = %h (esperado: 7FFFFFFE)",
                 MD.datapath.rf.RF[6]);

        $display("x7  = %h (esperado: 0000009C)",
                 MD.datapath.rf.RF[7]);

        $display("x8  = %h (esperado: 00000005)",
                 MD.datapath.rf.RF[8]);

        $display("PC  = %h (esperado: 00000014)",
                 MD.datapath.PCReg.pc);

        $finish;
    end

endmodule