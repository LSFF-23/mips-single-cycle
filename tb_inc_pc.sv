`timescale 1ns/1ps

module tb_inc_pc;

    // Sinais
    reg [31:0] cur_pc;
    wire [31:0] next_pc;
    
    // Instância do módulo
    inc_pc uut (
        .cur_pc(cur_pc),
        .next_pc(next_pc)
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
                $display("[PASS] %s: cur_pc=0x%h, next_pc=0x%h", test_name, cur_pc, actual);
            end else begin
                $display("[FAIL] %s: cur_pc=0x%h, expected next_pc=0x%h, got 0x%h", 
                         test_name, cur_pc, expected, actual);
                test_passed = 0;
                errors = errors + 1;
            end
        end
    endtask
    
    // Inicialização
    initial begin
        cur_pc = 0;
        test_passed = 1;
        errors = 0;
        
        $display("==========================================");
        $display("Iniciando testes do Incrementador de PC");
        $display("==========================================\n");
        
        // ========== TESTE 1: PC = 0 ==========
        $display("--- Teste 1: PC = 0 ---");
        cur_pc = 32'h00000000;
        #10;
        check(32'h00000004, next_pc, "PC = 0");
        
        // ========== TESTE 2: PC = 4 ==========
        $display("\n--- Teste 2: PC = 4 ---");
        cur_pc = 32'h00000004;
        #10;
        check(32'h00000008, next_pc, "PC = 4");
        
        // ========== TESTE 3: PC = 8 ==========
        $display("\n--- Teste 3: PC = 8 ---");
        cur_pc = 32'h00000008;
        #10;
        check(32'h0000000C, next_pc, "PC = 8");
        
        // ========== TESTE 4: PC = 0x00400000 (endereço típico) ==========
        $display("\n--- Teste 4: PC = 0x00400000 ---");
        cur_pc = 32'h00400000;
        #10;
        check(32'h00400004, next_pc, "PC = 0x00400000");
        
        // ========== TESTE 5: PC = 0x00400004 ==========
        $display("\n--- Teste 5: PC = 0x00400004 ---");
        cur_pc = 32'h00400004;
        #10;
        check(32'h00400008, next_pc, "PC = 0x00400004");
        
        // ========== TESTE 6: PC = 0xFFFFFFFC (próximo ao limite) ==========
        $display("\n--- Teste 6: PC = 0xFFFFFFFC ---");
        cur_pc = 32'hFFFFFFFC;
        #10;
        check(32'h00000000, next_pc, "PC = 0xFFFFFFFC (overflow)");
        
        // ========== TESTE 7: PC = 0xFFFFFFF8 ==========
        $display("\n--- Teste 7: PC = 0xFFFFFFF8 ---");
        cur_pc = 32'hFFFFFFF8;
        #10;
        check(32'hFFFFFFFC, next_pc, "PC = 0xFFFFFFF8");
        
        // ========== TESTE 8: PC = 0x0000FFFC ==========
        $display("\n--- Teste 8: PC = 0x0000FFFC ---");
        cur_pc = 32'h0000FFFC;
        #10;
        check(32'h00010000, next_pc, "PC = 0x0000FFFC");
        
        // ========== TESTE 9: PC = 0xFFFFFFFF ==========
        $display("\n--- Teste 9: PC = 0xFFFFFFFF ---");
        cur_pc = 32'hFFFFFFFF;
        #10;
        check(32'h00000003, next_pc, "PC = 0xFFFFFFFF (overflow)");
        
        // ========== TESTE 10: Alteração rápida de valores ==========
        $display("\n--- Teste 10: Alteração rápida de valores ---");
        cur_pc = 32'h00000000;
        #5;
        $display("PC = 0x%h, next = 0x%h", cur_pc, next_pc);
        
        cur_pc = 32'h10000000;
        #5;
        $display("PC = 0x%h, next = 0x%h", cur_pc, next_pc);
        
        cur_pc = 32'h20000000;
        #5;
        $display("PC = 0x%h, next = 0x%h", cur_pc, next_pc);
        $display("[PASS] Alterações rápidas funcionaram");
        
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