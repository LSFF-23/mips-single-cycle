module alu_control (
    input [1:0] alu_op,
    input [5:0] funct,
    output [2:0] alu_ctrl
);

reg [2:0] ctrl_signal;
assign alu_ctrl = ctrl_signal;
always @* begin
    case (alu_op)
        2'b00: ctrl_signal = 3'b010;
        2'b01: ctrl_signal = 3'b011;
        2'b10: begin
            case (funct)
                6'b100000: ctrl_signal = 3'b010;
                6'b100010: ctrl_signal = 3'b011;
                6'b100100: ctrl_signal = 3'b000;
                6'b100101: ctrl_signal = 3'b001;
                6'b100110: ctrl_signal = 3'b110;
                6'b101010: ctrl_signal = 3'b100;
                6'b100111: ctrl_signal = 3'b101;
                default: ctrl_signal = 3'bx;
            endcase
        end
        default: ctrl_signal = 3'bx;
    endcase
end

endmodule