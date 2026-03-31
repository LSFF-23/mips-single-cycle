module mips_sc (input clk, rstn);
wire [31:0] cur_pc;
wire [31:0] next_pc = cur_pc + 32'h4;
pc pc_inst (clk, rstn, next_pc, cur_pc);

wire [31:0] instr;
instr_mem imem_inst (cur_pc, instr);

wire [5:0] opcode = instr[31:26];
wire reg_dst;
wire branch;
wire mem_read;
wire mem_write;
wire load_mem;
wire alu_src;
wire reg_write;
wire [1:0] alu_op;
control_unit mcu_inst (
    .opcode(opcode),
    .reg_dst(reg_dst),
    .branch(branch),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .load_mem(load_mem),
    .alu_src(alu_src),
    .reg_write(reg_write),
    .alu_op(alu_op)
);

wire [4:0] rs = instr[25:21];
wire [4:0] rt = instr[20:16];
wire [4:0] rd = instr[15:11];
wire [5:0] funct = instr[5:0];
wire [15:0] imm16 = instr[15:0];
wire [4:0] write_addr = (reg_dst) ? rd : rt;
wire [31:0] write_data, read_data1, read_data2;
assign write_data = 32'b0;
register_file regfile_inst (
    .clk(clk),
    .rstn(rstn),
    .write_enable(reg_write),
    .read_addr1(rs), 
    .read_addr2(rt), 
    .write_addr(write_addr),
    .write_data(write_data), 
    .read_data1(read_data1), 
    .read_data2(read_data2)
);



endmodule