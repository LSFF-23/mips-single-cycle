`timescale 1ns/1ps

module tb_register_file;

    // Sinais
    reg clk;
    reg rstn;
    reg write_enable;
    reg [4:0] read_addr1;
    reg [4:0] read_addr2;
    reg [4:0] write_addr;
    reg [31:0] write_data;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    
    // Instância do módulo
    register_file uut (
        .clk(clk),
        .rstn(rstn),
        .write_enable(write_enable),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    // Gerador de clock
    always #5 clk = ~clk;
    
    // Variáveis
    integer i;
    integer test_passed;
    integer errors;
    
    // Procedimento de verificação
    task check;
        input [31:0] expected1;
        input [31:0] expected2;
        input [31:0] actual1;
        input [31:0] actual2;
        input string test_name;
        begin
            if ((actual1 === expected1) && (actual2 === expected2)) begin
                $display("[PASS] %s: data1=0x%h, data2=0x%h", test_name, actual1, actual2);
            end else begin
                $display("[FAIL] %s: expected data1=0x%h, got 0x%h; expected data2=0x%h, got 0x%h", 
                         test_name, expected1, actual1, expected2, actual2);
                test_passed = 0;
                errors = errors + 1;
            end
        end
    endtask
    
    // Inicialização
    initial begin
        clk = 0;
        rstn = 0;
        write_enable = 0;
        read_addr1 = 0;
        read_addr2 = 0;
        write_addr = 0;
        write_data = 0;
        test_passed = 1;
        errors = 0;
        
        $display("==========================================");
        $display("Iniciando testes do Register File");
        $display("==========================================\n");
        
        // ========== RESET INICIAL ==========
        $display("--- Aplicando reset ---");
        #10;
        rstn = 1;
        #10;
        
        // ========== TESTE 1: Estado após reset ==========
        $display("\n--- Teste 1: Verificando estado após reset (todos zeros) ---");
        for (i = 0; i < 32; i = i + 1) begin
            read_addr1 = i;
            read_addr2 = 0;
            #2;
            check(32'h00000000, 32'h00000000, read_data1, read_data2, 
                  $sformatf("Leitura reg[%0d]", i));
        end
        
        // ========== TESTE 2: Escrita e leitura básica ==========
        $display("\n--- Teste 2: Escrita e leitura de registradores ---");
        
        // Escrita em reg[5]
        @(posedge clk);
        write_addr = 5;
        write_data = 32'h12345678;
        write_enable = 1;
        @(posedge clk);
        write_enable = 0;
        
        read_addr1 = 5;
        read_addr2 = 0;
        #2;
        check(32'h12345678, 32'h00000000, read_data1, read_data2, "Leitura reg[5] e reg[0]");
        
        // Escrita em reg[10]
        @(posedge clk);
        write_addr = 10;
        write_data = 32'hDEADBEEF;
        write_enable = 1;
        @(posedge clk);
        write_enable = 0;
        
        read_addr1 = 5;
        read_addr2 = 10;
        #2;
        check(32'h12345678, 32'hDEADBEEF, read_data1, read_data2, "Leitura reg[5] e reg[10]");
        
        // ========== TESTE 3: $zero permanece zero ==========
        $display("\n--- Teste 3: Verificando que $zero (reg[0]) permanece zero ---");
        
        @(posedge clk);
        write_addr = 0;
        write_data = 32'hFFFFFFFF;
        write_enable = 1;
        @(posedge clk);
        write_enable = 0;
        
        read_addr1 = 0;
        read_addr2 = 0;
        #2;
        check(32'h00000000, 32'h00000000, read_data1, read_data2, "$zero deve ser sempre zero");
        
        // ========== TESTE 4: Forwarding (leitura e escrita no mesmo ciclo) ==========
        $display("\n--- Teste 4: Forwarding - leitura do registrador sendo escrito ---");
        
        @(posedge clk);
        write_addr = 15;
        write_data = 32'hA5A5A5A5;
        write_enable = 1;
        read_addr1 = 15;
        read_addr2 = 5;
        #2;
        // Durante a escrita, deve ler o valor que está sendo escrito
        check(32'hA5A5A5A5, 32'h12345678, read_data1, read_data2, 
              "Forwarding: lendo reg[15] durante escrita");
        
        @(posedge clk);
        write_enable = 0;
        
        // Após a escrita, verifica se o valor foi realmente armazenado
        #2;
        check(32'hA5A5A5A5, 32'h12345678, read_data1, read_data2, 
              "Após escrita: reg[15] deve conter o valor");
        
        // ========== TESTE 5: Sobrescrita de registrador ==========
        $display("\n--- Teste 5: Sobrescrevendo registrador existente ---");
        
        @(posedge clk);
        write_addr = 5;
        write_data = 32'h55555555;
        write_enable = 1;
        @(posedge clk);
        write_enable = 0;
        
        read_addr1 = 5;
        read_addr2 = 0;
        #2;
        check(32'h55555555, 32'h00000000, read_data1, read_data2, "reg[5] sobrescrito");
        
        // ========== TESTE 6: write_enable = 0 (nenhuma escrita) ==========
        $display("\n--- Teste 6: write_enable desativado ---");
        
        @(posedge clk);
        write_addr = 5;
        write_data = 32'h99999999;
        write_enable = 0;
        @(posedge clk);
        
        read_addr1 = 5;
        read_addr2 = 0;
        #2;
        check(32'h55555555, 32'h00000000, read_data1, read_data2, 
              "reg[5] não foi alterado (write_enable=0)");
        
        // ========== TESTE 7: Múltiplos registradores ==========
        $display("\n--- Teste 7: Escrevendo todos os registradores (16 a 31) ---");
        
        for (i = 16; i < 32; i = i + 1) begin
            @(posedge clk);
            write_addr = i;
            write_data = {16'h0000, i[15:0]};
            write_enable = 1;
        end
        @(posedge clk);
        write_enable = 0;
        
        // Verifica todos
        for (i = 16; i < 32; i = i + 1) begin
            read_addr1 = i;
            read_addr2 = 0;
            #2;
            check({16'h0000, i[15:0]}, 32'h00000000, read_data1, read_data2, 
                  $sformatf("Verificando reg[%0d]", i));
        end
        
        // ========== TESTE 8: Verificando independência entre registradores ==========
        $display("\n--- Teste 8: Verificando independência entre registradores ---");
        
        read_addr1 = 5;
        read_addr2 = 10;
        #2;
        check(32'h55555555, 32'hDEADBEEF, read_data1, read_data2, 
              "Leitura independente reg[5] e reg[10]");
        
        // ========== TESTE 9: Ambas as portas lendo mesmo registrador ==========
        $display("\n--- Teste 9: Ambas as portas lendo o mesmo registrador ---");
        
        read_addr1 = 15;
        read_addr2 = 15;
        #2;
        check(32'hA5A5A5A5, 32'hA5A5A5A5, read_data1, read_data2, 
              "Mesmo registrador nas duas portas");
        
        // ========== TESTE 10: Forwarding não deve ocorrer para $zero ==========
        $display("\n--- Teste 10: Forwarding não deve ocorrer para $zero ---");
        
        @(posedge clk);
        write_addr = 0;
        write_data = 32'hFFFFFFFF;
        write_enable = 1;
        read_addr1 = 0;
        read_addr2 = 0;
        #2;
        // Mesmo com escrita ativa, leitura de $zero deve retornar 0
        check(32'h00000000, 32'h00000000, read_data1, read_data2, 
              "$zero não recebe forwarding");
        
        @(posedge clk);
        write_enable = 0;
        
        // ========== TESTE 11: Forwarding simultâneo para ambas as portas ==========
        $display("\n--- Teste 11: Forwarding simultâneo para ambas as portas ---");
        
        @(posedge clk);
        write_addr = 20;
        write_data = 32'hBEEFBEEF;
        write_enable = 1;
        read_addr1 = 20;
        read_addr2 = 20;
        #2;
        check(32'hBEEFBEEF, 32'hBEEFBEEF, read_data1, read_data2, 
              "Forwarding simultâneo para ambas as portas");
        
        @(posedge clk);
        write_enable = 0;
        
        // ========== TESTE 12: Leitura antes e depois da escrita ==========
        $display("\n--- Teste 12: Timing - leitura antes/depois da escrita ---");
        
        read_addr1 = 25;
        read_addr2 = 0;
        #2;
        $display("Antes da escrita: reg[25] = 0x%h", read_data1);
        
        @(posedge clk);
        write_addr = 25;
        write_data = 32'hCAFECAFE;
        write_enable = 1;
        #2;
        $display("Durante a escrita (forwarding): reg[25] = 0x%h", read_data1);
        
        @(posedge clk);
        write_enable = 0;
        #2;
        $display("Após a escrita: reg[25] = 0x%h", read_data1);
        
        // ========== TESTE 13: Reset durante operação ==========
        $display("\n--- Teste 13: Reset durante operação ---");
        
        @(posedge clk);
        write_addr = 30;
        write_data = 32'hDEADDEAD;
        write_enable = 1;
        @(posedge clk);
        write_enable = 0;
        
        read_addr1 = 30;
        read_addr2 = 0;
        #2;
        $display("Antes do reset: reg[30] = 0x%h", read_data1);
        
        #10;
        rstn = 0;
        #10;
        rstn = 1;
        
        read_addr1 = 30;
        read_addr2 = 0;
        #2;
        check(32'h00000000, 32'h00000000, read_data1, read_data2, 
              "Após reset, reg[30] deve ser zero");
        
        // ========== TESTE 14: Estresse com operações aleatórias ==========
        $display("\n--- Teste 14: Estresse - 200 ciclos com operações aleatórias ---");
        
        for (i = 0; i < 200; i = i + 1) begin
            @(posedge clk);
            if (i % 3 == 0) begin
                // Operação de escrita
                write_addr = {$random} % 32;
                write_data = {$random};
                write_enable = 1;
            end else begin
                // Operação de leitura
                read_addr1 = {$random} % 32;
                read_addr2 = {$random} % 32;
                write_enable = 0;
            end
        end
        $display("Estresse concluído");
        
        // ========== RELATÓRIO FINAL ==========
        $display("\n==========================================");
        if (test_passed) begin
            $display("RESULTADO: TODOS OS TESTES PASSARAM!");
        end else begin
            $display("RESULTADO: %0d TESTE(S) FALHOU(ARAM) - Verifique as mensagens acima", errors);
        end
        $display("==========================================");
        
        #50;
        $finish;
    end
    
    // Monitoramento opcional
    always @(posedge clk) begin
        if (write_enable && write_addr != 0) begin
            $display("[MONITOR] Ciclo %0t: Escrita em reg[%0d] <= 0x%h", 
                     $time, write_addr, write_data);
        end
    end
    
endmodule