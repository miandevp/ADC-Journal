module Alu(
    input [31:0] a,
    input [31:0] b,
    input [1:0] sel,
    output reg [31:0] y,
    output zero
);


wire [31:0] condinvb;
wire [31:0] sum;

assign condinvb = (sel == 2'b01) ? ~b : b;
assign sum = a + condinvb + (sel == 2'b01);

always @(*) begin
   case(sel)
        2'b00: y = sum;
        2'b01: y = sum;
        2'b10: y = a & b;
        2'b11: y = a | b;
   endcase    
end

assign zero = (y == 0);

endmodule