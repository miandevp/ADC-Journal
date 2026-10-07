module Alu(
    input [31:0] a,
    input [31:0] b,
    input sel,
    output reg [31:0] y
);

always @(*) begin 
    if(sel)
        y = a - b;
    else
        y = a + b;
end 

endmodule