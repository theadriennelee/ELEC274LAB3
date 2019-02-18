	.equ	LAST_RAM_WORD, 	0X007FFFFC
	.equ 	JTAG_UART_BASE,	0x10001000
	.equ	DATA_OFFSET,	0
	.equ	STATUS_OFFSET,	4
	.equ	WSPACE_MASK,	0xFFFF
	.equ 	RANDOM_NUMBER, 	0x8000
	.equ	OTHER_NUMBER, 	0xFF

	.text
	.global _start
	.org	0x00000000
	
_start:
	#code 
	movia sp, LAST_RAM_WORD
	movi r2, MSG #print elec274 lab3
call PrintString
	movi r2, MSG1 #print type two decimal digits
call PrintString
call GetDecimal99 #im going to assume that when we call this, the decimal is placed into r2
	mov		r3, r2 #move the number into r3
	movi 	r2, MSG3 #yup, most likely wrong
call PrintChar
	movi 	r2, MSG2 #print you typed: "
call 	PrintChar
	mov 	r2, r3 #move the number back into r2
call 	PrintDecimal99
	movia 	r2, MSG3 #this is probably totally illegal
call PrintString

	
_end:
	br _end	
	
PrintString: 
	subi	sp, sp, 12
	stw 	ra, 8(sp)
	stw 	r3, 4(sp) 
	stw 	r2, 0(sp)
	mov 	r3, r2 
ps_loop: 
	ldb 	r2, 0(r3)
	beq		r2, r0, end_ps_loop 
	call 	PrintChar
	addi 	r3, r3, 1 
	br		ps_loop 
end_ps_loop:
	ldw 	ra, 8(sp)
	ldw 	r3, 4(sp)
	ldw 	r2, 0(sp)
	addi 	sp, sp, 12 
	ret 

PrintChar: 
	subi	sp, sp, 8
	stw		r3, 4(sp)
	stw		r4, 0(sp)
	movia	r3, JTAG_UART_BASE 
pc_loop: 
	ldwio	r4, STATUS_OFFSET(r3) 
	andhi	r4, r4, WSPACE_MASK
	beq		r4, r0, pc_loop
	stwio	r2, DATA_OFFSET(r3)
	ldw 	r3, 4(sp) 
	ldw		r4, 0(sp)
	addi	sp, sp, 8 
	ret
	
GetDecimal99: 
	subi	sp, sp, 16
	stw		r2, 0(sp) #where value is found
	stw		r3, 4(sp) #result
	stw 	r4, 8(sp) #9
	stw		r5, 12(sp) #10
	movi	r3, 0 #set result to 0
	movi	r4, 9 #set the register to 9
	movi	r5, 10 #set the register to 10
	call 	GetChar #call function to print the character that is found in r2 and store in r2
tens_loop:
	call	PrintChar #will print character found in r2
	sub		r3, r2, r0 #subtract 0 from character found in r2
	mul		r3, r3, r5 #multiply results by 10
	ble 	r2, r0, tens_loop #branch if less than 0??
	bgt		r2, r4, tens_loop #branch if greater than 9??
	call 	GetChar #call function to print the character that is found in r2 and store in r2
ones_loop:
	call	PrintChar #will print character found in r2
	sub 	r2, r2, r0 #subtract 0 from character found in r2
	add 	r3, r3, r2 #add previous result to current result
	ble 	r2, r0, ones_loop
	bgt	r2, r4, ones_loop
	mov 	r2, r3 #move value in result into r2
	ldw 	r2, 0(sp)
	ldw	r3, 4(sp)
	ldw 	r4, 8(sp)
	ldw	r5, 12(sp)
	addi	sp, sp, 16
#write the subroutine

GetChar: 
	subi	sp, sp, 16
	stw		ra, 12(sp) #because print decimal calls this routine?
	stw		r2, 8(sp) #need a register that will return the variable
	stw		r3, 4(sp)
	stw 	r4, 0(sp) #r4 is st
	movia 	r3, JTAG_UART_BASE #r3 is data
gc_loop:
	ldwio 	r3, DATA_OFFSET(r3) #i think im setting data to read JTAG UART data register
	andi	r4,675 r3, RANDOM_NUMBER #i think im and-ing data and 0x8000
	beq 	r4, r0, gc_loop #while st is equal to? zero
	#stwio 	r2, DATA_OFFSET(r3) #and this line - im not entirely sure if this is right
	andi	r2, r3, OTHER_NUMBER #data and 0xFF and place it into r2
	ldw		ra, 12(sp)
	ldw		r2, 8(sp)
	ldw 	r3, 4(sp)
	ldw 	r4, 0(sp)
	addi 	sp, sp, 16
	ret

PrintDecimal99:
	subi 	sp, sp, 16
	stw		r2, 0(sp) #n will be stored here
	stw		r3, 4(sp) #q will be stored here
	stw		r4, 8(sp) #r will be stored here
	stw		r5, 12(sp) #10 will be stored here
	movi	r5, 10 #set the register to 10
	div 	r3, r2, r5 #divide n by 10
	mul		r5, r3, r5 #multiply q by 10
	sub 	r4, r2, r5 #subtract the product by n
	add 	r2, r3, r0 #add q and 0 and store into r2
	call	PrintChar #print character found in r2
	add 	r2, r4, r0 #add r and 0
	ldw 	r2, 0(sp)
	ldw		r3, 4(sp)
	ldw		r4, 8(sp)
	ldw		r5, 12(sp)
	addi 	sp, sp, 16
	
#write the subroutine

	.org 0x1000
MSG: .asciz "ELEC274, Lab 3\n"
MSG1: .asciz "Type two decimal digits: "
MSG2: .asciz "You typed: "
MSG3: .asciz "\n"

_end:
	.end
