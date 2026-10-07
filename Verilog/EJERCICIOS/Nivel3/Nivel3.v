module Alu(
    input [31:0] a,
    input [31:0] b,
    input [1:0] sel,
    output reg [31:0] y
);

always @(*) begin
   if(sel == 2'b00 ) 
        y = a + b;
   else if( sel == 2'b01)
        y = a - b;
   else if( sel == 2'b10)
        y = a | b;
   else 
        y = a & b;    
end

endmodule