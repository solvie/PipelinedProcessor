addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
# not taken
loop1: addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
beq $1, $2, end1
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
# not taken
loop2: addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
beq $1, $2, end1
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
end1: addi $1, $1, 0 #$1=1
#taken
loop3: addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
beq $1, $1, end3
addi $3, $0, 2 #$1=1
addi $4, $0, 2 #$1=1
addi $5, $0, 2 #$1=1
addi $6, $0, 2 #$1=1
addi $7, $0, 2 #$1=1
j loop3
end3: addi $1, $1, 0 #$1=1
#taken
loop4: addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
beq $1, $1, end4
addi $3, $0, 4 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 4 #$1=1
addi $6, $0, 4 #$1=1
addi $7, $0, 4 #$1=1
j loop4
end4: addi $1, $0, 1 #$1=1
# not taken
loop5: addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
beq $1, $2, end5
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
# not taken
loop6: addi $1, $0, 1 #$1=1
addi $2, $0, 2 #$1=1
beq $1, $2, end5
addi $3, $0, 3 #$1=1
addi $4, $0, 4 #$1=1
addi $5, $0, 5 #$1=1
addi $6, $0, 6 #$1=1
addi $7, $0, 7 #$1=1
end5: addi $1, $1, 0 #$1=1