.data             
Str: .asciz  "                                           *************       \n**************                            *3333333333333*      \n*222222222222222*                         *33333********       \n*22222******222222*                       *33333*              \n*22222*      *22222*                      *33333********       \n*22222*       *22222*      *************  *3333333333333*      \n*22222*       *22222*    **11111*****111* *33333********       \n*22222*       *22222*  **1111**       **  *33333*              \n*22222*      *222222*  *1111*             *33333********       \n*22222*******222222*  *11111*             *3333333333333*      \n*2222222222222222*    *11111*              *************       \n***************       *11111*                                  \n     ---               *1111**                                 \n   / o o \\              *1111****   *****                      \n   \\   > /               **111111***111*                       \n    -----                  ***********    dce.hust.edu.vn      \n"
#                                           *************     \n
#**************                            *3333333333333*    \n
#*222222222222222*                         *33333********     \n
#*22222******222222*                       *33333*            \n
#*22222*      *22222*                      *33333********     \n
#*22222*       *22222*      *************  *3333333333333*    \n    
#*22222*       *22222*    **11111*****111* *33333********     \n
#*22222*       *22222*  **1111**       **  *33333*            \n
#*22222*      *222222*  *1111*             *33333********     \n
#*22222*******222222*  *11111*             *3333333333333*    \n
#*2222222222222222*    *11111*              *************     \n
#***************       *11111*                                \n
#      ---              *1111**                               \n
#    / o o \\             *1111****   *****                    \n
#    \\   > /              **111111***111*                     \n
#     -----                 ***********    dce.hust.edu.vn    \n

menu: .asciz "\n=============================MENU===========================\n|1. Hien thi hinh anh tren giao dien                       |\n|2. Hien thi hinh anh chi con lai vien, khong co mau o giua|\n|3. Hien thi hinh anh sau khi hoan doi vi tri              |\n|4. Nhap tu ban phim ki tu mau cho chu D, C, E roi hien thi|\n|5. Thoat                                           	   |\n============================================================\n"
input: .asciz "Nhap lua chon: "
msg: .asciz "Nhap lan luot mau cho chu D, C, E (Tu 0 den 9):\n"
error: .asciz "So khong phu hop. Nhap lai!\n"
.text
main:
	# In ra menu
	la a0, menu
	li a7, 4
	ecall 
In:
	# In dòng yêu cầu nhập
	la a0, input
	li a7, 4
	ecall

	# Đọc số nguyên nhập vào a0

	li a7, 5
	ecall
	blez a0, Error
	bgt a0, a7, Error
	j case1
Error:
	li a7, 4
	la a0, error
	ecall
	j In
#____________Chức năng 1_______________
case1:
	li a1, 1
	bne a0, a1, case2
	j ex1
#____________Chức năng 2_______________
case2:	
	li a2, 2
	bne a0, a2, case3
	j ex2
#____________Chức năng 3_______________
case3:
	li a3, 3
	bne a0, a3, case4
	j ex3
#____________Chức năng 4_______________
case4:
	li a4, 4
	bne a0, a4, case5
	j ex4
#____________Chức năng 5_______________
case5:
	li a5, 5
	bne a0, a5, default
	j ex5
default:
	j main
#\n=============================CHUONG TRINH===========================\n
#____________________Chuc nang 1______________________
ex1:
	li a7, 4
	la a0, Str # Lay dia chi xau Str
	ecall
	j main
#____________________Chuc nang 2______________________
ex2:
	li t0, 0 # Bien dem i = 0
	la s0, Str # Lay dia chi xau Str
	li t1, 1023 # Do dai xau
	li s1, '0'
	li s2, '9'
loop_ex2:
	beq t0, t1, main
	lb t2, 0(s0)
	
	bgt t2, s2, print_ex2
	bge t2, s1, number
	j print_ex2
number:	
	addi t2, zero, 32 # Ky tu khoang trang co ma Ascii 32
print_ex2:
	li a7, 11
	mv a0, t2
	ecall 
	addi t0, t0, 1 # i = i + 1
	addi s0, s0, 1 # Dich chuyen sang ky tu tiep theo
	j loop_ex2

#____________________Chuc nang 3______________________
ex3:
	la s5, Str # Lay dia chi xau Str
	li s6, -1
	li s7, 16 # 16 dong 
	li s8, '\n'
loop_ex3:
	addi s6, s6, 1
	beq s6, s7, main # Duyet het 16 dong quay tro lai Menu
	slli s1, s6, 6
	add s1, s1, s5
	
	addi s3, s1, 42 # Chu E bat dau tu ki tu 42 tren dong
	jal print_21
	addi s3, s1, 21 # Chu C bat dau tu ki tu 21 tren dong
	jal print_21
	addi s3, s1, 0 # Chu D bat dau tu dau dong
	jal print_21
	
# In ky tu xuong dong	
	li a7, 11
	mv a0, s8 
	ecall
	
	j loop_ex3
# In 21 ky tu tren dong
print_21:
	li s4, 0
	li a5, 21
loop_2_ex3:
	lb t2, 0(s3) # Luu gia tri phan tu dang xet tren Str 
	li a7, 11
	mv a0, t2
	ecall
	addi s4, s4, 1 # s4 = s4 + 1
	addi s3, s3, 1 # Chuyen sang ky tu tiep theo
	bne s4, a5, loop_2_ex3
	jr ra
j main
#____________________Chuc nang 4______________________
ex4:
	li t0, 9 
# In ra message: Nhap mau cho chu D, C, E
	li a7, 4
	la a0, msg
	ecall
# Nhap mau cho D: a1
	li a7, 5
	ecall
	bltz a0, ERROR
	bgt a0, t0, ERROR 
	addi a1, a0, 48
# Nhap mau cho C: a2
	li a7, 5
	ecall
	bltz a0, ERROR
	bgt a0, t0, ERROR
	addi a2, a0, 48
# Nhap mau cho E: a3
	li a7, 5
	ecall
	bltz a0, ERROR
	bgt a0, t0, ERROR 
	addi a3, a0, 48
# Mau goc: s5, s6, s7
	li s5, 50
	li s6, 49
	li s7, 51
	j next
ERROR:
	li a7, 4
	la a0, error 
	ecall
	j ex4
next:
#_____________________________________________
	li t0, -1
	la s0, Str
	li t1, 1023
loop_ex4:
	beq t0, t1, main
	lb t2, 0(s0)
	
	beq t2, s5, print_1
	beq t2, s6, print_2
	beq t2, s7, print_3
	li a7, 11
	mv a0, t2
	ecall
	j continue
print_1:
	li a7, 11
	mv a0, a1
	ecall
	j continue
print_2:
	li a7, 11
	mv a0, a2
	ecall
	j continue
print_3:
	li a7, 11
	mv a0, a3
	ecall
	j continue
continue:
	addi t0, t0, 1
	addi s0, s0, 1
	j loop_ex4	
j main
#____________________Chuc nang 5______________________
ex5:
li a7, 10
ecall

