module Alu(
    input [31:0] a,
    input [31:0] b,
    input [1:0] sel,
    output reg [31:0] y
);

always @(*) begin
   case(sel)
        2'b00: y = a + b;
        2'b01: y = a - b;
        2'b10: y = a & b;
        2'b11: y = a | b;
   endcase    
end

endmodule