addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
loop: addi $10, $0, 10
addi $11, $0, 11
addi $12, $0, 12
beq $1, $2, exit
addi $7, $0, 7
addi $8, $0, 8
addi $1, $1, 1
addi $9, $0, 9
j loop
exit: addi $1, $0, 1
loop2: addi $10, $0, 10
addi $11, $0, 11
addi $12, $0, 12
beq $1, $2, exit2
addi $7, $0, 7
addi $8, $0, 8
addi $1, $1, 1
addi $9, $0, 9
j loop2
exit2: addi $1, $0, 1