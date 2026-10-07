module RegisterFile(
    input clk,
    input we,

    input  [4:0] rs1,
    input  [4:0] rs2,
    input  [4:0] rd,
    input  [31:0] y,

    output [31:0] a,
    output [31:0] b
);

    reg [31:0] RF [31:0];

    initial begin
        $readmemh("registers.mem", RF);
    end

    // Lectura combinacional
    assign a = RF[rs1];
    assign b = RF[rs2];

    // Escritura secuencial
    always @(posedge clk) begin
        if (we && rd != 0)
            RF[rd] <= y;

        // x0 siempre es 0
        RF[0] <= 32'd0;
    end

endmodule