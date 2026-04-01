`timescale 1ns / 1ps

module mips_sc_tb;

    reg clk;
    reg rstn;
    wire [31:0] out_data, out_pc;

    // Instancia o processador
    mips_sc uut (
        .clk(clk),
        .rstn(rstn),
        .out_data(out_data),
        .out_pc(out_pc)
    );

    // Clock de 10ns
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0;
        rstn = 0;

        $display("Iniciando Simulação: Soma de 1 a 10");
        #15 rstn = 1;

        // Aguarda tempo suficiente para as 10 iterações do loop
        // Cada volta no loop faz ~4 instruções. 10 voltas = 40 + setup/end.
        // 800ns é seguro para um Single Cycle a 100MHz.
        #800;

        $display("----------------------------------------------");
        $display("Verificando Resultado Final:");
        
        // O resultado esperado de 1+2...+10 é 55 (0x37 em hexa)
        
        // 1. Verifica no Register File ($t0 é o reg 8)
        if (uut.regfile_inst.regfile[8] === 32'd55) begin
            $display("[SUCESSO] Registrador $t0 (Soma) = %d", uut.regfile_inst.regfile[8]);
        end else begin
            $display("[ERRO] $t0 esperado: 55, obtido: %d", uut.regfile_inst.regfile[8]);
        end

        // 2. Verifica na Data Memory (Endereço 100)
        // Se sua memória for word-addressed (array de 32 bits), index = 100/4 = 25
        if (uut.dmem_inst.dmem[25] === 32'd55) begin
            $display("[SUCESSO] Memoria[100] = %d", uut.dmem_inst.dmem[25]);
        end else begin
            $display("[ERRO] Memoria[100] esperado: 55, obtido: %d", uut.dmem_inst.dmem[25]);
        end

        $display("----------------------------------------------");
        $finish;
    end

    // Monitor para acompanhar a evolução da soma
    always @(posedge clk) begin
        if (rstn && uut.reg_write && uut.write_addr == 5'd8) begin
            $display("Time: %0t | PC: %h | Soma parcial ($t0): %d", $time, uut.cur_pc, uut.write_data);
        end
    end

endmodule