module alu (
    input signed [31:0] a,
    input signed [31:0] b,
    input [2:0]  op,
    output signed [31:0] r,
    output zero
);

assign zero = (r == 0); 

reg signed [31:0] result;
assign r = result;
always @* begin
    case (op)
        3'b000: result = a & b;
        3'b001: result = a | b;
        3'b010: result = a + b;
        3'b011: result = a - b;
        3'b100: result = (a < b) ? 32'b1 : 32'b0;
        3'b101: result = ~(a | b);
        3'b110: result = a ^ b;
        default: result = 32'bx;
    endcase
end

endmodule