use16

; ===========================================================================
; PS/2 Mouse Driver for Bare Metal (INT 33h emulation)
; Corrected version with proper IRQ handling and hardware initialization
; ===========================================================================

; Driver State Variables
align 2
m_x         dw 160          ; Current X position
m_y         dw 100          ; Current Y position
m_b         dw 0            ; Current Buttons (Bit 0: Left, Bit 1: Right, Bit 2: Middle)
m_state     db 0            ; Packet cycle (0, 1, 2 - standard PS/2)
m_bytes     db 0, 0, 0      ; Packet buffer
m_min_x     dw 0            ; Min X range
m_max_x     dw 319          ; Max X range
m_min_y     dw 0            ; Min Y range
m_max_y     dw 199          ; Max Y range
m_enabled   db 0            ; Driver initialized flag
m_packet_sz db 3            ; Packet size (3 for standard, 4 for Intellimouse)

; ===========================================================================
; Initialize Mouse Driver
; Hooks INT 33h and INT 74h (IRQ 12)
; Returns: AX = 0xFFFF on success, 0 on failure
; ===========================================================================
mouse_init:
    push bx
    push cx
    push dx
    push si
    push di
    push es

    ; Disable interrupts during initialization
    cli

    xor ax, ax
    mov es, ax              ; ES = 0 (IVT)

    ; Check if already initialized
    cmp byte [cs:m_enabled], 1
    je .already_init

    ; Reset packet state
    mov byte [cs:m_state], 0

    ; Set default range directly (don't use INT 33h during init)
    mov word [cs:m_min_x], 0
    mov word [cs:m_max_x], 319
    mov word [cs:m_min_y], 0
    mov word [cs:m_max_y], 199
    mov word [cs:m_x], 160
    mov word [cs:m_y], 100

    ; Install Interrupt Handlers
    ; Hook INT 74h (IRQ 12)
    mov word [es:0x74*4], mouse_irq_handler
    mov word [es:0x74*4+2], cs

    ; Hook INT 33h (Mouse Services)
    mov word [es:0x33*4], int33_handler
    mov word [es:0x33*4+2], cs

    ; Enable Auxiliary Device (Mouse)
    call ps2_wait_write
    mov al, 0xA8            ; Enable Aux
    out 0x64, al

    ; Read Compaq Status Byte, modify it, write it back
    call ps2_wait_write
    mov al, 0x20            ; Read Command Byte
    out 0x64, al
    call ps2_wait_read
    in al, 0x60
    or al, 2                ; Enable IRQ 12 (Bit 1)
    and al, 0xDF            ; Enable Mouse Clock (Clear bit 5 - disable in ')
    push ax
    call ps2_wait_write
    mov al, 0x60            ; Write Command Byte
    out 0x64, al
    call ps2_wait_write
    pop ax
    out 0x60, al

    ; Reset Mouse (0xFF)
    mov al, 0xFF
    call mouse_cmd_with_ack
    jc .init_failed         ; Carry set if no ACK

    ; Expect 0xAA (BAT successful)
    call ps2_wait_read_ack
    jc .init_failed
    cmp al, 0xAA
    jne .init_failed

    ; Expect 0x00 (Device ID - standard PS/2 mouse)
    call ps2_wait_read_ack
    jc .init_failed
    mov byte [cs:m_packet_sz], 3  ; Standard 3-byte packets

    ; Set Defaults (0xF6)
    mov al, 0xF6
    call mouse_cmd_with_ack
    jc .init_failed

    ; Enable Data Reporting (0xF4)
    mov al, 0xF4
    call mouse_cmd_with_ack
    jc .init_failed

    ; Enable IRQ 12 on PIC
    ; Slave PIC (Port 0xA1) - Clear bit 4 (IRQ 12)
    in al, 0xA1
    and al, 0xEF
    out 0xA1, al

    ; Master PIC (Port 0x21) - Clear bit 2 (Cascade)
    in al, 0x21
    and al, 0xFB
    out 0x21, al

    ; Mark as enabled
    mov byte [cs:m_enabled], 1

    sti                     ; Enable interrupts

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    mov ax, 0xFFFF          ; Success
    ret

.init_failed:
    sti
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    xor ax, ax              ; Return 0 on failure
    ret

.already_init:
    sti
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    mov ax, 0xFFFF          ; Already initialized = success
    ret

; ===========================================================================
; Helper Functions
; ===========================================================================

; Wait until PS/2 controller input buffer is empty (Bit 1 of 0x64 is 0)
; Returns: Carry clear if OK, set if timeout
ps2_wait_write:
    push cx
    mov cx, 0x8000          ; Timeout counter
.loop:
    in al, 0x64
    test al, 2              ; Bit 1 = Input buffer full
    jz .ok
    dec cx
    jnz .loop
    stc                     ; Timeout
    pop cx
    ret
.ok:
    clc
    pop cx
    ret

; Wait until PS/2 controller output buffer has data (Bit 0 of 0x64 is 1)
; Returns: Carry clear if OK, set if timeout
ps2_wait_read:
    push cx
    mov cx, 0x8000          ; Timeout counter
.loop:
    in al, 0x64
    test al, 1              ; Bit 0 = Output buffer full
    jnz .ok
    dec cx
    jnz .loop
    stc                     ; Timeout
    pop cx
    ret
.ok:
    clc
    pop cx
    ret

; Wait for read with discard of potential stale data
; Used during init to clear spurious bytes
ps2_wait_read_ack:
    call ps2_wait_read
    jc .fail
    in al, 0x60
    clc
    ret
.fail:
    ret

; Send command to mouse via aux port and wait for ACK (0xFA)
; Input: AL = Command byte
; Returns: Carry clear if ACK received, set otherwise
mouse_cmd_with_ack:
    push ax
    call ps2_wait_write
    jc .timeout
    mov al, 0xD4            ; Write to Aux Device
    out 0x64, al
    call ps2_wait_write
    jc .timeout
    pop ax
    out 0x60, al            ; Send command

    ; Wait for ACK (0xFA)
    call ps2_wait_read
    jc .timeout
    in al, 0x60
    cmp al, 0xFA            ; ACK?
    jne .no_ack
    clc                     ; Success
    ret
.timeout:
    add sp, 2               ; Clean up pushed AX
    stc
    ret
.no_ack:
    stc
    ret

; ===========================================================================
; INT 74h Handler (IRQ 12 - PS/2 Mouse)
; Reads mouse packet bytes and processes complete packets
; ===========================================================================
mouse_irq_handler:
    pusha
    push ds
    push es

    push cs
    pop ds                  ; DS = CS for data access
    push cs
    pop es                  ; ES = CS

    ; Check Status Register - confirm data is from Aux Device
    in al, 0x64
    test al, 0x20           ; Bit 5 = Aux device data
    jz .not_mouse

    ; Read the data byte
    in al, 0x60

    ; Get current state (which byte we're expecting)
    xor bh, bh
    mov bl, [m_state]

    ; Store byte in buffer
    mov [m_bytes + bx], al

    ; Byte 0 should have bit 3 set (always 1 in PS/2 protocol)
    cmp bl, 0
    jne .not_first
    test al, 0x08           ; Sync bit check
    jnz .sync_ok
    ; Sync lost - reset state and ignore this packet
    mov byte [m_state], 0
    jmp .eoi
.sync_ok:
    ; Increment state to expect byte 1
    inc byte [m_state]
    jmp .eoi

.not_first:
    ; Move to next byte
    inc byte [m_state]

    ; Check if packet complete
    mov bl, [m_state]
    cmp bl, [m_packet_sz]
    jb .eoi                 ; Not complete yet

    ; Packet complete - process it
    mov byte [m_state], 0

    ; ===== Process Packet =====
    ; Byte 0: Y_overflow X_overflow Ys Xs 1 M R L
    mov al, [m_bytes]

    ; Check for overflow - ignore packet if X or Y overflowed
    test al, 0xC0          ; Bits 7:6 = Y_overflow:X_overflow
    jnz .eoi               ; Skip packet if overflow

    ; Extract Buttons (Bits 0-2)
    xor bx, bx
    test al, 1              ; Left button
    jz .no_left
    or bl, 1
.no_left:
    test al, 2              ; Right button
    jz .no_right
    or bl, 2
.no_right:
    test al, 4              ; Middle button (if available)
    jz .no_mid
    or bl, 4
.no_mid:
    mov [m_b], bx

    ; X Movement (Byte 1)
    xor cx, cx
    mov cl, [m_bytes+1]
    test al, 0x10           ; X sign bit
    jz .x_add
    or ch, 0xFF             ; Sign extend
.x_add:
    add [m_x], cx

    ; Clamp X to range
    mov ax, [m_x]
    cmp ax, [m_min_x]
    jge .x_min_ok
    mov ax, [m_min_x]
.x_min_ok:
    cmp ax, [m_max_x]
    jle .x_max_ok
    mov ax, [m_max_x]
.x_max_ok:
    mov [m_x], ax

    ; Y Movement (Byte 2) - PS/2 Y+ is Up, Screen Y+ is Down
    xor cx, cx
    mov cl, [m_bytes+2]
    test al, 0x20           ; Y sign bit
    jz .y_sub
    or ch, 0xFF             ; Sign extend
.y_sub:
    ; Invert Y (subtract instead of add)
    neg cx
    add [m_y], cx

    ; Clamp Y to range
    mov ax, [m_y]
    cmp ax, [m_min_y]
    jge .y_min_ok
    mov ax, [m_min_y]
.y_min_ok:
    cmp ax, [m_max_y]
    jle .y_max_ok
    mov ax, [m_max_y]
.y_max_ok:
    mov [m_y], ax

    jmp short .eoi

.not_mouse:
    ; Not mouse data - possibly keyboard byte arrived simultaneously
    ; Read and discard to clear buffer
    test al, 1              ; Output buffer full?
    jz .eoi
    in al, 0x60

.eoi:
    ; Send EOI to both PICs
    mov al, 0x20
    out 0xA0, al            ; Slave PIC
    out 0x20, al            ; Master PIC

    pop es
    pop ds
    popa
    iret

; ===========================================================================
; INT 33h Handler - Mouse Services
; AX = Function number:
;   0 - Reset/Detect (returns AX=0xFFFF, BX=buttons)
;   1 - Show Cursor (not implemented - just returns)
;   2 - Hide Cursor (not implemented - just returns)
;   3 - Get Status (returns BX=buttons, CX=x, DX=y)
;   4 - Set Cursor Position (CX=x, DX=y)
;   7 - Set X Range (CX=min, DX=max)
;   8 - Set Y Range (CX=min, DX=max)
; ===========================================================================
int33_handler:
    cmp ax, 0
    je .reset
    cmp ax, 1
    je .show_cursor
    cmp ax, 2
    je .hide_cursor
    cmp ax, 3
    je .get_status
    cmp ax, 4
    je .set_position
    cmp ax, 7
    je .set_x_range
    cmp ax, 8
    je .set_y_range
    iret

.reset:
    mov ax, 0xFFFF          ; Mouse installed
    mov bx, 3               ; Report 3 buttons (even if middle not present)
    iret

.show_cursor:
    iret

.hide_cursor:
    iret

.get_status:
    mov bx, [cs:m_b]
    mov cx, [cs:m_x]
    mov dx, [cs:m_y]
    iret

.set_position:
    mov [cs:m_x], cx
    mov [cs:m_y], dx
    ; Clamp immediately
    mov ax, cx
    cmp ax, [cs:m_min_x]
    jge .check_max_x
    mov ax, [cs:m_min_x]
.check_max_x:
    cmp ax, [cs:m_max_x]
    jle .x_ok
    mov ax, [cs:m_max_x]
.x_ok:
    mov [cs:m_x], ax

    mov ax, dx
    cmp ax, [cs:m_min_y]
    jge .check_max_y
    mov ax, [cs:m_min_y]
.check_max_y:
    cmp ax, [cs:m_max_y]
    jle .y_ok
    mov ax, [cs:m_max_y]
.y_ok:
    mov [cs:m_y], ax
    iret

.set_x_range:
    mov [cs:m_min_x], cx
    mov [cs:m_max_x], dx
    ; Clamp current position to new range
    mov ax, [cs:m_x]
    cmp ax, cx
    jge .min_x_ok
    mov ax, cx
.min_x_ok:
    cmp ax, dx
    jle .max_x_ok
    mov ax, dx
.max_x_ok:
    mov [cs:m_x], ax
    iret

.set_y_range:
    mov [cs:m_min_y], cx
    mov [cs:m_max_y], dx
    ; Clamp current position to new range
    mov ax, [cs:m_y]
    cmp ax, cx
    jge .min_y_ok
    mov ax, cx
.min_y_ok:
    cmp ax, dx
    jle .max_y_ok
    mov ax, dx
.max_y_ok:
    mov [cs:m_y], ax
    iret
