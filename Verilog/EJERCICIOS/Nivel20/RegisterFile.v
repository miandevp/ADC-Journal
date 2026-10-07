module RegisterFile(
    input  [4:0] rs1,
    input  [4:0] rs2,
    input  [4:0] rd,
    input  [31:0] y,

    output [31:0] a,
    output [31:0] b
);

    // 32 registros de 32 bits
    reg [31:0] rf [31:0];

    integer i;

    // Inicializar todos los registros en 0
    initial begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] = 32'd0;
    end

    // Lectura de dos puertos
    assign a = rf[rs1];
    assign b = rf[rs2];

    // Escritura inmediata (sin clk)
    always @(*) begin
        if (rd != 0)
            rf[rd] = y;
    end

endmodule