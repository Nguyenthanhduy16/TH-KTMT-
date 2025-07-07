.eqv IN_ADDRESS_HEXA_KEYBOARD    0xFFFF0012 
.eqv OUT_ADDRESS_HEXA_KEYBOARD   0xFFFF0014
.eqv MONITOR_SCREEN 0x10000000  # Dia chi bat dau cua bo nho man hinh
.eqv WHITE          0x00FFFFFF  # Mau trang
.eqv SCREEN_END     0x10010000  # Dia chi ket thuc cua man hinh (0x10010000 + 512*512*4)

.data
turn: .word 0                   # Bien luu luot: 0 = O, 1 = X
start_turn: .word 0		# Bien luu luot bat dau cua van: 0 = O, 1 = X
board: .word line1, line2, line3, line4 # 4 con tro tro den 4 hang
line1: .word 0,0,0,0            # Hang 1
line2: .word 0,0,0,0            # Hang 2
line3: .word 0,0,0,0            # Hang 3
line4: .word 0,0,0,0            # Hang 4
move_count: .word 0             # Dem so nuoc di de kiem tra hoa
win_msg_X: .asciz "X wins!"
win_msg_O: .asciz "0 wins!"
draw_msg: .asciz "Draw!"
newline: .asciz "\n"

.text
new_game:
    li a0, MONITOR_SCREEN        # Nap dia chi bat dau cua man hinh
    li t1, SCREEN_END           # Nap dia chi ket thuc
luoi_cot:
    li t0, WHITE              
    sw t0, 0(a0)                           
    addi a0, a0, 32             
    blt a0, t1, luoi_cot        # Neu a0 < SCREEN_END, tiep tuc vong lap

    li a0, MONITOR_SCREEN
    addi a0, a0, 896            # Dia chi dau hang ngang so 8
    addi a1, a0, 128            # Dia chi dau hang ngang so 9
luoi_ngang:
    li t0, WHITE 
    sw t0,0(a0)
    addi a0, a0, 4
    blt a0, a1, luoi_ngang
nhay_hang:
    addi a0, a0, 896            # Dia chi dau hang ngang so 15, 22
    addi a1, a0, 128            # Dia chi dau hang ngang so 16, 23
    blt a0, t1, luoi_ngang      # Neu a0 < SCREEN_END, tiep tuc vong lap
    
main:
    # Nap dia chi chuong trinh phuc vu ngat vao thanh ghi UTVEC
    la      t0, handler
    csrrs   zero, utvec, t0
    
    # Bat bit UEIE (User External Interrupt Enable) trong thanh ghi UIE
    li      t1, 0x100
    csrrs   zero, uie, t1     # uie - ueie bit (bit 8)
    
    # Bat bit UIE (User Interrupt Enable) trong thanh ghi USTATUS
    csrrsi  zero, ustatus, 1  # ustatus - bat uie (bit 0)
    
    # Bat ngat tu ban phim hex cua Digital Lab Sim
    li      t1, IN_ADDRESS_HEXA_KEYBOARD
    li      t3, 0x80          # bit 7 - 1 de bat ngat
    sb      t3, 0(t1)
    
end_main:
    j end_main

# --------------------------------------------------------------
# Chuong trinh phuc vu ngat
# --------------------------------------------------------------
handler:
    nop
polling:
    li      t2, 0x1
get_key_code:
    li      t4, 0x80          # Kiem tra hang 4 va bat lai bit 7
    li      t1, IN_ADDRESS_HEXA_KEYBOARD
    add     t5, t4, t2
    sb      t5, 0(t1)         # Phai gan lai hang can kiem tra
    li      t1, OUT_ADDRESS_HEXA_KEYBOARD
    lbu     a0, 0(t1)
    beqz    a0, next_row      # Neu khong co nut nao bam, sang hang tiep theo
    
    li      t0, 0
    li      s3, 16
cal_bit:
    # Lay gia tri hex tu bo nho
    add     t0, zero, a0
    # Tach chu so hang chuc (high nibble)
    srli    t1, t0, 4         # Dich phai 4 bit de lay phan chuc
    andi    t1, t1, 0xF       # Chi giu lai 4 bit thap
    # Tach chu so hang don vi (low nibble)
    andi    t2, t0, 0xF       # Lay 4 bit thap
    # Tim so mu co so 2 cao nhat cua hang chuc
    li      t3, -1            # Khoi tao so mu = -1 (neu t1 = 0)
    beqz    t1, skip_tens     # Neu t1 = 0, bo qua tim so mu
    li      t3, 0             # Khoi tao so mu = 0
find_tens_power:
    srli    t4, t1, 1         # Dich phai 1 bit
    beqz    t4, tens_done     # Neu = 0, da tim xong
    mv      t1, t4            # Cap nhat t1
    addi    t3, t3, 1         # Tang so mu
    j       find_tens_power
tens_done:
skip_tens:
    # Tim so mu co so 2 cao nhat cua hang don vi
    li      t5, -1            # Khoi tao so mu = -1 (neu t2 = 0)
    beqz    t2, skip_units    # Neu t2 = 0, bo qua tim so mu
    li      t5, 0             # Khoi tao so mu = 0
find_units_power:
    srli    t4, t2, 1         # Dich phai 1 bit
    beqz    t4, units_done    # Neu = 0, da tim xong
    mv      t2, t4            # Cap nhat t2
    addi    t5, t5, 1         # Tang so mu
    j       find_units_power
units_done:
skip_units:
    # Tinh dia chi: 34 + chuc*256 + donvi*8
    slli    t5, t5, 8         # t5 = t5 × 256
    slli    t3, t3, 3         # t3 = t3 * 8
    add     a0, t3, t5        # a0 = t3 + t5
    addi    a0, a0, 34
    slli    a0, a0, 2
    li      s0, MONITOR_SCREEN  
    add     a0, s0, a0        # a0 = dia chi offset trong bitmap

    # Kiem tra o da duoc dien chua
    # t5 = row, t3 = col
    srli t3,t3,3        	# dua t3 ve lai gia tri col
    srli t5,t5,8       	 	# dua t5 ve lai gia tri col
    la t1, board                # t1 = dia chi cua board
    slli t2, t5, 2              # t2 = row * 4 (moi con tro 4 byte)
    add t2, t1, t2              # t2 = dia chi cua board[row]
    lw t1, 0(t2)                # t1 = dia chi cua lineX (hang row)
    slli t2, t3, 2              # t2 = col * 4
    add t1, t1, t2              # t1 = dia chi cua board[row][col]
    lw t2, 0(t1)                # t2 = trang thai tai board[row][col]
    # Neu o khong trong, quay lai quet ban phim
    li s3,1 
    li s4,2
    beq t2,s3, invalid_key
    beq t2,s4, invalid_key
    
    # Kiem tra luot hien tai
    la t3, turn
    lw t4, 0(t3)
    beqz t4, draw_O        # Neu turn = 0, ve O
    j draw_X               # Neu turn = 1, ve X
    
draw_X:
    li t0, WHITE              
    sw t0, 0(a0)
    sw t0, 16(a0)
    addi a0,a0,132
    sw t0, 0(a0)
    sw t0, 8(a0)
    addi a0,a0,132
    sw t0, 0(a0)
    addi a0,a0,124
    sw t0, 0(a0)
    sw t0, 8(a0)
    addi a0,a0,124
    sw t0, 0(a0)
    sw t0, 16(a0)
    # Ghi trang thai vao board = 1 (X)
    li t5, 1
    sw t5, 0(t1)
    # Chuyen turn = 1 -> 0 (O)
    la t3, turn
    li t4, 0
    sw t4, 0(t3)
    # Tang move_count
    la t0, move_count
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    # Kiem tra thang thua
    jal check_winner
    li a2, 1
    li a3, 2
    beq a1, a2, end_game         # Neu X thang
    beq a1, a3, end_game         # Neu O thang
    beqz a1, check_draw       # Neu hoa
    j next_row

draw_O:
    li t0, WHITE              
    sw t0, 0(a0)
    sw t0, 4(a0)
    sw t0, 8(a0)
    sw t0, 12(a0)
    sw t0, 16(a0)
    addi a0, a0,128
    sw t0, 0(a0)
    sw t0, 16(a0)
    addi a0, a0,128
    sw t0, 0(a0)
    sw t0, 16(a0)
    addi a0, a0,128
    sw t0, 0(a0)
    sw t0, 16(a0)
    addi a0, a0,128
    sw t0, 0(a0)
    sw t0, 4(a0)
    sw t0, 8(a0)
    sw t0, 12(a0)
    sw t0, 16(a0)
    # Ghi trang thai vao board = 2 (O)
    li t5, 2
    sw t5, 0(t1)
    # Chuyen turn = 0 -> 1 (X)
    la t3, turn
    li t4, 1
    sw t4, 0(t3)
    # Tang move_count
    la t0, move_count
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    # Kiem tra thang thua
    jal check_winner
    li a2, 1
    li a3, 2
    beq a1, a2, end_game         # Neu X thang
    beq a1, a3, end_game         # Neu O thang
    beqz a1, check_draw       # Neu hoa
    j next_row
        
check_draw:
    la t0, move_count
    lw t1, 0(t0)
    li t2, 16                   # Ban co 4x4 co 16 o
    beq t1, t2, is_draw         # Neu da di 16 nuoc, hoa
    j polling                   # Tiep tuc quet ban phim

is_draw:
    la a0, draw_msg
    li a7, 4
    ecall
    la a0, newline
    ecall
    j reset_game
invalid_key:
next_row:
    slli t2, t2, 1         # Dich trai de kiem tra hang tiep theo
    li t3, 0x10
    blt t2, t3, get_key_code
    j polling              # Quay lai quet ban phim
check_winner:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    # Kiem tra 4 hang
    jal winRow0
    bne a1, zero, end_check
    jal winRow1
    bne a1, zero, end_check
    jal winRow2
    bne a1, zero, end_check
    jal winRow3
    bne a1, zero, end_check
    # Kiem tra 4 cot
    jal winCol0
    bne a1, zero, end_check
    jal winCol1
    bne a1, zero, end_check
    jal winCol2
    bne a1, zero, end_check
    jal winCol3
    bne a1, zero, end_check
    # Kiem tra 2 duong cheo
    jal winDiag0
    bne a1, zero, end_check
    jal winDiag1
    bne a1, zero, end_check
    # Khong co nguoi thang
    li a1, 0
    j end_check

end_check:
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

winRow0:
    la t0, board
    lw t1, 0(t0)            # t1 = dia chi cua line1
    lw t2, 0(t1)            # t2 = board[0][0]
    beqz t2, no_win_row0    # Neu o trong, khong thang
    lw t3, 4(t1)            # t3 = board[0][1]
    bne t2, t3, no_win_row0
    lw t4, 8(t1)            # t4 = board[0][2]
    bne t2, t4, no_win_row0
    lw t5, 12(t1)           # t5 = board[0][3]
    bne t2, t5, no_win_row0
    mv a1, t2               # a1 = 1 (X) hoac 2 (O)
    ret
no_win_row0:
    li a1, 0
    ret

winRow1:
    la t0, board
    lw t1, 4(t0)            # t1 = dia chi cua line2
    lw t2, 0(t1)            # t2 = board[1][0]
    beqz t2, no_win_row1
    lw t3, 4(t1)            # t3 = board[1][1]
    bne t2, t3, no_win_row1
    lw t4, 8(t1)            # t4 = board[1][2]
    bne t2, t4, no_win_row1
    lw t5, 12(t1)           # t5 = board[1][3]
    bne t2, t5, no_win_row1
    mv a1, t2
    ret
no_win_row1:
    li a1, 0
    ret

winRow2:
    la t0, board
    lw t1, 8(t0)            # t1 = dia chi cua line3
    lw t2, 0(t1)            # t2 = board[2][0]
    beqz t2, no_win_row2
    lw t3, 4(t1)            # t3 = board[2][1]
    bne t2, t3, no_win_row2
    lw t4, 8(t1)            # t4 = board[2][2]
    bne t2, t4, no_win_row2
    lw t5, 12(t1)           # t5 = board[2][3]
    bne t2, t5, no_win_row2
    mv a1, t2
    ret
no_win_row2:
    li a1, 0
    ret

winRow3:
    la t0, board
    lw t1, 12(t0)           # t1 = dia chi cua line4
    lw t2, 0(t1)            # t2 = board[3][0]
    beqz t2, no_win_row3
    lw t3, 4(t1)            # t3 = board[3][1]
    bne t2, t3, no_win_row3
    lw t4, 8(t1)            # t4 = board[3][2]
    bne t2, t4, no_win_row3
    lw t5, 12(t1)           # t5 = board[3][3]
    bne t2, t5, no_win_row3
    mv a1, t2
    ret
no_win_row3:
    li a1, 0
    ret

winCol0:
    la t0, board
    lw t1, 0(t0)            # t1 = line1
    lw t2, 0(t1)            # t2 = board[0][0]
    beqz t2, no_win_col0
    lw t3, 4(t0)            # t3 = line2
    lw t3, 0(t3)            # t3 = board[1][0]
    bne t2, t3, no_win_col0
    lw t4, 8(t0)            # t4 = line3
    lw t4, 0(t4)            # t4 = board[2][0]
    bne t2, t4, no_win_col0
    lw t5, 12(t0)           # t5 = line4
    lw t5, 0(t5)            # t5 = board[3][0]
    bne t2, t5, no_win_col0
    mv a1, t2
    ret
no_win_col0:
    li a1, 0
    ret

winCol1:
    la t0, board
    lw t1, 0(t0)            # t1 = line1
    lw t2, 4(t1)            # t2 = board[0][1]
    beqz t2, no_win_col1
    lw t3, 4(t0)            # t3 = line2
    lw t3, 4(t3)            # t3 = board[1][1]
    bne t2, t3, no_win_col1
    lw t4, 8(t0)            # t4 = line3
    lw t4, 4(t4)            # t4 = board[2][1]
    bne t2, t4, no_win_col1
    lw t5, 12(t0)           # t5 = line4
    lw t5, 4(t5)            # t5 = board[3][1]
    bne t2, t5, no_win_col1
    mv a1, t2
    ret
no_win_col1:
    li a1, 0
    ret

winCol2:
    la t0, board
    lw t1, 0(t0)            # t1 = line1
    lw t2, 8(t1)            # t2 = board[0][2]
    beqz t2, no_win_col2
    lw t3, 4(t0)            # t3 = line2
    lw t3, 8(t3)            # t3 = board[1][2]
    bne t2, t3, no_win_col2
    lw t4, 8(t0)            # t4 = line3
    lw t4, 8(t4)            # t4 = board[2][2]
    bne t2, t4, no_win_col2
    lw t5, 12(t0)           # t5 = line4
    lw t5, 8(t5)            # t5 = board[3][2]
    bne t2, t5, no_win_col2
    mv a1, t2
    ret
no_win_col2:
    li a1, 0
    ret

winCol3:
    la t0, board
    lw t1, 0(t0)            # t1 = line1
    lw t2, 12(t1)           # t2 = board[0][3]
    beqz t2, no_win_col3
    lw t3, 4(t0)            # t3 = line2
    lw t3, 12(t3)           # t3 = board[1][3]
    bne t2, t3, no_win_col3
    lw t4, 8(t0)            # t4 = line3
    lw t4, 12(t4)           # t4 = board[2][3]
    bne t2, t4, no_win_col3
    lw t5, 12(t0)           # t5 = line4
    lw t5, 12(t5)           # t5 = board[3][3]
    bne t2, t5, no_win_col3
    mv a1, t2
    ret
no_win_col3:
    li a1, 0
    ret

winDiag0:
    la t0, board
    lw t1, 0(t0)            # t1 = line1
    lw t2, 0(t1)            # t2 = board[0][0]
    beqz t2, no_win_diag0
    lw t3, 4(t0)            # t3 = line2
    lw t3, 4(t3)            # t3 = board[1][1]
    bne t2, t3, no_win_diag0
    lw t4, 8(t0)            # t4 = line3
    lw t4, 8(t4)            # t4 = board[2][2]
    bne t2, t4, no_win_diag0
    lw t5, 12(t0)           # t5 = line4
    lw t5, 12(t5)           # t5 = board[3][3]
    bne t2, t5, no_win_diag0
    mv a1, t2
    ret
no_win_diag0:
    li a1, 0
    ret

winDiag1:
    la t0, board
    lw t1, 0(t0)            # t1 = line1
    lw t2, 12(t1)           # t2 = board[0][3]
    beqz t2, no_win_diag1
    lw t3, 4(t0)            # t3 = line2
    lw t3, 8(t3)            # t3 = board[1][2]
    bne t2, t3, no_win_diag1
    lw t4, 8(t0)            # t4 = line3
    lw t4, 4(t4)            # t4 = board[2][1]
    bne t2, t4, no_win_diag1
    lw t5, 12(t0)           # t5 = line4
    lw t5, 0(t5)            # t5 = board[3][0]
    bne t2, t5, no_win_diag1
    mv a1, t2
    ret
no_win_diag1:
    li a1, 0
    ret

end_game:
    # In thong bao thang
    li t0, 1
    beq a1, t0, x_wins
    la a0, win_msg_O
    j print_winner
x_wins:
    la a0, win_msg_X
print_winner:
    li a7, 4
    ecall
    la a0, newline
    ecall
reset_game:
    # Reset board (dat tat ca ve 0)
    la t0, board
    li t2, 4          # 4 hang
    mv t4, t0         # t4 = dia chi board
reset_board_loop:
    lw t1, 0(t4)      # t1 = dia chi lineX
    sw zero, 0(t1)
    sw zero, 4(t1)
    sw zero, 8(t1)
    sw zero, 12(t1)
    addi t4, t4, 4    # Chuyen den con tro hang tiep theo
    addi t2, t2, -1   # Giam so hang
    bnez t2, reset_board_loop

    # Reset move_count
    la t0, move_count
    sw zero, 0(t0)

    # Reset turn (luan phien bat dau)
    la t0, start_turn
    lw t1, 0(t0)      # t1 = start_turn (0 hoac 1)
    xori t1, t1, 1    # Dao gia tri: 0 -> 1, 1 -> 0
    sw t1, 0(t0)      # Luu start_turn moi
    la t0, turn
    sw t1, 0(t0)      # Gan turn = start_turn moi

    # Xoa man hinh (boi toan bo man hinh ve mau ?en)
    li a0, MONITOR_SCREEN
    li t1, SCREEN_END
clear_screen:
    sw zero, 0(a0)
    addi a0, a0, 4
    blt a0, t1, clear_screen
    j new_game
    