; ============================================================================
; MS-DOS INT 33h Compatible Mouse Driver (Minimal)
; Provides basic mouse position and button state for baremetal
; ============================================================================

mouse_driver_installed db 0
mouse_x dw 160
mouse_y dw 100
mouse_buttons db 0

; ============================================================================
; Install Mouse Driver - Hook INT 33h
; ============================================================================
install_mouse_driver:
	xor ax, ax
	mov es, ax

	mov word [es:0x33*4], int33_handler
	mov [es:0x33*4+2], cs

	mov byte [mouse_driver_installed], 1
	ret

; ============================================================================
; INT 33h Handler
; ============================================================================
int33_handler:
	cmp ax, 0
	je .get_status
	cmp ax, 3
	je .get_pos
	cmp ax, 4
	je .set_pos
	iret

.get_status:
	mov ax, 0xFFFF
	mov bx, 2
	mov cx, 320
	mov dx, 200
	iret

.get_pos:
	mov cx, [cs:mouse_x]
	mov dx, [cs:mouse_y]
	mov bl, [cs:mouse_buttons]
	and bl, 3
	xor bh, bh
	iret

.set_pos:
	mov [cs:mouse_x], cx
	mov [cs:mouse_y], dx
	iret

; ============================================================================
; Process PS/2 Mouse Packet (called from game loop)
; ============================================================================
process_mouse_byte:
	push bx
	push cx
	push dx

	cmp byte [cs:packet_idx], 0
	jne .store
	test al, 8
	jz .done

.store:
	movzx bx, [cs:packet_idx]
	mov [cs:packet_data + bx], al
	inc byte [cs:packet_idx]

	cmp byte [cs:packet_idx], 3
	jb .done

	mov byte [cs:packet_idx], 0

	mov al, [cs:packet_data + 1]
	cbw
	add [cs:mouse_x], ax
	js .x_min
	cmp word [cs:mouse_x], 319
	jbe .y_update
	mov word [cs:mouse_x], 319
	jmp .y_update
.x_min:
	mov word [cs:mouse_x], 0

.y_update:
	mov al, [cs:packet_data + 2]
	cbw
	sub [cs:mouse_y], ax
	js .y_min
	cmp word [cs:mouse_y], 199
	jbe .buttons
	mov word [cs:mouse_y], 199
	jmp .buttons
.y_min:
	mov word [cs:mouse_y], 0

.buttons:
	mov al, [cs:packet_data]
	and al, 3
	mov [cs:mouse_buttons], al

.done:
	pop dx
	pop cx
	pop bx
	ret

packet_idx db 0
packet_data rb 3
