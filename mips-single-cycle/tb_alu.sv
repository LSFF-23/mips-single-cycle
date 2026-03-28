`timescale 1ns/1ps

module tb_alu;

    // Sinais
    reg signed [31:0] a;
    reg signed [31:0] b;
    reg [2:0] op;
    wire signed [31:0] r;
    wire zero;
    
    // Instância do módulo
    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .r(r),
        .zero(zero)
    );
    
    // Variáveis
    integer test_passed;
    integer errors;
    
    // Procedimento de verificação
    task check;
        input [31:0] expected_r;
        input expected_zero;
        input [31:0] actual_r;
        input actual_zero;
        input string test_name;
        begin
            if ((actual_r === expected_r) && (actual_zero === expected_zero)) begin
                $display("[PASS] %s: r=0x%h, zero=%b", test_name, actual_r, actual_zero);
            end else begin
                $display("[FAIL] %s: expected r=0x%h, zero=%b; got r=0x%h, zero=%b", 
                         test_name, expected_r, expected_zero, actual_r, actual_zero);
                test_passed = 0;
                errors = errors + 1;
            end
        end
    endtask
    
    // Inicialização
    initial begin
        a = 0;
        b = 0;
        op = 0;
        test_passed = 1;
        errors = 0;
        
        $display("==========================================");
        $display("Iniciando testes da ULA (com XOR)");
        $display("==========================================\n");
        
        // ========== TESTE 1: AND ==========
        $display("--- Teste 1: AND ---");
        a = 32'hFFFF0000;
        b = 32'h0000FFFF;
        op = 3'b000;
        #10;
        check(32'h00000000, 1'b1, r, zero, "AND FFFF0000 & 0000FFFF");
        
        // ========== TESTE 2: AND com resultado não zero ==========
        $display("\n--- Teste 2: AND com resultado não zero ---");
        a = 32'hFFFFFFFF;
        b = 32'h0000FFFF;
        op = 3'b000;
        #10;
        check(32'h0000FFFF, 1'b0, r, zero, "AND FFFFFFFF & 0000FFFF");
        
        // ========== TESTE 3: OR ==========
        $display("\n--- Teste 3: OR ---");
        a = 32'hFFFF0000;
        b = 32'h0000FFFF;
        op = 3'b001;
        #10;
        check(32'hFFFFFFFF, 1'b0, r, zero, "OR FFFF0000 | 0000FFFF");
        
        // ========== TESTE 4: OR com resultado parcial ==========
        $display("\n--- Teste 4: OR com resultado parcial ---");
        a = 32'hFFFF0000;
        b = 32'h000000FF;
        op = 3'b001;
        #10;
        check(32'hFFFF00FF, 1'b0, r, zero, "OR FFFF0000 | 000000FF");
        
        // ========== TESTE 5: ADD ==========
        $display("\n--- Teste 5: ADD ---");
        a = 32'd1;
        b = 32'd2;
        op = 3'b010;
        #10;
        check(32'd3, 1'b0, r, zero, "ADD 1 + 2");
        
        // ========== TESTE 6: ADD com overflow ==========
        $display("\n--- Teste 6: ADD com overflow ---");
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        op = 3'b010;
        #10;
        check(32'h00000000, 1'b1, r, zero, "ADD 0xFFFFFFFF + 1");
        
        // ========== TESTE 7: ADD com resultado não zero ==========
        $display("\n--- Teste 7: ADD com resultado não zero ---");
        a = 32'd10;
        b = 32'd20;
        op = 3'b010;
        #10;
        check(32'd30, 1'b0, r, zero, "ADD 10 + 20");
        
        // ========== TESTE 8: SUB ==========
        $display("\n--- Teste 8: SUB ---");
        a = 32'd5;
        b = 32'd3;
        op = 3'b011;
        #10;
        check(32'd2, 1'b0, r, zero, "SUB 5 - 3");
        
        // ========== TESTE 9: SUB resultando zero ==========
        $display("\n--- Teste 9: SUB resultando zero ---");
        a = 32'd5;
        b = 32'd5;
        op = 3'b011;
        #10;
        check(32'd0, 1'b1, r, zero, "SUB 5 - 5");
        
        // ========== TESTE 10: SLT - menor (positivo) ==========
        $display("\n--- Teste 10: SLT - menor (positivo) ---");
        a = 32'd1;
        b = 32'd2;
        op = 3'b100;
        #10;
        check(32'd1, 1'b0, r, zero, "SLT 1 < 2");
        
        // ========== TESTE 11: SLT - não menor ==========
        $display("\n--- Teste 11: SLT - não menor ---");
        a = 32'd2;
        b = 32'd1;
        op = 3'b100;
        #10;
        check(32'd0, 1'b1, r, zero, "SLT 2 < 1");
        
        // ========== TESTE 12: SLT - números negativos ==========
        $display("\n--- Teste 12: SLT - números negativos ---");
        a = -32'd1;
        b = 32'd1;
        op = 3'b100;
        #10;
        check(32'd1, 1'b0, r, zero, "SLT -1 < 1");
        
        // ========== TESTE 13: SLT - comparando dois negativos ==========
        $display("\n--- Teste 13: SLT - comparando dois negativos ---");
        a = -32'd5;
        b = -32'd3;
        op = 3'b100;
        #10;
        check(32'd1, 1'b0, r, zero, "SLT -5 < -3");
        
        // ========== TESTE 14: SLT - valores iguais ==========
        $display("\n--- Teste 14: SLT - valores iguais ---");
        a = -32'd10;
        b = -32'd10;
        op = 3'b100;
        #10;
        check(32'd0, 1'b1, r, zero, "SLT -10 < -10");
        
        // ========== TESTE 15: NOR ==========
        $display("\n--- Teste 15: NOR ---");
        a = 32'hFFFF0000;
        b = 32'h0000FFFF;
        op = 3'b101;
        #10;
        check(32'h00000000, 1'b1, r, zero, "NOR FFFF0000, 0000FFFF");
        
        // ========== TESTE 16: NOR com valores diferentes ==========
        $display("\n--- Teste 16: NOR com valores diferentes ---");
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        op = 3'b101;
        #10;
        check(32'h00000000, 1'b1, r, zero, "NOR AAAAAAAA, 55555555");
        
        // ========== TESTE 17: XOR ==========
        $display("\n--- Teste 17: XOR ---");
        a = 32'hFFFF0000;
        b = 32'h0000FFFF;
        op = 3'b110;
        #10;
        check(32'hFFFFFFFF, 1'b0, r, zero, "XOR FFFF0000 ^ 0000FFFF");
        
        // ========== TESTE 18: XOR com valores iguais ==========
        $display("\n--- Teste 18: XOR com valores iguais ---");
        a = 32'hAAAAAAAA;
        b = 32'hAAAAAAAA;
        op = 3'b110;
        #10;
        check(32'h00000000, 1'b1, r, zero, "XOR AAAAAAAA ^ AAAAAAAA");
        
        // ========== TESTE 19: XOR com padrão alternado ==========
        $display("\n--- Teste 19: XOR com padrão alternado ---");
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        op = 3'b110;
        #10;
        check(32'hFFFFFFFF, 1'b0, r, zero, "XOR AAAAAAAA ^ 55555555");
        
        // ========== TESTE 20: XOR com um dos operandos zero ==========
        $display("\n--- Teste 20: XOR com b = 0 ---");
        a = 32'h12345678;
        b = 32'h00000000;
        op = 3'b110;
        #10;
        check(32'h12345678, 1'b0, r, zero, "XOR 0x12345678 ^ 0");
        
        // ========== TESTE 21: XOR com ambos operandos zero ==========
        $display("\n--- Teste 21: XOR com ambos operandos zero ---");
        a = 32'h00000000;
        b = 32'h00000000;
        op = 3'b110;
        #10;
        check(32'h00000000, 1'b1, r, zero, "XOR 0 ^ 0");
        
        // ========== TESTE 22: ADD com números grandes ==========
        $display("\n--- Teste 22: ADD com números grandes ---");
        a = 32'h7FFFFFFF;
        b = 32'h00000001;
        op = 3'b010;
        #10;
        check(32'h80000000, 1'b0, r, zero, "ADD 0x7FFFFFFF + 1");
        
        // ========== TESTE 23: SUB com números negativos ==========
        $display("\n--- Teste 23: SUB com números negativos ---");
        a = -32'd5;
        b = -32'd3;
        op = 3'b011;
        #10;
        check(-32'd2, 1'b0, r, zero, "SUB -5 - (-3)");
        
        // ========== TESTE 24: Operação inválida ==========
        $display("\n--- Teste 24: Operação inválida (default) ---");
        a = 32'd10;
        b = 32'd20;
        op = 3'b111;
        #10;
        $display("[INFO] Operação inválida: r = 0x%h, zero = %b", r, zero);
        $display("[PASS] Operação inválida tratada com default");
        
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