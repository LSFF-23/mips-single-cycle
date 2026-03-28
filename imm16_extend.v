module imm16_extend (
    input [15:0] imm16,
    input zero_extend,
    output [31:0] imm32
);

reg [31:0] ext;
assign imm32 = ext;
always @* begin
    if (zero_extend)
        ext = {16'b0, imm16};
    else
        ext = {{16{imm16[15]}}, imm16};
end

endmodule