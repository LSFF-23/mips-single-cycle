# soma de 1 a 10 = 55
addi $t0, $zero, 1          # $t0 = contador (i = 1)
addi $t1, $zero, 10         # $t1 = limite (10)
addi $t2, $zero, 0          # $t2 = soma (0)
loop: add  $t2, $t2, $t0    # soma = soma + i
addi $t0, $t0, 1            # i = i + 1
addi $t3, $t0, -10          # $t3 = i - 10
beq  $t3, $zero, fim        # se i == 10, sai do loop
beq  $zero, $zero, loop     # senão, continua
fim: sw   $t2, 0($zero)     # armazena soma em memória[0]
beq  $zero, $zero, fim      # para evitar do pc ler lixo