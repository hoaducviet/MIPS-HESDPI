# Hoa Duc Viet

#Trung To - Hau To

.data
infix: 		.space 	256
postfix: 	.space 	256
stack: 		.space 	256
notification:	.asciiz "Enter String infix\n(Note) Input expression has number must be integer and positive number beetwen 0 and 99:"
string: 	.asciiz "\n"
message_postfix:.asciiz "Postfix is: "
message_result: .asciiz "Result is: "
message_infix: 	.asciiz "Infix is: "
message_error1: 	.asciiz "Error! \n Bieu thuc khong thoa man, Vui long nhap lai"
message_error2: 	.asciiz "So nguyen nam ngoai khoang 0-99.\n Vui long nhap lai"

.text
#Nhập và hiển thị chuỗi trung tố
 		li 	$v0, 54
 		la 	$a0, notification
 		la 	$a1, infix
 		la 	$a2, 256
 		syscall 
 
 		la 	$a0, message_infix
		li 	$v0, 4
		syscall
	
		la 	$a0, infix
		li 	$v0, 4
		syscall

# Chuyển trung tố sang hậu tố

		li 	$s6, -1 		# counter
		li 	$s7, -1 		# Scounter
		li 	$t7, -1 		# Pcounter
loop:
        	la 	$s1, infix  		# $s1 = infix
        	la 	$t5, postfix 		# $t5 = postfix
        	la 	$t6, stack 		# $t6 = stack
		addi 	$s6, $s6, 1  		# counter ++
	
	
		add 	$s1, $s1, $s6
		lb 	$t1, 0($s1)		# t1 = infix[counter]
	
		beq 	$t1, '+', operator 
		nop
		beq 	$t1, '-', operator 
		nop
		beq 	$t1, '*', operator
		nop
		beq 	$t1, '/', operator 
		nop
		beq 	$t1, '\n', n_operator 
		nop
		beq 	$t1, ' ', n_operator 
		nop
		beq 	$t1, $zero, end_loop
		nop
	
		beq 	$t1, '=', case_special	#Kiem tra cac ki tu dac biet
		nop
		beq 	$t1, '.', case_special
		nop
		beq 	$t1, ',', case_special
		nop
		
		j 	next			# Neu khong thuoc truong hop dac biet thi chuyen xuong next de bo qua bao loi
	
		case_special: j noti_error		
	
	noti_error:
		li 	$v0, 55
		la 	$a0, message_error1
		li 	$a1, 0
		syscall
		
	next:	
	# push so tu infix
		addi 	$t7, $t7, 1
		add 	$t5, $t5, $t7
		
		sb 	$t1, 0($t5)
		lb 	$a0, 1($s1)

		jal 	check_number
		beq 	$v0, 1, n_operator
		nop
	
	add_space:
		add 	$t1, $zero, ' '
		sb 	$t1, 1($t5)
		addi 	$t7, $t7, 1
	
		j 	n_operator
		nop
	
	operator:
	# add to stack	
		beq 	$s7, -1, pushToStack
		nop
		add 	$t6, $t6, $s7
		lb 	$t2, 0($t6) 		# t2 = value of stack[counter]
	
	# check t1 precedence
		beq 	$t1, '+', equal1
		nop
		beq 	$t1, '-', equal1
		nop
		li 	$t3, 2
		j check_t2
		nop
		
	equal1:
		li 	$t3, 1
	
	# check t2 precedence
	check_t2:
	
		beq 	$t2, '+', equal2
		nop
		beq 	$t2, '-', equal2
		nop
	
		li 	$t4, 2	
		j 	compare_precedence
		nop
	equal2:
		li 	$t4, 1	
	
compare_precedence:
	
		beq 	$t3, $t4, equal_precedence
		nop
		slt 	$s1, $t3, $t4
		beqz 	$s1, t3_large_t4
		nop

# t3 < t4
# pop t2 from stack  and t2 ==> postfix  
# get new top stack do again

		sb 	$zero, 0($t6)
		addi 	$s7, $s7, -1  		# scounter ++
		addi 	$t6, $t6, -1
		la 	$t5, postfix 		# $t5 = postfix
		addi 	$t7, $t7, 1
		add 	$t5, $t5, $t7
		
		sb 	$t2, 0($t5)
		j 	operator
		nop
	
	
t3_large_t4:
# push t1 to stack
		j 	pushToStack
		nop
		
equal_precedence:
# pop t2  from stack  and t2 ==> postfix  
# push to stack

		sb 	$zero, 0($t6)
		addi 	$s7, $s7, -1  		# scounter ++
		addi 	$t6, $t6, -1
		la 	$t5, postfix 		# postfix = $t5
		addi 	$t7, $t7, 1 		# pcounter ++
		add 	$t5, $t5, $t7
	
		sb 	$t2, 0($t5)
		j 	pushToStack
		nop
		
pushToStack:
		la 	$t6, stack 		# stack = $t6
		addi 	$s7, $s7, 1  		# scounter ++
		add 	$t6, $t6, $s7
		sb 	$t1, 0($t6)	
	
n_operator:					# Khi gap 1 so ki tu dac biet se bo qua va sang ki tu tiep theo
		j 	loop
		nop
	

end_loop:
	
		addi 	$s1, $zero, 32
		add 	$t7, $t7, 1
		add 	$t5, $t5, $t7 
		la 	$t6, stack
		add 	$t6, $t6, $s7
	
popallstack:

		lb 	$t2, 0($t6) 		# t2 = value of stack[counter]
		beq 	$t2, 0, endPostfix
		sb 	$zero, 0($t6)
		addi 	$s7, $s7, -2
		add 	$t6, $t6, $s7
	
		sb 	$t2, 0($t5)
		add 	$t5, $t5, 1
	
	
		j popallstack
		nop

endPostfix:
# Hiển thị chuỗi hậu tố
		la 	$a0, message_postfix
		li 	$v0, 4
		syscall

		la 	$a0, postfix
		li 	$v0, 4
		syscall

		la 	$a0, string
		li 	$v0, 4
		syscall


#Calculater

		li 	$s3, 0 			# counter
		la 	$s2, stack 		# $s2 = stack


# postfix to stack
		loop_post_to_stack:
		la 	$s1, postfix 		#$s1 = postfix
	
		add 	$s1, $s1, $s3
		lb 	$t1, 0($s1)
	
	
	
		beqz 	$t1 end_loop_post_stack
		nop
	

		add 	$a0, $zero, $t1
		jal 	check_number
		nop
	
		beqz 	$v0, is_operator
		nop
	
		jal 	add_number_to_stack
		nop
	
		j 	continue
		nop
	
is_operator:
	
		jal 	pop
		nop
		add 	$a1, $zero, $v0 
		jal 	pop
		nop
		add 	$a0, $zero, $v0 		
		add 	$a2, $zero, $t1 		
		jal caculate
		
continue:
	
		add 	$s3, $s3, 1 		# counter++
		j 	loop_post_to_stack
		nop


caculate:
		sw 	$ra, 0($sp)
		li 	$v0, 0
		beq 	$t1, '*', case_mul
		nop
		beq 	$t1, '/', case_div
		nop
		beq 	$t1, '+', case_plus
		nop
		beq 	$t1, '-', case_sub
		
	case_mul:
		mul 	$v0, $a0, $a1
		j 	cal_push
	case_div:
		div 	$a0, $a1
		mflo 	$v0
		j 	cal_push
	case_plus:
		add 	$v0, $a0, $a1
		j 	cal_push
	case_sub:
		sub 	$v0, $a0, $a1
		j 	cal_push
		
	cal_push:
		add 	$a0, $v0, $zero
		jal 	push
		nop
		lw 	$ra, 0($sp) 
		jr 	$ra
		nop
	



# $s3 : counter for postfix string
# $s1 : postfix string
# $t1 : current value

add_number_to_stack:
		#backup $ra				
		sw 	$ra, 0($sp)			
		li 	$v0, 0
	
	loop_adds:
		beq 	$t1, '0', case_0
		nop
		beq 	$t1, '1', case_1
		nop
		beq 	$t1, '2', case_2
		nop
		beq 	$t1, '3', case_3
		nop
		beq 	$t1, '4', case_4
		nop
		beq 	$t1, '5', case_5
		nop
		beq 	$t1, '6', case_6
		nop
		beq	$t1, '7', case_7
		nop
		beq 	$t1, '8', case_8
		nop
		beq 	$t1, '9', case_9
		nop
		
	case_0:	j 	store_stack
	
	case_1:	addi 	$v0, $v0, 1	
		j 	store_stack
		nop
		
	case_2:	addi 	$v0, $v0, 2
		j 	store_stack
		nop
		
	case_3:	addi	 $v0, $v0, 3
		j 	store_stack
		nop
		
	case_4:	addi 	$v0, $v0, 4
		j 	store_stack
		nop
		
	case_5:	addi 	$v0, $v0, 5
		j 	store_stack
		nop
		
	case_6:	addi 	$v0, $v0, 6
		j 	store_stack
		nop
		
	case_7:	addi 	$v0, $v0, 7
		j 	store_stack
			nop
			
	case_8:	addi 	$v0, $v0, 8
		j 	store_stack
		nop
		
	case_9:	addi 	$v0, $v0, 9
		j 	store_stack
			nop
	store_stack:
			
		add   	$s3, $s3, 1 			# counter++
		la 	$s1, postfix			# $s1 = postfix
	
		add 	$s1, $s1, $s3
		lb 	$t1, 0($s1)
		
		beq 	$t1, $zero, end_loop_adds
		beq 	$t1, ' ', end_loop_adds	
		mul	 $v0, $v0, 10	
		j 	loop_adds
		
	end_loop_adds:
		add 	$a0, $zero, $v0
		
		slti 	$t0, $v0, 100			# Neu so nam ngoai 0-99 thi bao loi
		beq	$t0, 1, tieptheo
		li 	$v0, 55
		la 	$a0, message_error2
		li 	$a1, 0
		syscall
		
tieptheo: 	jal 	push
		# restore $ra
		lw 	$ra, 0($sp) 
		jr 	$ra
		nop
		
		
	check_number:
        
		li 	$t8, '0'
		li	$t9, '9'
		beq 	$t8, $a0, check_number_true
		beq	$t9, $a0, check_number_true
	
		slt 	$v0, $t8, $a0
		beqz	$v0, check_number_false
	
		slt 	$v0, $a0, $t9
		beqz 	$v0, check_number_false
	
	check_number_true:
	
		li 	$v0, 1
		jr 	$ra
		nop
	check_number_false:
	
		li 	$v0, 0
	
		jr 	$ra
		nop

pop:
		lw 	$v0, -4($s2)
		sw 	$zero, -4($s2)
		add	$s2, $s2, -4
		jr 	$ra
		nop

push:
		sw 	$a0, 0($s2)
		add	$s2, $s2, 4
		jr 	$ra
		nop
	
end_loop_post_stack:					# print postfix
		la 	$a0, message_result
		li 	$v0, 4
		syscall


		jal 	pop
		add 	$a0, $zero, $v0 
		li 	$v0, 1
		syscall

		la 	$a0, string
		li 	$v0, 4
		syscall
