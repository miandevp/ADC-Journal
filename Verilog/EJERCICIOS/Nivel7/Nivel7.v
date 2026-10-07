module Alu(
    input [31:0] a,
    input [31:0] b,
    input [2:0] sel,
    output reg [31:0] y,
    output zero
);


wire [31:0] condinvb;
wire [31:0] sum;

assign condinvb = (sel == 3'b001) ? ~b : b;
assign sum = a + condinvb + (sel == 3'b001);

always @(*) begin
   case(sel)
        3'b000: y = sum;
        3'b001: y = sum;
        3'b010: y = a & b;
        3'b011: y = a | b;
        3'b100: 
            if(a<b)
                y = 32'd1;
            else
                y = 32'd0;
   endcase    
end

assign zero = (y == 0);

endmodule