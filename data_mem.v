module data_mem (
    input clk,
    input rstn,
    input mem_write,
    input mem_read,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [31:0] dmem [31:0];

assign read_data = (mem_read) ? dmem[addr[6:2]] : 32'b0;

integer i;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i < 32; i = i + 1)
            dmem[i] <= 32'b0;
    end else begin
        if (mem_write)
            dmem[addr[6:2]] <= write_data;
    end
end

endmodule