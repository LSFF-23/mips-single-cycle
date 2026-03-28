module instr_mem (
    input [31:0] addr,
    output [31:0] instr
);

reg [31:0] imem [31:0];
assign instr = imem[addr[6:2]];

initial begin
    $readmemh("program.hex", imem);
end

endmodule