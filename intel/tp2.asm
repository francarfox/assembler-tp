;*********************************************************************
;*********************************************************************
;              Intel 80x86 - Ordenamiento por Seleccion
;*********************************************************************
;*********************************************************************
segment pila stack
			resb 64

segment datos data
	filename db	'datafile.dat',0
	registro dw 1
	vector	times 60 db ' '
	fila	db	1
	totalnum db 1
	limit 	db  1
	indexi 	db	1 	
	indexj	db	1
	indexp	db	1
	buffer 	dw 	1
	num 	resb 1
	handle  dw  1
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
	call imprimirLinea
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

;---------------------------------------------------------------------
leerarch:        
	mov al,0
	mov dx,filename
	mov ah,3dh
	int 21h
	jc  erropen
	mov [handle],ax
	mov byte[fila],0

lectura:
	mov bx,[handle]
	mov cx,2              ;lee 2 bytes
	mov dx,registro
	mov ah,3fh
	int 21h
	jc  errlec
	cmp ax,0
	jne proceso

	mov word[totalnum],fila
	mov bx,[handle]
	mov ah,3eh
	int 21h
	jmp inicio

erropen:
	mov dx,msgErr
	call imprimirMsg
	jmp inicio

errlec:
	mov dx,msgErrlec
	call imprimirMsg
	jmp inicio

proceso:
	mov dx,registro
	call imprimirMsg

	mov si,[fila]
	mov ax,registro
	mov word[vector+si],ax

	inc byte[fila]
	jmp lectura

;---------------------------------------------------------------------
ordenasc:
	mov byte[ascend],'Y'
ordendes:
	mov ax,vector
	mov byte[indexi],0
	mov word[limit],totalnum
	dec byte[limit]

continuoi:
	cmp word[indexi],limit
	jl	procesord
	jmp mostrar

procesord:
	mov word[indexp],indexi			;p=i
	mov word[indexj],indexi			;j=i+1
	inc byte[indexj]
continuoj:
	cmp word[indexj],limit
	jg 	finprocord

	cmp byte[ascend],'Y'
	je 	funcasc
	jne funcdesc

funcasc:
	mov si,[indexj]				;if(vector[j] < vector[p]) p = j;
	mov	ax,word[vector+si]
	mov si,[indexp]
	mov	bx,word[vector+si]
	cmp ax,bx
	jl 	igualindex
	inc byte[indexj]
	jmp continuoj

funcdesc:
	mov si,[indexj]				;if(vector[j] > vector[p]) p = j;
	mov	ax,word[vector+si]
	mov si,[indexp]
	mov	bx,word[vector+si]
	cmp ax,bx
	jg 	igualindex
	inc byte[indexj]
	jmp continuoj

igualindex:
	mov word[indexp],indexj
	inc byte[indexj]
	jmp continuoj

finprocord:
	;if(p != i)
	cmp word[indexp],indexi
	je 	finswap

	mov si,[indexp]				;swap
	mov	ax,word[vector+si]
	mov word[buffer],ax

	mov di,[indexi]
	mov	ax,word[vector+di]
	mov word[vector+si],ax

	mov word[vector+di],buffer

finswap:
	inc byte[indexi]
	jmp continuoi


;---------------------------------------------------------------------
ordendesc:
	mov byte[ascend],'N'
	jmp ordendes


;*********************************************************************
;                 				RUTINAS
;*********************************************************************
;Muestra los elementos del vector de numeros
mostrar:
	call saltoLinea
	mov dx,vector
	call imprimirMsg
	call saltoLinea
	jmp inicio

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

imprimirChar:
	mov	ah,2
	int 21h
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