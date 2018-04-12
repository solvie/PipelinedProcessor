addi $1, $0, 0
addi $2, $0, 2
addi $3, $0, 3
addi $4, $0, 4
addi $5, $0, 5
addi $6, $0, 0
loop:addi $7, $0, 7
addi $8, $0, 8
addi $9, $0, 9
beq $1, $1, exit
addi $10, $0, 10
addi $11, $0, 11
addi $12, $0, 12
addi $1, $1, 1
j loop
exit: addi $6, $6, 1
loop2: addi $7, $0, 7
addi $8, $0, 8
addi $9, $0, 9
beq $1, $1, exit2
addi $10, $0, 10
addi $11, $0, 11
addi $12, $0, 12
addi $1, $1, 1
j loop2
exit2: addi $6, $6, 1
loop3: addi $7, $0, 7
addi $8, $0, 8
addi $9, $0, 9
beq $1, $2, exit3
addi $10, $0, 10
addi $11, $0, 11
addi $12, $0, 12
addi $1, $1, 1
j loop3
exit3: addi $6, $6, 1