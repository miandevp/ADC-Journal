`timescale 1ns / 1ps

module testbench_Pipeline;

reg clk;
reg reset;

Pipeline DUT(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin

    clk   = 0;
    reset = 1;

    #10;
    reset = 0;

    // Esperar solo lo necesario
    #60;

    $display("");
    $display("========== RESULTADOS ==========");
    $display("x9  = %h", DUT.rf.RF[9]);
    $display("x10 = %h", DUT.rf.RF[10]);
    $display("x11 = %h", DUT.rf.RF[11]);

    $display("");
    $display("========== PIPELINE ==========");
    $display("instrD      = %h", DUT.instrD);
    $display("SrcAE       = %h", DUT.SrcAE);
    $display("RD2E        = %h", DUT.RD2E);
    $display("ImmExtE     = %h", DUT.ImmExtE);
    $display("AluResultM  = %h", DUT.AluResultM);
    $display("ReadDataW   = %h", DUT.ReadDataW);
    $display("AluResultW  = %h", DUT.AluResultW);
    $display("rdW         = %d", DUT.rdW);

    $finish;

end

endmodule