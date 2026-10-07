`timescale 1ns / 1ps

module testbench_Alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0]funct3;
    reg [6:0] funct7b5;
    reg [1:0] AluOp;   
    wire [31:0] y;
    wire zero;
    wire overflow;
    
    MiniDatapath MD (
        .a(a),
        .b(b),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .AluOp(AluOp),
        .y(y),
        .zero(zero),
        .overflow(overflow)
    );

    initial begin
     a=5;
     b=6;
     AluOp=0;
     funct3=0;
     funct7b5 = 0;   //  suma
     #10
     
     a=6;
     b=5;
     AluOp=1;
     funct3=0;
     funct7b5 = 32; // resta
     #10
    
     $finish;
    end
endmodule
