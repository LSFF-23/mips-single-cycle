module mips_sc (input clk, rstn);

wire [31:0] cur_pc;
wire [31:0] next_pc = cur_pc + 32'h4;
pc pc_inst (clk, rstn, next_pc, cur_pc);

wire [31:0] instr;
instr_mem imem_instr (cur_pc, instr);

endmodule