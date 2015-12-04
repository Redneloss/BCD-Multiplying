masm
model small
.stack 100h
.data 
	a db 10 dup (0)
	b db 0
	res db 11 dup (0)
	mes1 db "Enter the first number (max 10 digits) and press space: $"
	mes2 db 0Ah,"Enter the second number: $"
	mes3 db 0Ah,"Result: $"
.code
main:
	mov AX, @data; |
	mov DS, AX;     >standard
	xor ax, ax;    /
	
	mov ah, 09h;             |
	mov dx, offset mes1 ;     > writes "Enter the first number (max 10 digits) and press space: "
	int 21h ;                /
	
	
	
	mov cx, 10;      										  |
cycle:;														  |
	mov ah, 01h;   >  digit input							  |
	int 21h;      /											  |
	;														   > cycle of number input and storing in stack as BCD
	cmp al, 20h;         >if space is entered, end input	  /
	je transfer_to_a;   /								     / 
	;													    /	
	sub al, 30h;										   /
	push ax;											  /
	loop cycle;										     /
	
	
	
transfer_to_a:	
	mov si, 9
cycle1:
	cmp sp, 100h
	je input_b
	pop dx
	mov [a+si], dl
	dec si
	jmp cycle1

input_b:
	mov ah, 09h;             |
	mov dx, offset mes2 ;     > writes "Enter the second number: "
	int 21h ;                /
	
	mov ah, 01h
	int 21h
	sub al, 30h
	mov b, al

	
	mov cx, 10
cycle2:
	mov si, cx
	dec si
	mov al, [a+si]
	mul b
	add al, bh
	aam
	mov bh, ah
	mov res[si+1], al
	loop cycle2
	mov res, bh
	

	mov ah, 09h;             |
	mov dx, offset mes3 ;     > writes: "Result: "
	int 21h ;                /
	
	mov cx, 11;				 |
	mov si, 0;				 |
output:;					 |
	mov ah, 02h;			 |
	mov dl, [res+si];		  > output of result
	add dl, 30h;			 /
	int 21h;				/
	inc si;				   / 
	loop output;          /
 
	
close:
	mov AX, 4c00h
	int 21h
end main


	