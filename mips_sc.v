module mips_sc (
    input clk, rstn,
    output [31:0] out_data, out_pc
);
wire [31:0] cur_pc;
// pc instance moved down

wire [31:0] instr;
instr_mem imem_inst (cur_pc, instr);

wire [5:0] opcode = instr[31:26];
wire reg_dst;
wire branch;
wire mem_read;
wire mem_write;
wire mem2reg;
wire alu_src;
wire reg_write;
wire [1:0] alu_op;
control_unit mcu_inst (
    .opcode(opcode),
    .reg_dst(reg_dst),
    .branch(branch),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem2reg(mem2reg),
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

wire [2:0] alu_ctrl;
wire [31:0] imm32 = {{16{imm16[15]}}, imm16};
wire [31:0] alu_b = (alu_src) ? imm32 : read_data2;
alu_control aluc_inst (alu_op, funct, alu_ctrl);

wire signed [31:0] r;
wire zero;
alu alu_inst (
    .a(read_data1),
    .b(alu_b),
    .op(alu_ctrl),
    .r(r),
    .zero(zero)
);

wire [31:0] mem_read_data;
assign write_data = (mem2reg) ? mem_read_data : r;
data_mem dmem_inst (
    .clk(clk),
    .rstn(rstn),
    .mem_write(mem_write),
    .mem_read(mem_read),
    .addr(r),
    .write_data(read_data2),
    .read_data(mem_read_data)
);

// branch calculations require later declared wires
wire [31:0] pc_plus4 = cur_pc + 32'h4;
wire [31:0] branch_addr = pc_plus4 + (imm32 << 2);
wire take_branch = branch & zero;
wire is_jump = (opcode == 6'b000010);
wire [31:0] jump_addr = {pc_plus4[31:28], instr[25:0], 2'b00};
wire [31:0] next_pc = (is_jump) ? jump_addr : ((take_branch) ? branch_addr : pc_plus4);
pc pc_inst (clk, rstn, next_pc, cur_pc);

assign out_data = write_data;
assign out_pc = cur_pc;

endmodule