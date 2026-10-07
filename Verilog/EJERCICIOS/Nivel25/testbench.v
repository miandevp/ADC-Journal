`timescale 1ns / 1ps

module testbench_Alu;

    reg clk;
    reg reset;

    Pipeline MD (
        .clk(clk),
        .reset(reset)
    );

    // Reloj de 10 ns
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        // Reset del PC
        #10;
        reset = 0;

        // Esperar a que se ejecuten las 5 instrucciones
        #50;

        $display("x9  = %h (esperado: 0000000C)", MD.datapath.rf.RF[9]);
        $display("x10 = %h (esperado: 0000001E)", MD.datapath.rf.RF[10]);
        $display("x11 = %h (esperado: 0000002A)", MD.datapath.rf.RF[11]);
        $display("x12 = %h (esperado: 00000004)", MD.datapath.rf.RF[12]);
        $display("x13 = %h (esperado: 00000009)", MD.datapath.rf.RF[13]);

        $display("PC = %h", MD.datapath.PCReg.pc);

        $finish;
    end

endmodule