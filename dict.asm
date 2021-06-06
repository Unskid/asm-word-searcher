IDEAL
MODEL small
STACK 100h
p186
DATASEG

; --------------------------
; Your variables here
; --------------------------
filename db 'test.secret',0	
handle dw 0   ; will be the file handle. the number that DOS assigns to the open file.
buffer db 20 DUP ('$')
errorhandle dw 0
startstring db 'Welcome to HANGMAN (V2)',10,13,'press p to start playing',10,13,'press h for help','$'
helpstring db 'Hello there!',10,13,'here are the rules:',10,13,'press p to start playing then try to guess the currect word',10,13,'you have only 3 tries use it wisely ;)','$'
healthstr db "Health : ",'$'
stage1 db  '|','-----',10,13,'|',10,13,'|',10,13,'|',10,13,'|',10,13,'|','$'

stage2 db  '|-----',10,13,'|    |',10,13,'|',10,13,'|',10,13,'|',10,13,'|','$'

stage3 db '|-----',10,13,'|    |',10,13,'|    ☺',10,13,'|    |',10,13,'|   /\',10,13,'|','$'
string1 db 'guess the word (','$'
extrastring1 db ' chars)','$'
gameoverstring db "Game Over",10,13,'You Lost','$'
successMsg1 db 'Congratulations the word:','$'
successMsg2 db 'is the secret!','$'
tryagain db 'try again...',10,13,'$'
stringFromUser db 20 dup('$')
health db 3
errormsg db 'error opening the file',10,13,'$'
line db 10, 13, '$'



INSTR1 DB 20 DUP('$')
LN DB 5 DUP('$')
N DB '$'
S DB ?


CODESEG
proc printNum
pusha
add dl,30h
mov ah,2
int 21h
call newLine
popa
ret 
endp printNum
proc printStr
push ax
mov ah, 9
int 21h
pop ax
ret
endp printStr

proc readfile2

openFile:

mov ah,3Dh
xor al,al ;just like mov al,0
mov dx,offset filename ;copy to dx filename RAM address
int 21h
jc openerror 
mov [handle],ax

readFromFile:
mov ah,3Fh
mov bx,[handle]
mov cx,20
mov [buffer],'$'
mov dx,offset buffer
call printstr

openerror:
mov [errorhandle],ax
mov dx,offset errormsg
call printstr

closeFile:
mov ah,3Eh
mov bx,[handle]
int 21h
ret
endp readfile2
proc stringlength

;PRINT LENGTH OF STRING (DIRECT)
        ADD BL,30H
        MOV AH,02H
        MOV DL,BL
        INT 21H



;PRINT LENGTH OF STRING ANOTHER WAY
        ADD SI,2
        MOV AX,00


     LL2:
	 	CMP SI,'$'
        JE LL1
        INC SI
        ADD AL,1
        JMP LL2

     LL1:SUB AL,1
        ADD AL,30H

        MOV AH,02H
        MOV DL,AL
        INT 21H


        MOV AH,4CH
        INT 21H
ret
endp stringlength
proc readFile
		mov ah,3Dh   ; 3Dh of DOS Services opens a file.
		mov al,0   ; 0 - for reading. 1 - for writing. 2 - both
		mov dx,offset filename  ; make a pointer to the filename
		int 21h  
		jc openerr ; call DOS
		mov [handle],ax   ; Function 3Dh returns the file handle in AX, here we save it for later use.

	;'DOS Service Function number 3Fh reads from a file.

		mov ah,3Fh
		mov cx,10 ; I will assume ELMO.TXT has atleast 4 bytes in it. CX is how many bytes to read.
		mov dx,offset buffer  ; DOS Functions like DX having pointers for some reason.
		mov bx,[handle]    ; BX needs the file handle.
		int 21h   ; call DOS

	;Here we will put a $ after 4 bytes in the buffer and print the data read:
		mov dx,offset buffer
		add dx,ax    ; Function 3Fh returns the actual amount of bytes read in AX (should be 4 if
				; nothing went wrong.
		mov bx,dx
		mov bx,'$'   ; byte pointer so we don't mess with the whole word (a word is 16bits).
            
               mov cl,20
               mov bl,1
            lea si,[buffer]
            label1:  
            mov al,[si] 
            mov dl,al
            mov ah,2h
            int 21h
            call moving1      
            cmp al,'a'
            jge changeLetter
           
           inc si 
           dec cl
           
           
           jnz label1
           jz Print
           ;;;;;;;;;;;;;;;;;
           changeLetter:
           cmp bl,1
           je changefirst  
    	   inc si 
           dec cl
           jnz label1
           ;;;;;;;;;;;;;;;;       
		             
		   changefirst:
		   inc si  
		 
		   mov al,[si]
		   sub al,32d  
		   mov [si],al
		   mov bl,0
		   
		   dec si 
		    inc si 
           dec cl
		   jnz label1  
		     ;ret                
		     
	Print:
		mov dx,offset buffer
		call printstr 
		mov dx,offset string1
		call printstr
		  
moving1: 
cmp al,' '

je increment
openerr:
mov dx,offset errormsg
call printstr
ret
increment:
mov bl,1  
ret
endp readFile

proc clearscreen
mov al,03h
	mov ah,0
	int 10h

ret
endp clearscreen

proc getString
mov si,offset stringFromUser
l1:
mov ah,1
int 21h
cmp al,13
je proggramed
mov [si],al
inc si
jmp l1
proggramed:
ret
endp getString

proc newLine
	; print a new line
	pusha
	mov dx, offset line
	mov ah, 9
	int 21h
	popa
	ret
endp newLine

proc isMatch
mov al, [stringFromUser]
cmp al,[buffer]
jne NotMatched
mov dx,offset successMsg1
call printStr
;mov dx,offset stringFromUser
;call printStr
;mov dx,offset successMsg2
;call printStr

NotMatched:
dec [health]
cmp [health],0
je gameOver
mov dx, offset tryagain
call printStr
call getString
gameOver:
call clearscreen
mov dx,offset gameoverstring
call printStr
ret
endp isMatch

start:
	mov ax, @data
	mov ds, ax
	call clearscreen
StartScreen:
mov dx,offset startstring
call printstr
WaitForCharacter:
	mov ah,0h
	int 16h
	;was Esc pressed
	cmp al,27
	je exit
	;was p pressed
	cmp al,'p'
	je startgame ; to start playing 
	cmp al,'h'
	je gamehelp
	jmp WaitForCharacter

gamehelp:
call clearscreen
mov dx, offset helpstring
call printstr

gamestarterfromhelp:
mov ah,0h
int 16h
cmp al,'p'
je startgame

jmp gamestarterfromhelp

StartGame:
call clearscreen
	printGameHealth:
	mov dx,offset healthstr
	call printstr
	mov dl,[health]
	call printnum
	
	call readfile2
	mov dx,offset string1
	call printstr
	
	mov bl,[buffer+1]
	call stringlength
	
	mov dx,offset extrastring1
	call printstr

	call newline

	call getString
exit:
	mov ax, 4c00h
	int 21h
END start
