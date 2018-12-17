; CS 261 -- Shawn Hillstrom -- Program 6
; --------------------------------------
; Implements Dijkstra's Algorithm in x86 Assembly.

SECTION .data

nl:		db	10

prompt:		db	"Enter a positive integer: "
plen:		equ	$ - prompt

message:	db	"Greatest common divisor = "
mlen:		equ	$ - message

error:		db	"Bad Number.",10
elen:		equ	$ - error

SECTION .bss

strlen:		equ	20

inbuf:		resb	strlen

digit:		resb	1

SECTION .text

; global _start

global _start

; Procedure: read
; ---------------
; Reads specified number of bytes from specified input into specified input 
;	buffer. 
;
; Input form, input buffer memory address, and number of bytes to read are
;	passed in ebx, ecx, and edx, respectively.
read:
	push	ebp		; save value previously in ebp
	mov	ebp, esp	; and set up the stack frame

	push	ebx		; save ebx,
	push	ecx		; ecx,
	push 	edx		; and edx

	mov	eax, 3		; read
	mov	ebx, [ebp+8]	; from specified input stream
	mov	ecx, [ebp+12]	; to specified input buffer
	mov	edx, [ebp+16]	; specified number of bytes
	int	80H		; interrupt with syscall

	pop	edx		; restore edx,
	pop	ecx		; ecx,
	pop	ebx		; and ebx

	mov 	esp, ebp	; tear down the stack frame
	pop 	ebp		; and restore ebp

	ret

; Procedure: write
; ----------------
; Writes specified number of bytes from specified buffer to specified output
; 	stream.
;
; Output stream, buffer to write from, and number of bytes to write are
;	passed in ebx, ecx, and edx, respectively.
write:
	push	ebp		; save value previously in ebp
	mov	ebp, esp	; and set up the stack frame
	
	push	ebx		; save ebx,
	push 	ecx		; ecx,
	push	edx		; and edx

	mov	eax, 4		; write
	mov	ebx, [ebp+8]	; to specified stream
	mov	ecx, [ebp+12]	; from specified source
	mov	edx, [ebp+16]	; specified number of bytes
	int	80H		; interrupt with syscall
	
	pop	edx		; restore edx,
	pop	ecx		; ecx,
	pop	ebx		; and ebx

	mov	esp, ebp	; tear down the stack frame
	pop	ebp		; and restore ebp

	ret

; Procedure: getInt
; -----------------
; Turns an int contained in a string into a regular unsigned int value.
; 
; Memory address of said string is stored on the stack.
getInt:
	push	ebp		; save value previously in ebp
	mov	ebp, esp	; and set up the stack frame
	
	push	ebx		; save ebx,
	push	ecx		; ecx,
	push	edx		; edx,
	push	esi		; and esi

	mov	ebx, 1		; unsigned int digitValue = 1
	mov	ecx, 0		; unsigned int result = 0
	mov	esi, [ebp+8]	; char * digit = string

intLoop1:
	cmp	byte [esi], 10	; is *digit == '\n'
	je	intDone1	; if it is, break 
	add	esi, 1		; digit++ 
	jmp 	intLoop1	; and loop

intDone1:
	sub	esi, 1		; digit-- (last digit character)

intLoop2:
	cmp	esi, [ebp+8] 	; is digit >= string
	jl	intDone2	; if not, break
	cmp	byte [esi], 32	; if (*digit == ' ')
	je	intDone2	; break
	cmp	byte [esi], 48	; if (*digit < '0')
	jl	badNum		; jump to badNum
	cmp	byte [esi], 57	; if (*digit > '9')
	jg	badNum		; jump to badNum
	sub	byte [esi], 48	; *digit - '0'
	mov	eax, 0		; initialize eax to 0
	mov	al, [esi]	; eax = character byte at *digit
	mul	ebx		; (*digit - '0') * digitValue
	add	ecx, eax	; result += (*digit - '0') * digitValue
	mov	eax, 10 	; eax = 10 
	mul	ebx		; digitValue *= 10
	mov	ebx, eax	; save the result in digitValue
	sub	esi, 1		; go to the previous byte
	jmp	intLoop2	; and loop	
	
badNum:
	push	elen		; write elen bytes
	push	error		; from error message
	push	0		; to stdout
	call 	write		; call
	add	esp, 12		; restore the stack frame

intDone2:	
	mov	eax, ecx	; return result

	pop 	esi		; restore esi,
	pop 	edx		; edx,
	pop	ecx		; ecx,
	pop	ebx		; and ebx	

	mov	esp, ebp	; tear down the stack frame
	pop	ebp		; restore ebp

	ret

; Procedure: makeDecimal
; ----------------------
; Recursively prints out an inputted integer. 
;
; Integer input provided on the stack.
makeDecimal:
	push	ebp		; save value previously in ebp
	mov	ebp, esp	; and set up the stack frame

	push	ecx		; save ecx,
	push	edx		; and edx
	
	mov	eax, [ebp+8]	; move the inputted integer to eax for division
	mov	ecx, 10		; move the divider to edx
	mov	edx, 0		; clear edx
	div	ecx		; eax/edx (eax = n / 10, edx = n % 10)
	cmp	eax, 0		; check to see if quotient > 0
	jle	decimalDone	; if it isn't jump to decimalDone
	push	eax		; push the quotient in as an arg
	call	makeDecimal	; call the recursion
	pop	eax		; restore eax

decimalDone:
	add	edx, 48		; remainder += '0'
	mov	[digit], dl	; move into digit
	push	1		; write one byte
	push	digit		; from digit
	push	1		; to stdout
	call	write		; call
	add	esp, 12		; restore the stack frame
	
	pop	edx		; restore edx
	pop	ecx		; and ecx

	mov	esp, ebp	; tear down the stack frame
	pop	ebp		; and restore ebp

	ret

; Procedure: readNumber
; ---------------------
; Reads an integer from stdin and returns it in eax
readNumber:
	push	plen		; write plen bytes
	push	prompt		; from prompt
	push	1		; to stdout
	call	write		; call
	add	esp, 12		; restore the stack frame

	push	strlen		; read strlen bytes
	push	inbuf		; to inbuf
	push	0		; from stdin
	call	read		; call
	add	esp, 12		; restore the stack frame

	push	inbuf		; turn the string in inbuf into an int
	call	getInt		; call
	add	esp, 4		; restore the stack frame

	ret

; Procedure: gcd
; --------------
; Calculates the greatest common denominator between two numbers.
; 
; Both numbers are contained on the stack.
gcd:
	push	ebp		; save the value previously in ebp
	mov	ebp, esp	; set up the stack frame
	
	push	ecx		; save ecx
	push	edx		; and edx
	
	mov	eax, [ebp+8]	; ecx = n
	mov	edx, [ebp+12]	; edx = m
	
	cmp	eax, edx	; compare the input numbers
	jg	gcdCase1	; if (n > m) jump to gcdCase1
	jl	gcdCase2	; else if (n < m) jump to gcdCase2
	jmp	gcdDone		; else return n and jump to gcdDone

gcdCase1:
	sub	eax, edx	; n -= m
	push	edx		; push new value of m
	push	eax		; push new value of n
	call	gcd		; call
	add	esp, 8		; restore the stack frame
	jmp	gcdDone		; jump to gcdDone

gcdCase2:
	sub	edx, eax	; m -= n
	push	edx		; push new value of m
	push	eax		; push new value of n
	call	gcd		; call
	add	esp, 8		; restore the stack frame

gcdDone:
	pop	edx		; restore edx

	mov	esp, ebp	; tear down the stack frame
	pop	ebp		; restore ebp

	ret

; Main Procedure
_start:
	call 	readNumber	; read a number
	mov	ebx, eax	; ebx (a) = readNumber()
	
	call	readNumber	; read another number
	mov	ecx, eax	; ecx (b) = readNumber()

	push	ecx		; push number2
	push	ebx		; push number1
	call	gcd		; gcd(a, b)
	mov	edx, eax	; answer = gcd(a, b)
	add	esp, 8		; restore the stack frame
	
	push	mlen		; write mlen bytes
	push	message		; from message
	push	1		; to stdout
	call	write		; call
	add	esp, 12		; restore the stack frame
	
	push	edx		; push the answer
	call	makeDecimal	; makeDecimal(answer)
	add	esp, 4		; restore the stack frame

	push	1		; write one byte
	push	nl		; from nl (newline character)
	push	1		; to stdout
	call	write		; call
	add	esp, 12

	mov	eax, 1		; -|
	mov	ebx, 0		; -|-> exit(0)
	int	80H		; -|

