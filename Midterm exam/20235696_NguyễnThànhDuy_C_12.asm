.data
A: .space 100
B: .space 100
message_1: .asciz "INPUT: \n"
message_2: .asciz "OUTPUT: \n"
A_input: .asciz "Nhap xau A: "
B_input: .asciz "Nhap xau B: "
space: .ascii " "
.text
main:

# INPUT

li a7, 4
la a0, message_1
ecall
#--------Nhap xau 1---------
# In ra thong bao nhap xau A
la a0, A_input
ecall
# Nhap xau A: 
li a7, 8
la a0, A
li a1, 100
ecall
#-------Nhap xau 2----------
# In ra thong bao nhap xau B
li a7, 4
la a0, B_input
ecall
# Nhap xau B:
li a7, 8
la a0, B
li a1, 100
ecall

#------------------------------

# Xet cac ky tu
li a7, 4 # In ra message_2
la a0, message_2
ecall

la s1, A # Lay dia chi xau A
li s10, 10
check_A:
lb t0, 0(s1) # Lay gia tri tai dia chi s1
beq t0, s10, done # Neu gia tri la ky tu xuong dong tuc da duyet xong xau
beqz  t0, done # Neu gia tri la ky tu rong tuc da duyet xong xau
li t1, 'a' 
li t2, 'z'
blt t0, t1, next_A # Neu nhu nam ngoai a-z thi chuyen toi phan tu tiep theo
bgt t0, t2, next_A 
# Kiem tra ky tu co trong xau B 
la s2, B # Lay dia chi xau B
check_B:
lb t3, 0(s2) # Lay gia tri tai dia chi s2
beq t0, t3, next_A # Neu co bo qua xet ky tu dang sau
beq t3, s10, print # Neu gap ky tu xuong dong thi da duyet het xau 
beqz t3, print # Neu duyet het ma khong thay thi in ra man hinh
addi s2, s2, 1 # s2 = s2 + 1
j check_B
next_A:
addi s1, s1, 1 # s1 = s1 + 1
j check_A
# OUTPUT
# In ky tu thuong khong xuat hien trong B
print:
li a7, 11
mv a0, t0
ecall
# In dau cach
li a7, 4
la a0, space
ecall

j next_A
# Ket thuc chuong trinh
done:
li a7, 10
ecall



