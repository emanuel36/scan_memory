.equ UART0_BASE, 0x44E09000

_start:
/********************************************************
Recebe o endereço inicial
********************************************************/
	mov r1, #8 //loop
	mov r2, #0 //endereço inicial
	bl print_string_endereco1
recebe_endereco1:
	bl recebe_byte
	cmp r0, #0x39
	suble r0, r0, #0x30
	cmp r0, #0x39
	subgt r0, r0, #0x57
	mov r2, r2, LSL#4
	orr r2, r0, r2
	sub r1, r1, #1
	cmp r1, #0
	bne recebe_endereco1

/********************************************************
Recebe o endereço final
********************************************************/
	mov r1, #8 //loop
	mov r3, #0 //endereço final
	bl print_string_endereco2
recebe_endereco2:
	bl recebe_byte
	cmp r0, #0x39
	suble r0, r0, #0x30
	cmp r0, #0x39
	subgt r0, r0, #0x57
	mov r3, r3, LSL#4
	orr r3, r0, r3
	sub r1, r1, #1
	cmp r1, #0
	bne recebe_endereco2
	bl quebra
	bl quebra

	bl print_saida

	cmp r2, r3
	bgt loop_contrario

/********************************************************
Imprime conteúdo do endereço r2 até o r3
********************************************************/
loop:
	bl print_zero_x //0x

	mov r6, r2
	bl print_register
	
	mov r0, #0x3A//Dois Pontos
	bl uart_putc
	
	mov r0, #0x20//Espaço
	bl uart_putc
	
	ldr r6, [r2], #4
	bl print_register
	cmp r2, r3
	bgt fim
	bl quebra
	b loop

/********************************************************
Imprime conteúdo do endereço r2 até o r3
********************************************************/
loop_contrario:
	bl print_zero_x //0x

	mov r6, r2
	bl print_register

	mov r0, #0x3A//Dois Pontos
	bl uart_putc
	
	mov r0, #0x20//Espaço
	bl uart_putc
	
	ldr r6, [r2], #-4
	bl print_register
	cmp r2, r3
	blt fim
	bl quebra
	b loop_contrario

/********************************************************
Imprime conteúdo do registrador r6
********************************************************/
print_register:
	stmfd sp!, {r5,r6,lr}
    mov r5, r6, LSR#24
    bl print_byte

    mov r5, r6, LSR#16
    and r5, r5, #0xFF
    bl print_byte

    mov r5, r6, LSR#8
    and r5, r5, #0xFF
    bl print_byte

    mov r5, r6
    and r5, r5, #0xFF
    bl print_byte
    ldmfd sp!, {r5,r6,pc}

/********************************************************
Imprime byte r5
********************************************************/
print_byte:
	mov r0, #0
	stmfd sp!, {r0-r5,lr}
	and r0, r5, #0xF0
	lsr r0, #4
	adr r1, ascii
	add r1, r1, r0
	ldrb r0, [r1]
	bl uart_putc

	mov r0, #0
	and r0, r5, #0xF
	adr r1, ascii
	add r1, r1, r0
	ldrb r0, [r1]
	bl uart_putc
	ldmfd sp!, {r0-r5,pc}

/********************************************************
Print string in r3 in screen
********************************************************/
print_string:
    stmfd sp!,{r0-r2,lr}
print:
    ldrb r0,[r3],#1
    and r0, r0, #0xff
    cmp r0, #0
    beq end_print
    bl uart_putc
    b print
    
end_print:
    ldmfd sp!,{r0-r2,pc}

/********************************************************
Recebe um byte do teclado
********************************************************/
recebe_byte:
	stmfd sp!, {lr}
	bl uart_getc
	cmp r0, #0
	beq recebe_byte
	bl uart_putc
	ldmfd sp!, {pc}

/********************************************************
Imprime r0
********************************************************/
uart_putc:
	stmfd sp!, {r0-r2,lr}
	ldr r1, =UART0_BASE

wait_tx_fifo_empty:
	ldr r2, [r1, #0x14]
	and r2, r2, #(1<<5)
	cmp r2, #0
	beq wait_tx_fifo_empty

	strb r0, [r1]
	ldmfd sp!, {r0-r2,pc}

/********************************************************
Recebe e salva em r0
********************************************************/
uart_getc:
    stmfd sp!,{r1-r2,lr}
    ldr     r1, =UART0_BASE

wait_rx_fifo:
    ldr r2, [r1, #0x14] 
    and r2, r2, #(1<<0)
    cmp r2, #0
    beq wait_rx_fifo

    ldrb  r0, [r1]
    ldmfd sp!,{r1-r2,pc}

print_string_endereco1:
    stmfd sp!,{r3,lr}
	adr r3, endereço_1
	bl print_string
	ldmfd sp!,{r3,pc}

print_string_endereco2:
    stmfd sp!,{r3,lr}
	adr r3, endereço_2
	bl print_string
	ldmfd sp!,{r3,pc}

quebra:
    stmfd sp!,{r3,lr}
	adr r3, quebra_linha
	bl print_string
	ldmfd sp!,{r3,pc}	

print_zero_x:
    stmfd sp!,{r3,lr}
	adr r3, zero_x
	bl print_string
	ldmfd sp!,{r3,pc}	

print_saida:
    stmfd sp!,{r3,lr}
	adr r3, saida
	bl print_string
	ldmfd sp!,{r3,pc}	

fim:
	b fim

quebra_linha: .asciz "\n\r"
zero_x: .asciz "0x"
ascii: .asciz "0123456789abcdef"
endereço_1: .asciz "\n\rEndereco Inicial: \r\n"
endereço_2: .asciz "\n\rEndereco Final: \r\n"
saida: .asciz "Saida:\r\n"
