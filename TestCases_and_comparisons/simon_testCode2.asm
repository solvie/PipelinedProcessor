addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
loop2: addi $4, $0, 0
addi $5, $0, 0
addi $6, $0, 0
beq $1, $2, end2
addi $1, $1, 1
addi $3, $0, 0
addi $4, $0, 0
addi $5, $0, 0
addi $6, $0, 0
j loop2
end2: addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
loop3: addi $4, $0, 0
addi $5, $0, 0
addi $6, $0, 0
beq $1, $2, end3
addi $1, $1, 1
addi $3, $0, 0
addi $4, $0, 0
addi $5, $0, 0
addi $6, $0, 0
j loop3
end3: addi $1, $0, 1
addi $2, $0, 2 #$1=1
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1