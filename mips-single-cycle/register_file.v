module register_file (
    input clk,
    input rstn,
    input write_enable,
    input [4:0] read_addr1, read_addr2, write_addr,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
);

reg [31:0] regfile [31:0];

wire rd1_forward = write_enable && (write_addr != 5'b0) && (read_addr1 == write_addr);
wire rd2_forward = write_enable && (write_addr != 5'b0) && (read_addr2 == write_addr);
assign read_data1 = rd1_forward ? write_data : regfile[read_addr1];
assign read_data2 = rd2_forward ? write_data : regfile[read_addr2];

integer i;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i < 32; i = i + 1)
            regfile[i] <= 32'b0;
    end else begin
        if (write_enable && (write_addr != 5'b0))
            regfile[write_addr] <= write_data;
    end
end

endmodule