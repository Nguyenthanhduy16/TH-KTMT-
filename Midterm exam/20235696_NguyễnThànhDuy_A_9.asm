.data
message_1: .asciz "Nhap so nguyen duong N co tu 2 chu so tro len: "
message_2: .asciz "Chu so nho nhat cua N: "
message_3: .asciz "Nhap sai, vui long thuc hien lai !"
space: .ascii " "
.text
main:
#------ Yeu cau nguoi dung nhap vao mot chu so -------
# In ra message_1
li a7, 4
la a0, message_1
ecall
# Nhap N
li a7, 5
ecall
mv s0, a0 #  s0 = N
# Kiem tra chu so nhap vao tu nguoi dung
li a2, 10 # a2 = 10
bge s0, a2, find_min
# Neu N < 10 thi in ra message_3
li a7, 55
la a0, message_3
li a1, 0
ecall
j end_main
#------ Tim chu so nho nhat co trong N -------
find_min:
li s2, 0x7fffffff # s2 duoc gan gia tri duong lon nhat
loop:
beqz s0, exit # Lap cho toi khi s0 = 0
rem s1, s0, a2 # s1 = s0 % 10
div s0, s0, a2 # s0 = s0 / 10
bgt s2, s1, update_min # s2 > s1 thi cap nhat

j loop
# Kiem tra va cap nhat gia tri nho nhat
update_min:
mv s2, s1 # Cap nhat gia tri min
j loop
# ------ In ra chu so nho nhat va ket thuc chuong trinh -------
exit:
# In ra message_2
li a7, 4
la a0, message_2
ecall
# In ra chu so nho nhat 
li a7, 1
mv a0, s2
ecall
# Ket thuc chuong trinh
end_main:
li a7, 10
ecall


