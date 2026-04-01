module control_unit (
    input [5:0] opcode,
    output reg_dst,
    output branch,
    output mem_read,
    output mem_write,
    output mem2reg,
    output alu_src,
    output reg_write,
    output [1:0] alu_op
);

reg [8:0] control_bus;
assign reg_dst = control_bus[8];
assign branch = control_bus[7];
assign mem_read = control_bus[6];
assign mem_write = control_bus[5];
assign mem2reg = control_bus[4];
assign alu_src = control_bus[3];
assign reg_write = control_bus[2];
assign alu_op = control_bus[1:0];

always @* begin
    case (opcode)
        6'b000000: control_bus = 9'b100000110;
        6'b001000: control_bus = 9'b000001100;
        6'b100011: control_bus = 9'b001011100;
        6'b101011: control_bus = 9'b000101000;
        6'b000100: control_bus = 9'b010000001;
        default: control_bus = 9'bx;
    endcase
end

endmodule