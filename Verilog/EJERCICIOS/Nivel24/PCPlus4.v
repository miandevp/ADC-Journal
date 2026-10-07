module PCPlus4(
    input  [31:0] pc,
    output [31:0] pcnext
);

    assign pcnext = pc + 32'd4;

endmodule