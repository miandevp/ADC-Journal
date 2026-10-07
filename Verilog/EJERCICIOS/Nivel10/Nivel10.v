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
wire v_add;
wire v_sub;


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
            if(sum[31])
                y = 32'd1;
            else
                y = 32'd0;
   endcase    
end

assign zero = (y == 0);
assign v_add =
    ((a[31] == 0) && (b[31] == 0) && (sum[31] == 1)) ||
    ((a[31] == 1) && (b[31] == 1) && (sum[31] == 0));
assign v_sub =
    ((a[31] == 0) && (b[31] == 1) && (sum[31] == 1)) ||
    ((a[31] == 1) && (b[31] == 0) && (sum[31] == 0));

assign v =
    (sel == 3'b000) ? v_add :
    (sel == 3'b001 || sel == 3'b100) ? v_sub :
    1'b0;    
    
assign overflow = v;

endmodule