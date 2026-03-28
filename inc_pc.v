module inc_pc (
    input  [31:0] cur_pc,
    output [31:0] next_pc
);

assign next_pc = cur_pc + 32'h4;

endmodule