

module MainDecoder(
        input [6:0] opcode,
        output reg [1:0] AluOp
    );
    
    always @(*) begin
        case(opcode)
        //R-type
           7'b0110011: AluOp = 2'b10;
        //I-type
           7'b0010011: AluOp = 2'b10;
           
           default:   AluOp = 2'bxx;
         endcase
    end
    
endmodule
