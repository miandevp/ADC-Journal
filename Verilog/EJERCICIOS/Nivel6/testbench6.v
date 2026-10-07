`timescale 1ns / 1ps

module testbench_Alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [1:0]sel;
    wire [31:0] y;
    
    Alu dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
     a=5;
     b=5;
     sel=1;
     
     #10
     
     a=6;
     sel=0;
     b=3;
    
    end
endmodule
