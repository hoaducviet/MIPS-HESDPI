.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012 	#DIGITAL
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014	#RUN I/O
#KEYBOARD
.eqv KEY_CODE  0xFFFF0004 	# ASCII code from keyboard, 1 byte =1 if has a new keycode ?
.eqv KEY_READY 0xFFFF0000 	# Auto clear after lw

# MARSBOT
.eqv HEADING 0xffff8010 		# Integer: An angle between 0 and 359
 				# 0 : North (up)
 				# 90: East (right)
				# 180: South (down)
				# 270: West (left)
.eqv MOVING 0xffff8050 		# Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 	# Boolean (0 or non-0):
 				# whether or not to leave a track
.eqv WHEREX 0xffff8030 		# Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040 		# Integer: Current y-location of MarsBot

# KEY VALUE
	.eqv KEY_0 0x11
	.eqv KEY_1 0x21
	.eqv KEY_2 0x41
	.eqv KEY_3 0x81
	.eqv KEY_4 0x12
	.eqv KEY_5 0x22
	.eqv KEY_6 0x42
	.eqv KEY_7 0x82
	.eqv KEY_8 0x14
	.eqv KEY_9 0x24
	.eqv KEY_a 0x44
	.eqv KEY_b 0x84
	.eqv KEY_c 0x18
	.eqv KEY_d 0x28
	.eqv KEY_e 0x48
	.eqv KEY_f 0x88
	
.data
#Code control

	MOVE_CODE:     .asciiz   "1b4"
	STOP_CODE:     .asciiz   "c68"
	LEFT_CODE:     .asciiz   "444"
	RIGHT_CODE:    .asciiz   "666"
	TRACK_CODE:    .asciiz   "dad"
	UNTRACK_CODE:  .asciiz   "cbc"
	BACK_CODE:     .asciiz   "999"
	WRONG_CODE:    .asciiz   "Ma dieu khien khong dung!!!"
	
	inputControlCode: .space 500
	lengthControlCode: .word 0
	nowHeading: .word 0

	path: .space 600
	lengthPath: .word 12
	
.text
main:
	li $k0, KEY_CODE 	
 	li $k1, KEY_READY
 	
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t3, 0x80			# bit số 7 có giá trị bằng 1 để bật
	sb $t3, 0($t1)
	addi $t7, $zero, 0

loop: 	
	nop

WaitForKey:	
	lw $t5, 0($k1)			# $t5 là giá trị sẵn sàng
	beq $t5, $zero, WaitForKey
	nop
	beq $t5, $zero, WaitForKey
		
ReadKey:
	lw $t6, 0($k0)			# $t6 = [$k0] = KEY_CODE
	beq $t6, 127, continue		# Nếu $t6 = kí tự xoá thì chuyển đến continue
					# 127 là kỹ tự xóa trong mã ascii
	bne $t6, '\n' , loop
	nop
	bne $t6, '\n' , loop
	
CheckControlCode:
	la  $s2, lengthControlCode
	lw $s2, 0($s2)
	bne $s2, 3, ErrorMessage		#Nếu độ dài CODE khác 3 thì thông báo lỗi
	
	la $s3, MOVE_CODE
	jal EqualString
	beq $t0, 1, go
	
	la $s3, STOP_CODE
	jal EqualString
	beq $t0, 1, stop
	
	la $s3, LEFT_CODE
	jal EqualString
	beq $t0, 1, goLeft
	
	la $s3, RIGHT_CODE
	jal EqualString
	beq $t0, 1, goRight
	
	la $s3, TRACK_CODE
	jal EqualString
	beq $t0, 1, track
	
	la $s3, UNTRACK_CODE
	jal EqualString
	beq $t0, 1, untrack
	
	la $s3, BACK_CODE
	jal EqualString
	beq $t0, 1, goBack
	
	beq $t0, 0, ErrorMessage		#Nếu không CODE không thuộc dữ kiện đề cho thì báo lỗi
	
printControlCode:
	li $v0,4
	la $a0, inputControlCode
	syscall
	nop
	
continue:
	jal removeControlCode
	nop
	j loop
	nop
	j loop
# code trở lên hoàn toàn ổn

storePath:
	#Sao lưu vào ngăn xếp
	addi $sp, $sp, 4
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4
	sw $t4, 0($sp)
	addi $sp, $sp, 4
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $s2, 0($sp)
	addi $sp, $sp, 4
	sw $s3, 0($sp)
	addi $sp, $sp, 4
	sw $s4, 0($sp)
	
	# Xử lý dữ liệu
	li $t1, WHEREX
	lw $s1, 0($t1)
	li $t2, WHEREY
	lw $s2, 0($t2)
	
	la $t3, lengthPath
	lw $s3, 0($t3)		# $s3 = lengthPath
	
	la $s4, nowHeading
	lw $s4, 0($s4)		# $s4 = nowHeading
	
	la $t4, path		# Gán địa chỉ mảng path cho $t4
	add $t4, $t4, $s3	# Chuyển đến địa chỉ chưa lưu giá trị của mảng path
	
	sw $s1, 0($t4)		# Lưu x
	sw $s2, 4($t4)		# Lưu y
	sw $s4, 8($t4)		# Lưu heading
	
	addi $s3, $s3, 12	# update lenghtPath: 3(word) x 4(bytes) = 12
	sw $s3, 0($t3)
	
	#Khôi phục dữ liệu
	lw $s4, 0($sp)
	addi $sp, $sp, -4
	lw $s3, 0($sp)
	addi $sp, $sp, -4
	lw $s2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t4, 0($sp)
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)

	jr $ra
	nop
	jr $ra
	
# QUAY LẠI BAN ĐẦU
# BEGIN GOBACK  
goBack: 
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $s7, 0($sp)
	addi $sp,$sp,4
	sw $t7, 0($sp)
	addi $sp,$sp,4
	sw $t8, 0($sp)
	addi $sp,$sp,4
	sw $t9, 0($sp)
	
	jal UNTRACK			# Xoá lựa chọn vết khi quay về, nếu cần phải thiết lập lại
	nop
	
	la $s7, path			# $s7 = mảng path
	la $s5, lengthPath
	lw $s5, 0($s5)
	add $s7, $s7, $s5
	# dùng path như 1 ngăn xếp 
	
begin: 
	addi $s5, $s5, -12		# Lùi lại 1 structure
	
	addi $s7, $s7, -12		# Lùi về cạnh cuối cùng
	lw $s6, 8($s7)			# đưa hướng vị trí cuối cùng vào thanh ghi $6
	addi $s6, $s6, 180		# Quay ngược hướng ban đầu
	
	la $t7, nowHeading
	sw $s6, 0($t7)
	jal ROTATE
	
loop_goBack:
	lw $t9, 0($s7)			# Toạ độ x xuất phát
	li $t8, WHEREX			# Toạ độ x hiện tại
	lw $t8, 0($t8)
	
	bne $t8, $t9, loop_goBack
	nop
	bne $t8, $t9, loop_goBack
	
	lw $t9, 4($s7)		
	li $t8, WHEREY			# Toạ độ y xuất phát
	lw $t8, 0($t8)			# Toạ độ y hiện tại
	
	bne $t8, $t9, loop_goBack
	nop
	bne $t8, $t9, loop_goBack
	
	beq $s5, 0, finish
	nop
	beq $s5, 0, finish
	
	j begin
	nop
	j begin
	

# END GO BACK 
finish:
	jal STOP
	
	la $t7, nowHeading
	add $s6, $zero, $zero
	sw $s6, 0($t7)			# update heading = 0
	la $t8, lengthPath
	addi $s5, $zero, 12
	sw $s5, 0($t8)			# update lengthPath = 12
	
	#restore
	lw $t9, 0($sp)
	addi $sp,$sp,-4
	lw $t8, 0($sp)
	addi $sp,$sp,-4
	lw $t7, 0($sp)
	addi $sp,$sp,-4
	lw $s7, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
		
	jal ROTATE
	j printControlCode
	
go:	
	jal GO
	j printControlCode

stop:	
	jal STOP
	j printControlCode

track:	
	jal TRACK
	j printControlCode

untrack:
	jal UNTRACK
	j printControlCode
	
goRight: 
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	
	beq $t7, 1, next_1
	j goRight_1
	
goRight_1: 
	la $s5, nowHeading		#Gán địa chỉ nowheading vào $t5
	lw $s6, 0($s5)
	addi $s6, $s6, 90
	sw $s6, 0($s5)			#Cập nhật lạ giá trị nowheading
	
	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath
	nop
	jal ROTATE
	nop
	j printControlCode
	
# Xóa và tạo vết mới
next_1:
	jal UNTRACK
	nop
	jal TRACK
	nop
	j goRight_1

goLeft:  
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	
	beq $t7, 1, next_2
	j goLeft_1

goLeft_1:	
	la $s5, nowHeading		#Gán địa chỉ nowheading vào $t5
	lw $s6, 0($s5)
	addi $s6, $s6, -90
	sw $s6, 0($s5)			#Cập nhật lạ giá trị nowheading

	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath
	jal ROTATE
	nop
	j printControlCode

next_2:
	jal UNTRACK
	nop
	jal TRACK
	nop
	j goLeft_1

removeControlCode:
	#backup cac thanh ghi
	addi $sp, $sp, 4
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $s2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	
	
	la $s1, inputControlCode
	la $s2, lengthControlCode
	lw $t3, 0($s2)				#$t3 = lengthControlCode
	addi $t1, $zero, -1			#$t1 = -1
	addi $t2, $zero, 0			#$t2 = '\0'
	addi $s1, $s1, -1

loop_remove:
	addi $t1, $t1, 1				# i++
	add $s1, $s1, 1
	sb $t2, 0($s1)				# Đặt lại giá trị inputControl = 0
	
	bne $t1, $t3, loop_remove		# $t1 <= 3 thì tiếp tục loop_remove
	nop
	bne $t1, $t3, loop_remove
	
	add $t3, $zero, $zero
	sw $t3, 0($s2)				# lengthControlCode = 0
	
	#restore lai gia tri cac thanh ghi
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $s2, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jr $ra
	nop
	jr $ra
	
EqualString:
	#backup gia tri
	addi $sp, $sp, 4
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	
	add $t0, $zero, $zero		#Khởi tạo giá trị $t0 = 0
	addi $t1, $zero, -1
	la $s1, inputControlCode
	
loop_equal:
	addi $t1, $t1, 1			#i++
	
	add $t2, $s1, $t1		#$t2 = inputControl + i
	lb $t2, 0($t2)			#$t2 = inputControl[i]
	
	add $t3, $s3, $t1
	lb $t3, 0($t3)
	
	bne $t2, $t3, not_equal
	
	bne $t1, 2, loop_equal		# $t1 <= 2 thì tiếp tục loop_equal
	nop
	bne $t1, 2, loop_equal
	
equal: 
	#restore
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	add $t0, $zero, 1          	#Nếu String đúng thì update $t0 = 1
	
	jr $ra
	nop
	jr $ra
	
not_equal:
	#restore
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	add $t0, $zero, $zero      	#Nếu String sai thì update $t0 = 0
	
	jr $ra
	nop
	jr $ra

ErrorMessage: 	
	li $v0, 4
	la $a0, inputControlCode		#Hiển thị lại dòng COĐE bị lỗi
	syscall
	nop
		
	li $v0, 55			#Hiển thị cảnh báo CODE lỗi
	la $a0, WRONG_CODE
	syscall
	nop
	nop
		
	j continue
	nop
	j continue
		
GO:	
	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	
	li $at, MOVING
	addi $k0, $zero, 1
	sb $k0, 0($at)
	
	#restore
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
	
STOP:	
	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	
	li $at, MOVING
	sb $zero, 0($at)
	
	#restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
	
TRACK:	
	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	
	li $at, LEAVETRACK
	addi $k0, $zero, 1
	sb $k0, 0($at)
	addi $t7, $zero, 1 
	
	#restore
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

UNTRACK:
	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	
	li $at, LEAVETRACK
	sb $zero, 0($at)
	addi $t7, $zero, 0
	
	#restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

ROTATE:	
	#backup
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	
	li $t1, HEADING
	la $t2, nowHeading
	lw $t3, 0($t2)
	sw $t3, 0($t1)
	
	#restore
 	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
	

#----------------------------------------------------------------------------------------
.ktext 0x80000180

backup:
	addi $sp, $sp, 4
	sw $ra, 0($sp)
	addi $sp, $sp, 4
	sw $at, 0($sp)
	addi $sp, $sp, 4
	sw $a0, 0($sp)
	addi $sp, $sp, 4
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4
	sw $t4, 0($sp)
	addi $sp, $sp, 4
	sw $s0, 0($sp)
	addi $sp, $sp, 4
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $s2, 0($sp)
	addi $sp, $sp, 4
	sw $s3, 0($sp)
	
get_code:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, OUT_ADRESS_HEXA_KEYBOARD

scan_row1:
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
	
scan_row2:
	li $t3, 0x82
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
	
scan_row3:
	li $t3, 0x84
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
	
scan_row4:
	li $t3, 0x88
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char

get_code_in_char:
	beq $a0, KEY_0, case_0
	beq $a0, KEY_1, case_1
	beq $a0, KEY_2, case_2
	beq $a0, KEY_3, case_3
	beq $a0, KEY_4, case_4
	beq $a0, KEY_5, case_5
	beq $a0, KEY_6, case_6
	beq $a0, KEY_7, case_7
	beq $a0, KEY_8, case_8
	beq $a0, KEY_9, case_9
	beq $a0, KEY_a, case_a
	beq $a0, KEY_b, case_b
	beq $a0, KEY_c, case_c
	beq $a0, KEY_d, case_d
	beq $a0, KEY_e, case_e
	beq $a0, KEY_f, case_f
	
case_0:	li $s0, '0'
	j store_code
case_1:	li $s0, '1'
	j store_code
case_2:	li $s0, '2'
	j store_code
case_3:	li $s0, '3'
	j store_code
case_4:	li $s0, '4'
	j store_code
case_5:	li $s0, '5'
	j store_code
case_6:	li $s0, '6'
	j store_code
case_7:	li $s0, '7'
	j store_code
case_8:	li $s0, '8'
	j store_code
case_9:	li $s0, '9'
	j store_code
case_a:	li $s0, 'a'
	j store_code
case_b:	li $s0, 'b'
	j store_code
case_c:	li $s0, 'c'
	j store_code
case_d:	li $s0, 'd'
	j store_code
case_e:	li $s0,	'e'
	j store_code
case_f:	li $s0, 'f'
	j store_code
	
store_code:
	la $s1, inputControlCode
	la $s2, lengthControlCode
	lw $s3, 0($s2)			# $s3 = lenghtControlCode
	addi $t4, $t4, -1		# $st4 = i

loop_store_code:
	addi $t4, $t4, 1
	bne $t4, $s3, loop_store_code
	add $s1, $s1, $t4		# $s1 = inputControlCode + i
	sb $s0, 0($s1)			# $s0 = inputControlCode[i]
	
	addi $s0, $zero, '\n'		# add '\n' để kết thúc chuỗi
	addi $s1, $s1, 1
	sb $s0, 0($s1)
	
	addi $s3, $s3, 1
	sw $s3, 0($s2)			# update lenghtControlCode
	
next_pc:
	mfc0 $at, $14 			# $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4			# $at = $at + 4 (next instruction)
	mtc0 $at, $14 			# Coproc0.$14 = Coproc0.epc <= $at

restore:
	lw $s3, 0($sp)
	addi $sp, $sp, -4
	lw $s2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $s0, 0($sp)
	addi $sp, $sp, -4
	lw $t4, 0($sp)
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	lw $a0, 0($sp)
	addi $sp, $sp, -4
	lw $at, 0($sp)
	addi $sp, $sp, -4
	lw $s3, 0($sp)
	addi $ra, $sp, -4

return: 
	eret
