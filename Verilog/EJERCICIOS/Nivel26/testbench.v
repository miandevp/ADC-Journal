`timescale 1ns / 1ps

module testbench_Alu;

    reg clk;
    reg reset;

    Pipeline MD (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        // Esperar las 6 instrucciones
        #70;

        $display("x9  = %h (esperado: 11111111)",
                 MD.datapath.rf.RF[9]);

        $display("x10 = %h (esperado: 44444444)",
                 MD.datapath.rf.RF[10]);

        $display("x11 = %h (esperado: BBBBBBBB)",
                 MD.datapath.rf.RF[11]);

        $display("PC  = %h",
                 MD.datapath.PCReg.pc);

        $finish;
    end

endmodule