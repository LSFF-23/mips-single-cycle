module sl2 (
    input  [31:0] imm32,
    output [31:0] imm_shifted
);

assign imm_shifted = imm32 << 2;

endmodule