module InstructionMemory(
    input  [31:0] pc,
    output [31:0] instr
);

    // 64 palabras de 32 bits
    reg [31:0] RAM [63:0];

    initial begin
        // Programa almacenado en hexadecimal
        $readmemh("instructions.mem", RAM);
    end

    // Acceso alineado a palabra
    assign instr = RAM[pc[31:2]];

endmodule