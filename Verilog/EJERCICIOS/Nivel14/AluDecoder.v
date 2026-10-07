
module AluDecoder(
    input [2:0] funct3,
    output reg [2:0] AluControl

    );
    
    
    always @(*)begin
        case(funct3)
                3'b000: AluControl = 3'b000; // ADD
                3'b001: AluControl = 3'b001; // SUB
                3'b010: AluControl = 3'b010; // AND
                3'b011: AluControl = 3'b011; // OR
                3'b100: AluControl = 3'b100; // SLT
                3'b101: AluControl = 3'b101; // XOR
                3'b110: AluControl = 3'b110; // SLL
                3'b111: AluControl = 3'b111; // SRL
        endcase
    end
endmodule
