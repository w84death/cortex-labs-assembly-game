use16

; ===========================================================================
; PS/2 Mouse Driver for Bare Metal (INT 33h emulation)
; ===========================================================================

; Driver State Variables
align 2
m_x         dw 160      ; Current X position
m_y         dw 100      ; Current Y position
m_b         dw 0        ; Current Buttons (Bit 0: Left, Bit 1: Right)
m_state     db 0        ; Packet cycle (0, 1, 2)
m_bytes     db 0, 0, 0  ; Packet buffer
m_min_x     dw 0        ; Min X range
m_max_x     dw 319      ; Max X range
m_min_y     dw 0        ; Min Y range
m_max_y     dw 199      ; Max Y range

; ===========================================================================
; Initialize Mouse Driver
; Hooks INT 33h and INT 74h (IRQ 12)
; Initializes PS/2 Mouse hardware
; ===========================================================================
mouse_init:
    pusha
    push es

    ; 1. Install Interrupt Handlers
    xor ax, ax
    mov es, ax      ; ES = 0 (IVT)

    ; Check for existing mouse driver
    mov bx, [es:0x33*4]
    or bx, [es:0x33*4+2]
    jz .install

    mov ax, 0
    int 0x33
    cmp ax, 0xFFFF
    je .skip_init

    .install:
    cli             ; Disable interrupts while hooking

    ; Hook INT 74h (IRQ 12)
    mov word [es:0x74*4], mouse_irq_handler
    mov word [es:0x74*4+2], cs

    ; Hook INT 33h (Mouse Services)
    mov word [es:0x33*4], int33_handler
    mov word [es:0x33*4+2], cs

    sti             ; Enable interrupts

    ; 2. Enable IRQ 12 on PIC
    ; Slave PIC (Port 0xA1) - Clear bit 4 (IRQ 12)
    in al, 0xA1
    and al, 0xEF
    out 0xA1, al

    ; Master PIC (Port 0x21) - Clear bit 2 (Cascade IRQ 2)
    in al, 0x21
    and al, 0xFB
    out 0x21, al

    ; 3. Enable Auxiliary Device (Mouse)
    call mouse_wait_write
    mov al, 0xA8    ; Enable Aux
    out 0x64, al

    ; 4. Update Compaq Status Byte
    call mouse_wait_write
    mov al, 0x20    ; Read Command Byte
    out 0x64, al
    call mouse_wait_read
    in al, 0x60
    or al, 2        ; Enable IRQ 12
    and al, 0xDF    ; Enable Mouse Clock (Clear bit 5)
    push ax
    call mouse_wait_write
    mov al, 0x60    ; Write Command Byte
    out 0x64, al
    call mouse_wait_write
    pop ax
    out 0x60, al

    ; 5. Set Defaults
    mov al, 0xF6
    call mouse_write

    ; 6. Enable Data Reporting
    mov al, 0xF4
    call mouse_write

    .skip_init:
    pop es
    popa

    mov ax, 7                             ; Mouse horizontal cursor range
    mov cx, 1                             ; from 1
    mov dx,319                            ; to 319
    int 33h
    ret

; Helper: Wait until 8042 input buffer is empty
mouse_wait_write:
    in al, 0x64
    test al, 2
    jnz mouse_wait_write
    ret

; Helper: Wait until 8042 output buffer is full
mouse_wait_read:
    in al, 0x64
    test al, 1
    jz mouse_wait_read
    ret

; Helper: Write byte to mouse (auxiliary device)
; Input: AL = Byte to write
mouse_write:
    push ax
    call mouse_wait_write
    mov al, 0xD4    ; Write to Aux Device
    out 0x64, al
    call mouse_wait_write
    pop ax
    out 0x60, al
    call mouse_wait_read
    in al, 0x60     ; Read Acknowledge (0xFA)
    ret

; ===========================================================================
; INT 74h Handler (IRQ 12)
; Reads mouse packet and updates state
; ===========================================================================
mouse_irq_handler:
    pusha
    push ds
    push cs
    pop ds          ; Ensure DS = CS to access variables

    in al, 0x60     ; Read data port
    mov bl, al      ; Save byte

    ; Store byte in buffer
    mov bh, 0
    mov bl, [m_state]
    mov si, m_bytes
    add si, bx
    mov [si], al

    ; Update state
    inc byte [m_state]

    ; Sync check on Byte 0
    cmp byte [m_state], 1
    jne .check_done
    test al, 0x08   ; Bit 3 should be 1
    jnz .packet_continue
    ; Sync fail
    mov byte [m_state], 0
    jmp .eoi
    .packet_continue:
    jmp .eoi

    .check_done:
    cmp byte [m_state], 3
    jb .eoi

    ; Packet Complete - Process it
    mov byte [m_state], 0

    ; Byte 0: Yov Xov Ys Xs 1 M R L
    mov al, [m_bytes]

    ; Extract Buttons
    xor bx, bx
    test al, 1
    jz .no_left
    or bx, 1        ; Left Button
    .no_left:
    test al, 2
    jz .no_right
    or bx, 2        ; Right Button
    .no_right:
    mov [m_b], bx

    ; X Movement
    mov al, [m_bytes]
    mov cl, [m_bytes+1]
    xor ch, ch
    test al, 0x10   ; X Sign Bit
    jz .x_pos
    mov ch, 0xFF
    .x_pos:
    add [m_x], cx

    ; Clamp X
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

    ; Y Movement (PS/2: + is Up, Screen: + is Down)
    mov al, [m_bytes]
    mov cl, [m_bytes+2]
    xor ch, ch
    test al, 0x20   ; Y Sign Bit
    jz .y_pos
    mov ch, 0xFF
    .y_pos:
    sub [m_y], cx   ; Subtract because screen Y is inverted relative to mouse

    ; Clamp Y
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

    .eoi:
    mov al, 0x20
    out 0xA0, al    ; EOI Slave
    out 0x20, al    ; EOI Master

    pop ds
    popa
    iret

; ===========================================================================
; INT 33h Handler
; Provides Mouse Services to Game
; ===========================================================================
int33_handler:
    sti             ; Allow interrupts inside
    cmp ax, 0
    je .reset
    cmp ax, 3
    je .get_status
    cmp ax, 7
    je .set_x_range
    cmp ax, 8
    je .set_y_range
    iret

    .reset:
    ; Reset mouse driver (re-init if needed, here just report presence)
    mov ax, 0xFFFF  ; Mouse installed
    mov bx, 2       ; 2 buttons
    iret

    .get_status:
    mov bx, [cs:m_b]
    mov cx, [cs:m_x]
    mov dx, [cs:m_y]
    iret

    .set_x_range:
    mov [cs:m_min_x], cx
    mov [cs:m_max_x], dx
    iret

    .set_y_range:
    mov [cs:m_min_y], cx
    mov [cs:m_max_y], dx
    iret
