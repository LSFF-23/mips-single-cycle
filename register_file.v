module register_file (
    input clk,
    input rstn,
    input write_enable,
    input [4:0] read_addr1, read_addr2, write_addr,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
);
reg [31:0] regfile [31:0];
integer i;

assign read_data1 = (read_addr1 == 5'b0) ? 32'b0 : regfile[read_addr1];
assign read_data2 = (read_addr2 == 5'b0) ? 32'b0 : regfile[read_addr2];

always @(posedge clk or negedge rstn) begin
	i = 32'bx;
    if (!rstn) begin
        for (i = 0; i < 32; i = i + 1) regfile[i] <= 32'b0;
    end else if (write_enable && (write_addr != 5'b0)) begin
        regfile[write_addr] <= write_data;
    end
end

endmodule