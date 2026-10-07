module AluDecoder(
    input [1:0] AluOp,
    input [2:0] funct3,
    input [6:0] funct7b5,
    output reg [2:0] AluControl
);

always @(*) begin
    case(AluOp)
        2'b00: 
            AluControl = 3'b000;
        2'b01:
            AluControl = 3'b001;
        2'b10:   case (funct3)  
                        3'b000: begin
                            if (funct7b5 == 7'b0100000)
                                AluControl = 3'b001; // SUB
                            else
                                AluControl = 3'b000; // ADD
                        end
                
                        3'b010:
                            AluControl = 3'b100; // SLT
                
                        3'b011:
                            AluControl = 3'b011; // OR
                
                        3'b111:
                            AluControl = 3'b010; // AND
                
                        3'b100:
                            AluControl = 3'b101; // XOR
                
                        3'b001:
                            AluControl = 3'b110; // SLL
                
                        3'b101:
                            AluControl = 3'b111; // SRL
                
                        default:
                            AluControl = 3'bxxx;
                
            endcase 
    endcase
end

endmodule