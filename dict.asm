IDEAL
MODEL small
STACK 100h
p186
DATASEG

; --------------------------
; Your variables here
; --------------------------
readfilename db 'test.txt',0	
handle dw 0   ; will be the file handle. the number that DOS assigns to the open file.
buffer db 100 DUP ('$')
errorhandle dw 0

secretstring db 'test','$'
startstring db 'Welcome to HANGMAN (V2)',10,13,'press p to start playing',10,13,'press h for help','$'
helpstring db 'Hello there!',10,13,'here are the rules:',10,13,'press p to start playing then try to guess the currect word',10,13,'you have only 3 tries use it wisely ;)','$'

healthstr db "Health : ",'$'
filename dw ?
stage1 db 'stage1.bmp',0
stage2 db 'stage2.bmp',0
stage3 db 'stage3.bmp',0

string1 db 'guess the word','$'
extrastring1 db ' chars)','$'
gameoverstring db "Game Over",10,13,'You Lost','$'
successMsg1 db 'Congratulations the word:','$'
successMsg2 db ' is the secret!','$'

tryagain db 'Nope, try again...',10,13,'$'
stringFromUser db 20 dup('$')
health dw 3
errormsg db 'error opening the file',10,13,'$'
line db 10, 13, '$'

filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsge db 'Error', 13, 10,'$'

INSTR1 DB 20 DUP('$')
LN DB 5 DUP('$')
N DB '$'
S DB ?


CODESEG
proc OpenBitmap
	; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, [filename]
	int 21h
	jc openerror1
	mov [filehandle], ax

	jmp fileopened
	openerror1:
	mov dx, offset ErrorMsge
	mov ah, 9h
	int 21h
	ret
	fileopened:
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
	PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB.
	mov al,[si+2] ; Get red value.
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it.
	mov al,[si+1] ; Get green value.
	shr al,2
	out dx,al ; Send it.
	mov al,[si] ; Get blue value.
	shr al,2
	out dx,al ; Send it.
	add si,4 ; Point to next color.
	; (There is a null chr. after every color.)

	loop PalLoop
	; BMP graphics are saved upside-down.
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
	PrintBMPLoop:
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine

	rep movsb ; Copy line to the screen
	 ;rep movsb is same as the following code:
	 ;mov es:di, ds:si
	 ;inc si
	 ;inc di
	 ;dec cx
	 ;loop until cx=0
	pop cx
	loop PrintBMPLoop
	ret
endp OpenBitmap
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
mov dx,offset readfilename ;copy to dx filename RAM address
int 21h
jc openerror 
mov [handle],ax

readFromFile:
mov ah,3Fh
mov bx,[handle]
mov cx,100
;mov [buffer],'$'
mov dx,offset buffer
int 21h

closeFile:
mov ah,3Eh
mov bx,[handle]
int 21h
ret

openerror:
mov [errorhandle],ax
mov dx,offset errormsg
call printstr
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

cmp al,[secretstring]

jne NotMatched
mov dx,offset successMsg1
call printStr
mov dx,offset secretstring
call printStr
mov dx,offset successMsg2
call printStr


mov ax, 4c00h ; exit the program
int 21h
;mov dx,offset stringFromUser
;call printStr
;mov dx,offset successMsg2
;call printStr

NotMatched:
dec [health]
cmp [health],0

jne gameNotOver
call clearscreen

mov dx,offset gameoverstring
call printStr

mov ah,1
int 21h
jmp health1

gameNotOver:
cmp [health],1
je health1

cmp [health],2
je health2

cmp [health],3
je health3

health3:
mov cx,offset stage1
mov [filename],cx
call OpenBitmap
jmp endpic

health2:
mov cx,offset stage2
mov [filename],cx
call OpenBitmap
jmp endpic

health1:
mov cx,offset stage3
mov [filename],cx
call OpenBitmap
jmp endpic

endpic:
; Wait for key press
	mov ah,1
	int 21h
	; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h
	cmp [health],0
	je exit

mov cx,[health]
add cx,2
mov dx, offset tryagain
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
	mov dx,[health]
	call printnum
	
	mov dx,offset string1
	call printstr
	

	call newline
	
	mov cx,[health]
	add cx,2
	loopgame:
	call getString
	call isMatch
	loop loopgame
exit:
	mov ax, 4c00h
	int 21h
END start
