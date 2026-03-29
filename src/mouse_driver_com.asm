; ============================================================================
; MS-DOS INT 33h Compatible Mouse Driver for Bare Metal
; Provides: X, Y position and button state via Serial (COM) Mouse
; Uses Microsoft Mouse Protocol (3-byte packets)
; ============================================================================

; --- Mouse State Variables ---
mouse_x          dw 160
mouse_y          dw 100
mouse_buttons    db 0

; --- Internal State ---
mouse_packet     db 0, 0, 0
mouse_cycle      db 0

; --- COM Port Constants (COM1) ---
COM_BASE         equ 0x3F8
COM_DATA         equ COM_BASE+0   ; Data register (R/W)
COM_IER          equ COM_BASE+1   ; Interrupt Enable Register
COM_LCR          equ COM_BASE+3   ; Line Control Register
COM_MCR          equ COM_BASE+4   ; Modem Control Register
COM_LSR          equ COM_BASE+5   ; Line Status Register
COM_DLL          equ COM_BASE+0   ; Divisor Latch Low (when DLAB=1)
COM_DLM          equ COM_BASE+1   ; Divisor Latch High (when DLAB=1)

; ============================================================================
; Install Mouse Driver - Initialize COM mouse and hook INT 33h
; ============================================================================
install_com_mouse_driver:
    ; Hook INT 33h
    xor ax, ax
    mov es, ax
    mov word [es:0x33*4], int33_handler
    mov [es:0x33*4+2], cs

    ; Hook IRQ4 (INT 0x0C - COM1/COM3)
    mov word [es:0x0C*4], irq4_handler
    mov [es:0x0C*4+2], cs

    ; Initialize COM port for serial mouse
    call mouse_init_com

    ; Unmask IRQ4 in the master PIC
    in al, 0x21
    and al, 0xEF          ; Clear bit 4 (IRQ4)
    out 0x21, al
    ret

; ============================================================================
; Initialize COM Port for Serial Mouse
; ============================================================================
mouse_init_com:
    ; Disable all UART interrupts during init
    mov dx, COM_IER
    xor al, al
    out dx, al

    ; Set DLAB=1 to access baud rate divisor
    mov dx, COM_LCR
    mov al, 0x80
    out dx, al

    ; Set baud rate to 1200 baud (divisor = 96 for 115200 base)
    mov dx, COM_DLL
    mov al, 96            ; 115200 / 1200 = 96
    out dx, al
    mov dx, COM_DLM
    xor al, al
    out dx, al

    ; 7 data bits, 1 stop bit, no parity (0x02)
    ; Microsoft mouse protocol uses 7N1
    mov dx, COM_LCR
    mov al, 0x02
    out dx, al

    ; Set DTR + RTS + OUT2 (OUT2 enables IRQ on PC)
    mov dx, COM_MCR
    mov al, 0x0B
    out dx, al

    ; Enable receive data available interrupt
    mov dx, COM_IER
    mov al, 0x01
    out dx, al

    ; Flush receive buffer
.flush:
    mov dx, COM_LSR
    in al, dx
    test al, 0x01
    jz .flushed
    mov dx, COM_DATA
    in al, dx
    jmp .flush
.flushed:
    ret

; ============================================================================
; Poll mouse and update state - call from timer or other IRQ
; ============================================================================
mouse_poll:
    push ax
    push bx
    push dx

    ; Check if data available (Line Status Register bit 0)
    mov dx, COM_LSR
    in al, dx
    test al, 0x01
    jz .done

    ; Read data byte
    mov dx, COM_DATA
    in al, dx

    ; Check for sync byte (bit 6 set = 0x40)
    test al, 0x40
    jnz .sync_byte

    ; Not a sync byte - process based on cycle
    mov bl, [cs:mouse_cycle]
    cmp bl, 1
    je .byte1
    cmp bl, 2
    je .byte2
    jmp .done             ; Ignore if not expecting data bytes

.sync_byte:
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
    pop dx
    pop bx
    pop ax
    ret

; ============================================================================
; Process mouse packet and update position
; Microsoft Mouse Protocol:
;   Byte 0: 0 1 L R Y6 Y7 X6 X7
;   Byte 1: 0 0 X5..X0
;   Byte 2: 0 0 Y5..Y0
; ============================================================================
mouse_process_packet:
    push cx

    ; Get button state
    ; Left button = bit 4 of byte 0
    ; Right button = bit 5 of byte 0
    xor al, al
    mov bl, [cs:mouse_packet+0]
    test bl, 0x20
    jz .no_left
    or al, 0x01
.no_left:
    test bl, 0x10
    jz .no_right
    or al, 0x02
.no_right:
    mov [cs:mouse_buttons], al

    ; --- X Movement ---
    ; Low 6 bits from byte 1, high 2 bits from byte 0 (bits 0,1)
    mov cl, [cs:mouse_packet+0]
    and cl, 0x03          ; X6, X7
    shl cl, 6             ; Shift to bits 6,7
    mov bl, [cs:mouse_packet+1]
    and bl, 0x3F          ; X0..X5
    or bl, cl             ; Combine
    ; Sign extend from 8-bit signed value
    movsx bx, bl

    ; Update X
    mov cx, [cs:mouse_x]
    add cx, bx
    cmp cx, 0
    jge .x_ok1
    xor cx, cx
.x_ok1:
    cmp cx, 639
    jle .x_ok2
    mov cx, 639
.x_ok2:
    mov [cs:mouse_x], cx

    ; --- Y Movement ---
    ; Low 6 bits from byte 2, high 2 bits from byte 0 (bits 2,3)
    mov cl, [cs:mouse_packet+0]
    and cl, 0x0C          ; Y6, Y7 (bits 2,3)
    shr cl, 2             ; Shift to bits 0,1 then to 6,7
    shl cl, 6
    mov bl, [cs:mouse_packet+2]
    and bl, 0x3F          ; Y0..Y5
    or bl, cl             ; Combine
    ; Sign extend from 8-bit signed value
    movsx bx, bl
    neg bx                ; Invert Y (serial mice: down = positive, screen: down = negative)

    ; Update Y
    mov cx, [cs:mouse_y]
    add cx, bx
    cmp cx, 0
    jge .y_ok1
    xor cx, cx
.y_ok1:
    cmp cx, 479
    jle .y_ok2
    mov cx, 479
.y_ok2:
    mov [cs:mouse_y], cx

    pop cx
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

.unhandled:
    xor ax, ax
    iret

; ============================================================================
; IRQ4 Handler - COM1 Serial Mouse Interrupt
; ============================================================================
irq4_handler:
    push ax

    ; Process mouse data
    call mouse_poll

    ; Send EOI to master PIC
    mov al, 0x20
    out 0x20, al

    pop ax
    iret
