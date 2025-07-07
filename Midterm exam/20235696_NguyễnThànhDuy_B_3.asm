.data
A: .space 100
message_1: .asciz "Nhap so phan tu cua mang A: "
message_2: .asciz "Cap phan tu lien ke co tich lon nhat: "
message_3: .asciz "Nhap sai, vui long thuc hien lai !"
space: .asciz " "
.text
main:
# In ra yeu cau nhap mang A
li a7, 4
la a0, message_1
ecall

# Nhap so phan tu cua mang A
li a7, 5
ecall
mv s0, a0  # Luu so phan tu vao s0
# Neu n < 2 thi khong ton tai 2 phan tu thoa man yeu cau de bai
li a1, 2 # a1 = 2
bge s0, a1, begin
# In ra thong bao loi
li a7, 55
la a0, message_3
li a1, 0
ecall    
j end
begin:    
# Nhap mang A
la s1, A  # Con tro dau mang
li t0, 0  # Bien dem

loop:
bge t0, s0, done  # Neu nhap du so phan tu thi thoat
li a7, 5  # Nhap so nguyen
ecall

slli s2, t0, 2  # t0 * 4
add s2, s2, s1  # Dia chi phan tu t0 trong A
sw a0, 0(s2)    # Lưu gia tri vào mảng

addi t0, t0, 1  # Tang bien dem
j loop

done:
# Tim cap co tich lon nhat
li t0, 0 # Bien dem
li a5, -2147483648  # Gia tri tich nho nhat co the
li s2, 0  # Luu phan tu thu nhat
li s5, 0  # Luu phan tu thu hai

la s1, A  # Con tro dau mang
find_max:
addi t1, t0, 1 # t1 = t0 + 1
bge t1, s0, exit  # Neu duyet het thi thoat

lw a3, 0(s1)   # Lay phan tu t0
lw a4, 4(s1)   # Lay phan tu t0 + 1
mul s3, a3, a4 # Tinh tich

# Neu tich lon hon a5, cap nhat gia tri
bge s3, a5, update
# Cap nhat con tro va bien dem
next:
addi s1, s1, 4  # Di chuyen con tro den phan tu tiep theo
addi t0, t0, 1  # Tang bien dem
j find_max

update:
mv a5, s3  # Cap nhat tich lon nhat
mv s2, a3  # Cap nhat phan tu thu nhat
mv s5, a4  # Cap nhat phan tu thu hai
j next

exit:
# In kết quả va ket thuc chuong trinh
li a7, 4
la a0, message_2
ecall
# In phan tu thu nhat
li a7, 1
mv a0, s2  
ecall

li a7, 4
la a0, space
ecall
# In phan tu thu hai
li a7, 1
mv a0, s5  
ecall
end:
li a7, 10  # Ket thuc chuong trinh
ecall
