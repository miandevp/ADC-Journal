module RegisterFile(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,      // todavía no se usa
    input [31:0] y,      // todavía no se usa

    output reg [31:0] a,
    output reg [31:0] b
);
reg [31:0] x1;
reg [31:0] x2;

// inciamos 2 registros
// x1 = 5
// x2 = 6
initial begin
    x1 = 32'd5;
    x2 = 32'd6;
end

// dependiendo de lo que venga si viene
// x1 en rs1 entonces a = x1
// x2 en rs1 entonces a = x2
// x1 en rs2 entonces a = x1
// x2 en rs2 entonces a = x2

always @(*) begin

    case(rs1)
        5'd1: a = x1;
        5'd2: a = x2;
        default: a = 32'd0;
    endcase

    case(rs2)
        5'd1: b = x1;
        5'd2: b = x2;
        default: b = 32'd0;
    endcase

end

endmodule