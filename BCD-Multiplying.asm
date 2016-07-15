masm
model small, stdcall
.386
.stack 100h
.data 
	a db 20 dup (0)
	b db 20 dup (0)
	temp1 db 40 dup (0)
	temp2 db 40 dup (0)
	res db 40 dup (0)
	mes1 db "Enter the factor and press space: $"
	mes3 db 0Ah,"Result: $"
.code
main:
	mov AX, @data
	mov DS, AX
	xor ax, ax
	
	mov ax, offset a
	push ax
	call Input
	mov ax, offset b
	push ax
	call Input

;--------------------
	;mov cx, 20
;cycle2:
	;mov si, cx
	;dec si
	;mov al, [a+si]
	;mul b
	;add al, bh
	;aam
	;mov bh, ah
	;mov res[si+1], al
	;loop cycle2
	;mov res, bh
;-------------------

	mov ax, offset temp1
	mov bx, 20
	push ax 
	push bx
	call multiply
	
	mov ax, offset temp2
	mov cx, 19
cycle:
	dec bx
	push ax
	push bx
	call multiply
	
	push bx
	call sum
	
	loop cycle
	
;--------------------------

	mov ah, 09h
	mov dx, offset mes3 
	int 21h 
	
	mov cx, 40
	mov si, 0
output: ;(of result)
	mov ah, 02h
	mov dl, [temp1+si]
	add dl, 30h
	int 21h
	inc si
	loop output
 

close:
	mov AX, 4c00h
	int 21h
	
;--------------------

Input proc
    ; writes "Enter the factor and press space: "
		mov ah, 09h
		mov dx, offset mes1
		int 21h 
	; get address of the variable sent in stack as parameter
		mov si, sp
		mov bp, ss:[si+2]
	; first writes to the 'temp1' buffer...
		mov cx, 20
		mov si, 0
	c1:
		mov ah, 01h
		int 21h
		cmp al, 20h
		je c2

		sub al, 30h
		mov [temp1+si], al
		inc si
		loop c1
	; ...then copies to the variable.
	c2:
		dec si
		mov cx, 20
	c3:
		mov di, cx
		dec di
		mov dh, [temp1+si]
		mov ds:[bp+di], dh
		mov [temp1+si], 0
		dec si
		cmp si, -1
		loopne c3

		ret 2
Input endp
;------------------------

	; parameters for 'multiply' (all 2 bytes)
	; 1 - LRA
	; 2 - digit of 'b' for multiplication
	; 3 - offset of variable to write result to
multiply proc
		pusha

		mov si, sp
		; 'di' is digit of 'b' for multiplication
		mov di, ss:[si+18]
		; 'bp' is offset of variable to write result to
		mov bp, ss:[si+20]
		
		mov cx, 40
	cycle2:
		mov si, cx
		dec si
		mov al, [a+si-20]
		mul b[di-1]
		add al, bh
		aam
		mov bh, ah
		mov ds:[bp+si], al
		loop cycle2
		mov ds:[bp], bh
		
		popa
		ret 4
multiply endp

;--------------------------
sum proc
		pusha
	
		mov si, sp
		mov bx, ss:[si+18]
		add bx, 20
		
		mov di, 40
		mov cx, 40
	l:
		cmp cx, bx
		jg z
		jng nz
	z:
		loop l
	nz:
		mov si, cx
		dec si
		dec di
		mov al, ds:[temp1+si]
		add al, ds:[temp2+di]
		aaa
		add al, bh
		mov bh, ah
		mov ds:[temp1+si], al
		xor ax, ax
		loop nz
		mov ds:[temp1], bh
		
	popa
	ret 2
sum endp 

end main



	