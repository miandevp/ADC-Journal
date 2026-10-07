
`timescale 1ns / 1ps

module testbench_Alu;

    reg clk;
    reg reset;

    wire zero;
    wire overflow;

    MiniDatapath MD (
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
        // PC = 0
        #10;
        reset = 0;

        // Programa ejecutado desde instructions.mem:
        //
        // PC = 0
        // ADD x7, x5, x6
        // 138 + 18 = 156
        // x7 = 0000009C
        // zero = 0
        // overflow = 0
        //
        // PC = 4
        // SUB x8, x1, x2
        // 10 - 5 = 5
        // x8 = 00000005
        // zero = 0
        // overflow = 0
        //
        // PC = 8
        // SUB x5, x2, x2
        // 5 - 5 = 0
        // x5 = 00000000
        // zero = 1
        // overflow = 0
        //
        // PC = 12
        // ADD x5, x3, x4
        // 7FFFFFFF + 1 = 80000000
        // zero = 0
        // overflow = 1
        //
        // PC = 16
        // SUB x6, x3, x4
        // 7FFFFFFF - 1 = 7FFFFFFE
        // x6 = 7FFFFFFE
        // zero = 0
        // overflow = 0

        // Esperar la ejecución de las 5 instrucciones
        #50;

        $display("x5  = %h (esperado: 80000000)", MD.rf.RF[5]);
        $display("x6  = %h (esperado: 7FFFFFFE)", MD.rf.RF[6]);
        $display("x7  = %h (esperado: 0000009C)", MD.rf.RF[7]);
        $display("x8  = %h (esperado: 00000005)", MD.rf.RF[8]);
        $display("PC  = %h (esperado: 00000014)", MD.pc);

        $finish;
    end

endmodule
