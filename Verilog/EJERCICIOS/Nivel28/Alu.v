module Alu(
    input [31:0] a,
    input [31:0] b,
    input [2:0] sel,
    output reg [31:0] y,
    output zero,
    output overflow
);


wire [31:0] condinvb;
wire [31:0] sum;
wire isSub;
wire v;

assign isSub = (sel == 3'b001 || sel == 3'b100);
assign condinvb = isSub ? ~b : b;
assign sum = a + condinvb + isSub;

always @(*) begin
   case(sel)
        3'b000: y = sum;
        3'b001: y = sum;
        3'b010: y = a & b;
        3'b011: y = a | b;
        3'b100: 
            if(sum[31] ^ overflow)
                y = 32'd1;
            else
                y = 32'd0;               
        3'b101: y = a ^ b;
        3'b110: y = a << b[4:0];
        3'b111: y = a >> b[4:0];       
   endcase    
end

assign zero = (y == 0);




assign v =
    ~(isSub ^ a[31] ^ b[31]) &
    (a[31] ^ sum[31]);
    
assign overflow = v;

endmodule