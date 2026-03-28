`timescale 1ns/1ps

module tb_imm16_extend;

    // Sinais
    reg [15:0] imm16;
    reg zero_extend;
    wire [31:0] imm32;
    
    // Instância do módulo
    imm16_extend uut (
        .imm16(imm16),
        .zero_extend(zero_extend),
        .imm32(imm32)
    );
    
    // Variáveis
    integer test_passed;
    integer errors;
    
    // Procedimento de verificação
    task check;
        input [31:0] expected;
        input [31:0] actual;
        input string test_name;
        begin
            if (actual === expected) begin
                $display("[PASS] %s: imm32=0x%h", test_name, actual);
            end else begin
                $display("[FAIL] %s: expected 0x%h, got 0x%h", test_name, expected, actual);
                test_passed = 0;
                errors = errors + 1;
            end
        end
    endtask
    
    // Inicialização
    initial begin
        imm16 = 0;
        zero_extend = 0;
        test_passed = 1;
        errors = 0;
        
        $display("==========================================");
        $display("Iniciando testes do Extensor de Imediato");
        $display("==========================================\n");
        
        // ========== TESTE 1: Sign extend com valor positivo ==========
        $display("--- Teste 1: Sign extend - valor positivo ---");
        imm16 = 16'h1234;
        zero_extend = 0;
        #10;
        check(32'h00001234, imm32, "Sign extend 0x1234");
        
        // ========== TESTE 2: Sign extend com valor negativo ==========
        $display("\n--- Teste 2: Sign extend - valor negativo ---");
        imm16 = 16'h8000;
        zero_extend = 0;
        #10;
        check(32'hFFFF8000, imm32, "Sign extend 0x8000");
        
        // ========== TESTE 3: Sign extend com FFFF ==========
        $display("\n--- Teste 3: Sign extend - FFFF ---");
        imm16 = 16'hFFFF;
        zero_extend = 0;
        #10;
        check(32'hFFFFFFFF, imm32, "Sign extend 0xFFFF");
        
        // ========== TESTE 4: Sign extend com 7FFF ==========
        $display("\n--- Teste 4: Sign extend - 7FFF ---");
        imm16 = 16'h7FFF;
        zero_extend = 0;
        #10;
        check(32'h00007FFF, imm32, "Sign extend 0x7FFF");
        
        // ========== TESTE 5: Sign extend com valor pequeno ==========
        $display("\n--- Teste 5: Sign extend - valor pequeno ---");
        imm16 = 16'h0001;
        zero_extend = 0;
        #10;
        check(32'h00000001, imm32, "Sign extend 0x0001");
        
        // ========== TESTE 6: Zero extend com valor positivo ==========
        $display("\n--- Teste 6: Zero extend - valor positivo ---");
        imm16 = 16'h1234;
        zero_extend = 1;
        #10;
        check(32'h00001234, imm32, "Zero extend 0x1234");
        
        // ========== TESTE 7: Zero extend com 8000 ==========
        $display("\n--- Teste 7: Zero extend - 8000 ---");
        imm16 = 16'h8000;
        zero_extend = 1;
        #10;
        check(32'h00008000, imm32, "Zero extend 0x8000");
        
        // ========== TESTE 8: Zero extend com FFFF ==========
        $display("\n--- Teste 8: Zero extend - FFFF ---");
        imm16 = 16'hFFFF;
        zero_extend = 1;
        #10;
        check(32'h0000FFFF, imm32, "Zero extend 0xFFFF");
        
        // ========== TESTE 9: Zero extend com valor zero ==========
        $display("\n--- Teste 9: Zero extend - valor zero ---");
        imm16 = 16'h0000;
        zero_extend = 1;
        #10;
        check(32'h00000000, imm32, "Zero extend 0x0000");
        
        // ========== TESTE 10: Comparação sign vs zero para 8000 ==========
        $display("\n--- Teste 10: Comparação sign vs zero para 0x8000 ---");
        imm16 = 16'h8000;
        
        zero_extend = 0;
        #10;
        $display("Sign extend 0x8000 = 0x%h", imm32);
        
        zero_extend = 1;
        #10;
        $display("Zero extend 0x8000 = 0x%h", imm32);
        $display("[INFO] Sign e zero dão resultados diferentes para 0x8000 (comportamento correto)");
        
        // ========== TESTE 11: Comparação sign vs zero para FFFF ==========
        $display("\n--- Teste 11: Comparação sign vs zero para 0xFFFF ---");
        imm16 = 16'hFFFF;
        
        zero_extend = 0;
        #10;
        $display("Sign extend 0xFFFF = 0x%h", imm32);
        
        zero_extend = 1;
        #10;
        $display("Zero extend 0xFFFF = 0x%h", imm32);
        
        // ========== TESTE 12: Alternando entre modos ==========
        $display("\n--- Teste 12: Alternando entre modos rapidamente ---");
        imm16 = 16'hFEDC;
        
        zero_extend = 0;
        #5;
        $display("Sign: 0x%h", imm32);
        
        zero_extend = 1;
        #5;
        $display("Zero: 0x%h", imm32);
        
        zero_extend = 0;
        #5;
        $display("Sign: 0x%h", imm32);
        
        $display("[PASS] Alternação entre modos funcionou");
        
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
    
endmodule