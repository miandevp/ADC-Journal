module AluDecoder(
    input [1:0] AluOp,
    input [2:0] funct3,
    input funct7b5,
    input opb5,
    output reg [2:0] AluControl
);

wire RtypeSub;

assign RtypeSub = funct7b5 & opb5;

always @(*) begin
    case (AluOp)

        // lw, sw
        2'b00:
            AluControl = 3'b000;   // ADD

        // beq
        2'b01:
            AluControl = 3'b001;   // SUB

        // instrucciones R/I
        2'b10:
            case (funct3)

                3'b000:
                    if (RtypeSub)
                        AluControl = 3'b001;   // SUB
                    else
                        AluControl = 3'b000;   // ADD / ADDI

                3'b010:
                    AluControl = 3'b100;       // SLT / SLTI

                3'b011:
                    AluControl = 3'b011;       // OR

                3'b111:
                    AluControl = 3'b010;       // AND

                3'b100:
                    AluControl = 3'b101;       // XOR

                3'b001:
                    AluControl = 3'b110;       // SLL

                3'b101:
                    AluControl = 3'b111;       // SRL

                default:
                    AluControl = 3'bxxx;

            endcase

        default:
            AluControl = 3'bxxx;

    endcase
end

endmodule