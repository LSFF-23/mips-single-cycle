module pc (
    input clk,
    input rstn,
    input [31:0] next_pc,
    output [31:0] cur_pc
);

reg [31:0] pc_reg;
assign cur_pc = pc_reg;

always @(posedge clk or negedge rstn) begin
    if (!rstn)
        pc_reg <= 32'h00400000; // load from file later?
    else
        pc_reg <= next_pc;
end

endmodule