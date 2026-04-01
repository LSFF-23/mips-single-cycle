`timescale 1ns / 1ps

module mips_sc_tb;

    // Sinais do Testbench
    reg clk;
    reg rstn;

    // Instancia o processador
    mips_sc uut (
        .clk(clk),
        .rstn(rstn)
    );

    // Geração do Clock (período de 10ns)
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0;
        rstn = 0;

        // Reset do sistema
        $display("Iniciando Simulação...");
        #15 rstn = 1;

        // Aguarda a execução de algumas instruções
        // Como o programa tem ~18 instruções, 200ns é suficiente para um Single Cycle
        #250;

        // --- VERIFICAÇÃO DOS RESULTADOS ---
        
        $display("----------------------------------------------");
        $display("Verificando resultados finais na Data Memory:");
        
        // Verificação do endereço 80 (0x50) - Esperado: 7
        if (uut.dmem_inst.dmem[20] === 32'd7) begin // 80/4 = index 20 se for word-addressed
            $display("[SUCESSO] Memoria[80] = %d", uut.dmem_inst.dmem[20]);
        end else begin
            $display("[ERRO] Memoria[80] esperado: 7, obtido: %d", uut.dmem_inst.dmem[20]);
        end

        // Verificação do endereço 84 (0x54) - Esperado: 7
        if (uut.dmem_inst.dmem[21] === 32'd7) begin // 84/4 = index 21
            $display("[SUCESSO] Memoria[84] = %d", uut.dmem_inst.dmem[21]);
        end else begin
            $display("[ERRO] Memoria[84] esperado: 7, obtido: %d", uut.dmem_inst.dmem[21]);
        end

        $display("----------------------------------------------");
        $display("Verificando Registradores Finais:");
        $display("$v0 (reg 2)  = %d (Esperado: 7)", uut.regfile_inst.regfile[2]);
        $display("$v1 (reg 3)  = %d (Esperado: 12)", uut.regfile_inst.regfile[3]);
        $display("$a1 (reg 5)  = %d (Esperado: 11)", uut.regfile_inst.regfile[5]);
        $display("$a3 (reg 7)  = %d (Esperado: 7)", uut.regfile_inst.regfile[7]);
        
        $finish;
    end

    // Opcional: Monitor de Instruções
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time: %0t | PC: %h | Instr: %h", $time, uut.cur_pc, uut.instr);
        end
    end

endmodule