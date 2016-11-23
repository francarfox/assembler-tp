;*********************************************************************
;*********************************************************************
;              Intel 80x86 - Ordenamiento por Seleccion
;*********************************************************************
;*********************************************************************
segment pila stack
			resb 64

segment datos data
	filename db	'datafile.dat',0
	registro db 2
	vector	resb 60
	limit 	db  1
	aux 	db 	1
	buffer 	dw 	1
	buffer2 resb 10
	num 	resb 1
	handle  resb 10
	ascend 	db  1

	salto	db	10,13,'$'
	msgErr	db	10,13,'ERROR: EL ARCHIVO NO SE PUEDO ABRIR!$'
	msgErrlec db 10,13,'ERROR: EL ARCHIVO NO SE PUEDO LEER!$'
	msgMax	db	10,13,'ERROR: MAS DE 30 NUMEROS EN ARCHIVO!$'

	msgLinea db	10,13,' _______________________________________________$'
	msgIni	db	10,13,' _______________________________________________',10,13,'|           Ordenamiento por Seleccion          |',10,13,'| 1.Leer archivo                                |',10,13,'| 2.Ordenamiento ascendente                     |',10,13,'| 3.Ordenamiento descendente                    |',10,13,'| 0.Salir                                       |',10,13,'Ingrese opcion: $'

;*********************************************************************
segment codigo code
..start:
	mov	ax,datos
	mov	ds,ax
	mov	ax,pila
	mov	ss,ax

inicio:
	call saltoLinea
	mov dx,msgIni
	call ingresoOp
	call saltoLinea

	cmp	byte[num],0
	je  fin
	cmp	byte[num],1
	je  leerarch
	cmp	byte[num],2
	je  ordenasc
	cmp	byte[num],3
	je  ordendesc
	jmp inicio

fin:
	mov	ah,4ch
	int	21h

;hardcode
	lea si,[vector]
	mov word[si],0077h
	add si,2
	mov word[si],0014h
	add si,2
	mov word[si],0015h
	add si,2
	mov word[si],0001h
	add si,2
	mov word[si],000ah
	jmp mostrar

;---------------------------------------------------------------------
leerarch:
	mov byte[limit],0
	mov al,0
	mov dx,filename
	mov ah,3dh
	int 21h
	jc  erropen
	mov [handle],ax
	mov	si,0

lectura:
	mov bx,[handle]
	mov cx,2              ;lee 2 bytes
	mov dx,registro
	mov ah,3fh
	int 21h
	jc  errlec
	cmp ax,0
	je finlect

proceso:
;mov word[registro],0077h
	mov cx,[registro]
	cmp cx,0077h
	je sarasa
	jmp continua
sarasa:
	call imprimirLinea
continua:
	mov word[vector+si],cx

	add si,2
	add byte[limit],2
	jmp lectura

finlect:
	mov bx,[handle]
	mov ah,3eh
	int 21h
	jmp mostrar

erropen:
	mov dx,msgErr
	call imprimirMsg
	jmp inicio

errlec:
	mov dx,msgErrlec
	call imprimirMsg
	jmp inicio

;---------------------------------------------------------------------
ordenasc:
	mov byte[ascend],'Y'
ordenar:
	mov byte[aux],'N'
	mov si,0
	mov di,2

procesord:
	mov	ax,word[vector+si]
	mov bx,word[vector+di]

	cmp byte[ascend],'Y'
	je 	funcasc
	jne funcdesc


funcasc:
	cmp ax,bx
	jg signum2
	cmp si,di
	jg swaping
	jmp signum2

funcdesc:
	cmp ax,bx
	jl signum2
	cmp si,di
	jg swaping

signum2:
	add di,2
	cmp di,60
	je signum
	jmp procesord

swaping:
	mov cx,word[vector+si]
	mov word[vector+si],bx
	mov word[vector+di],cx

signum:
	mov di,0	
	add si,2
	cmp si,60
	je finord
	jmp procesord

finord:
	jmp mostrar

;---------------------------------------------------------------------
ordendesc:
	mov byte[ascend],'N'
	jmp ordenar


;*********************************************************************
;                 				RUTINAS
;*********************************************************************
;Muestra los elementos del vector de numeros
mostrar:
	call saltoLinea
	mov di,0
exitlec:
	mov byte[buffer2+9],'$'
	lea si,[buffer2+9]
	mov ax,[vector+di] 		;ax = value that I want to convert
	mov bx,10

	cmp ax,01h
	jl 	negativo

loop2:
	mov dx,0
	div bx
	add dx,48
	dec si
	mov [si],dl
	cmp ax,0
	jz exitmost
	jmp loop2
exitmost:
	cmp byte[si],'0'
	je saltop 
print:
	mov ah,9
	mov dx,si
	int 21h
	call saltoLinea
saltop:
	add di,2
	cmp di,60
	je 	inicio
	jmp exitlec

negativo:
	not ax
	add ax,00000001b
	jmp loop2

ingresoOp:
	call imprimirMsg
	call ingresarChar
	sub al,48
	mov	[num],al
	ret

ingresarChar:
	mov	ah,1
	int	21h
	ret

imprimirMsg:
	mov	ah,9
	int	21h
	ret

imprimirLinea:
	mov dx,msgLinea
	call imprimirMsg
	ret

saltoLinea:
	mov dx,salto
	call imprimirMsg
	ret

;*********************************************************************