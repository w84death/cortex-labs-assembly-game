; ============================================================================
; MS-DOS INT 33h Compatible Mouse Driver for Bare Metal
; Provides: X, Y position and button state via PS/2 mouse
; ============================================================================

MOUSE_PORT                              equ 0x60
MOUSE_STATUS                            equ 0x64
MOUSE_CMD                               equ 0x64
MOUSE_MAX_X                             equ SCREEN_WIDTH-1
MOUSE_MAX_Y                             equ SCREEN_HEIGHT-1
MOUSE_IRQ33                             equ 0x33
MOUSE_IRQ12                             equ 0x74


mouse_x                                 dw SCREEN_WIDTH/2
mouse_y                                 dw SCREEN_HEIGHT/2
mouse_buttons                           db 0
mouse_packet                            db 0, 0, 0
packet_idx                              db 0
mouse_cycle                             db 0

; ===================================== INSTALL DRIVER ======================|80
install_mouse_driver:

  .hook_irq33:
  xor ax, ax
  mov es, ax
  mov word [es:MOUSE_IRQ33*4], int33_handler
  mov word [es:MOUSE_IRQ33*4+2], cs

  .hook_irq12:
  mov word [es:MOUSE_IRQ12*4], irq12_handler
  mov word [es:MOUSE_IRQ12*4+2], cs

  call mouse_init

  ; Unmask IRQ12 in the slave PIC (0xA1)
  in al, 0xA1
  and al, 0xEF          ; Clear bit 4 (IRQ12)
  out 0xA1, al

  ; Ensure IRQ2 is unmasked in master PIC (cascade)
  in al, 0x21
  and al, 0xFB          ; Clear bit 2 (IRQ2)
  out 0x21, al
  ret

; ============================================================================
; Initialize PS/2 Mouse
; ============================================================================
mouse_init:
    ; Enable auxiliary device (mouse)
    call mouse_wait_write
    mov al, 0xA8
    out MOUSE_CMD, al

    ; Enable mouse interrupt (IRQ12)
    call mouse_wait_write
    mov al, 0x20
    out MOUSE_CMD, al
    call mouse_wait_read
    in al, MOUSE_PORT
    or al, 0x02
    push ax
    call mouse_wait_write
    mov al, 0x60
    out MOUSE_CMD, al
    call mouse_wait_write
    pop ax
    out MOUSE_PORT, al

    ; Enable mouse (streaming mode)
    call mouse_write_cmd
    mov al, 0xF4
    out MOUSE_PORT, al
    call mouse_read_ack

    ; Set sample rate 60
    call mouse_write_cmd
    mov al, 0xF3
    out MOUSE_PORT, al
    call mouse_read_ack
    call mouse_write_cmd
    mov al, 60
    out MOUSE_PORT, al
    call mouse_read_ack

    ret

; ============================================================================
; Wait for PS/2 controller ready to write
; ============================================================================
mouse_wait_write:
    push ax
    xor cx, cx
.wait:
    in al, MOUSE_STATUS
    test al, 0x02
    jz .ready
    loop .wait
.ready:
    pop ax
    ret

; ============================================================================
; Wait for PS/2 controller ready to read
; ============================================================================
mouse_wait_read:
    push ax
    xor cx, cx
.wait:
    in al, MOUSE_STATUS
    test al, 0x01
    jnz .ready
    loop .wait
.ready:
    pop ax
    ret

; ============================================================================
; Write command byte to mouse
; ============================================================================
mouse_write_cmd:
    call mouse_wait_write
    mov al, 0xD4
    out MOUSE_CMD, al
    call mouse_wait_write
    ret

; ============================================================================
; Read and acknowledge
; ============================================================================
mouse_read_ack:
    call mouse_wait_read
    in al, MOUSE_PORT
    ret

; ============================================================================
; Poll mouse and update state - call this from timer or keyboard IRQ
; ============================================================================
mouse_poll:
    push ax
    push bx

    ; Check if data available
    in al, MOUSE_STATUS
    test al, 0x21
    jz .done

    in al, MOUSE_PORT

    mov bl, [cs:mouse_cycle]
    cmp bl, 0
    je .byte0
    cmp bl, 1
    je .byte1
    cmp bl, 2
    je .byte2
    jmp .done

.byte0:
    mov [cs:mouse_packet+0], al
    mov byte [cs:mouse_cycle], 1
    jmp .done

.byte1:
    mov [cs:mouse_packet+1], al
    mov byte [cs:mouse_cycle], 2
    jmp .done

.byte2:
    mov [cs:mouse_packet+2], al
    mov byte [cs:mouse_cycle], 0
    call mouse_process_packet

.done:
    pop bx
    pop ax
    ret

; ============================================================================
; Process mouse packet and update position
; ============================================================================
mouse_process_packet:
    ; Get button state (bits 0-2)
    mov al, [cs:mouse_packet+0]
    and al, 0x07
    mov [cs:mouse_buttons], al

    ; Get X movement
    mov bl, [cs:mouse_packet+1]
    mov al, [cs:mouse_packet+0]
    test al, 0x10
    jz .x_pos
    or bl, 0xC0
.x_pos:
    movsx bx, bl

    ; Update X
    mov cx, [cs:mouse_x]
    add cx, bx
    cmp cx, 0
    jge .x_ok1
    xor cx, cx
.x_ok1:
    cmp cx, MOUSE_MAX_X
    jle .x_ok2
    mov cx, MOUSE_MAX_X
.x_ok2:
    mov [cs:mouse_x], cx

    ; Get Y movement
    mov bl, [cs:mouse_packet+2]
    mov al, [cs:mouse_packet+0]
    test al, 0x20
    jz .y_pos
    or bl, 0xC0
.y_pos:
    movsx bx, bl
    neg bx

    ; Update Y
    mov cx, [cs:mouse_y]
    add cx, bx
    cmp cx, 0
    jge .y_ok1
    xor cx, cx
.y_ok1:
    cmp cx, MOUSE_MAX_Y
    jle .y_ok2
    mov cx, MOUSE_MAX_Y
.y_ok2:
    mov [cs:mouse_y], cx
    ret

; ============================================================================
; INT 33h Handler - DOS Mouse API
; ============================================================================
int33_handler:
  cmp al, 0x00
  je .func00
  cmp al, 0x03
  je .func03
  jmp .unhandled

  ; Function 00h - Reset Mouse
  .func00:
    mov ax, 0xFFFF
    mov bx, 3
    xor cx, cx
    xor dx, dx
    iret

  ; Function 03h - Get Position and Button Status
  .func03:
    mov cx, [cs:mouse_x]
    mov dx, [cs:mouse_y]
    xor bx, bx
    mov bl, [cs:mouse_buttons]
    iret

  .unhandled:  ; todo: do we need that?
    xor ax, ax
    iret

; ============================================================================
; IRQ12 Handler - PS/2 Mouse Interrupt
; ============================================================================
irq12_handler:
  push ax

  call mouse_poll

  ; Send EOI to slave PIC
  mov al, 0x20
  out 0xA0, al

  ; Send EOI to master PIC
  out 0x20, al

  pop ax
  iret
