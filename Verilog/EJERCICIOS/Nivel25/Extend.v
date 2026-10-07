
module Extend(
    input [11:0] imm,
    output [31:0] immext
    );
    
assign immext = {{20{imm[11]}},imm};

endmodule
