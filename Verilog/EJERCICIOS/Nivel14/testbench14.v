`timescale 1ns / 1ps

module testbench_Alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0]funct3;
    wire [31:0] y;
    wire zero;
    wire overflow;
    
    MiniDatapath MD (
        .a(a),
        .b(b),
        .funct3(funct3),
        .y(y),
        .zero(zero),
        .overflow(overflow)
    );

    initial begin
     a=5;
     b=6;
     funct3=4;
     
     #10
     
     a=6;
     b=4;
     funct3=4;
     
     #10
     
     a=6;
     b=6;
     funct3=4;
     #10
     
     a=7;
     b=7;
     funct3=5;
     #10
     
     a=10;
     b=2;
     funct3=6;
     #10
     
     a=20;
     b=2;
     funct3=7;
     #10
     
          
     a=2147483647;
     b=-1;
     funct3=4;
     #10
     
     a=2147483647;
     b=-1;
     funct3 = 1;
     #10
     $finish;
    end
endmodule
