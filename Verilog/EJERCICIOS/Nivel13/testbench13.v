`timescale 1ns / 1ps

module testbench_Alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0]sel;
    wire [31:0] y;
    wire zero;
    wire overflow;
    
    Alu dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y),
        .zero(zero),
        .overflow(overflow)
    );

    initial begin
     a=5;
     b=6;
     sel=4;
     
     #10
     
     a=6;
     b=4;
     sel=4;
     
     #10
     
     a=6;
     b=6;
     sel=4;
     #10
     
     a=7;
     b=7;
     sel=5;
     #10
     
     a=10;
     b=2;
     sel=6;
     #10
     
     a=20;
     b=2;
     sel=7;
     #10
     
          
     a=2147483647;
     b=-1;
     sel=4;
     #10
     
     a=2147483647;
     b=-1;
     sel = 1;
     #10
     $finish;
    end
endmodule
