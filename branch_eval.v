module branch_eval (
    input  [31:0] next_pc,
    input  [31:0] imm_shifted,
    output [31:0] branch_addr
);

assign branch_addr = imm_shifted + next_pc;

endmodule