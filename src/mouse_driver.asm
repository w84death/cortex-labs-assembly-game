; ============================================================================
; MS-DOS INT 33h Compatible Mouse Driver (Minimal)
; Provides basic mouse position and button state for baremetal
; ============================================================================

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

	ret

; ============================================================================
; INT 33h Handler
; ============================================================================
int33_handler:
  xor bx, bx
  mov cx, 160
  mov dx, 100
	iret
