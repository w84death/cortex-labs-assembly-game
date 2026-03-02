; ============================================================================
; MS-DOS INT 33h Compatible Mouse Driver
; Mimics DOS mouse functions for game12-asm
; ============================================================================

TRUE equ 1
FALSE equ 0

MOUSE_IRQ equ 12
MOUSE_INT_NUM equ 0x2C

mouse_driver_installed db 0
mouse_cursor_visible db 0
mouse_driver_data:

mouse_x dw 160
mouse_y dw 100
mouse_buttons db 0
mouse_event_mask db 0

mouse_save_cs dw 0
mouse_save_ip dw 0
user_mouse_handler_cs dw 0
user_mouse_handler_ip dw 0

packet_idx db 0
packet_data rb 3

; ============================================================================
; Install Mouse Driver
; ============================================================================
install_mouse_driver:

    xor ax, ax
    mov es, ax

    ; Check if DOS environment
    mov bx, [es:0x21*4+2]
    cmp bx, 0
    jne .skip_init

    ; Not DOS - skip hardware init, just install simple handler
    jmp .install_handler

.install_handler:
    ; Save old INT 33h vector
    mov ax, [es:0x33*4]
    mov [mouse_save_ip], ax
    mov ax, [es:0x33*4+2]
    mov [mouse_save_cs], ax

    ; Install new handler
    mov word [es:0x33*4], mouse_int_handler
    mov [es:0x33*4+2], cs

    mov byte [mouse_driver_installed], TRUE
    mov byte [mouse_cursor_visible], FALSE

.skip_init:
.done:
    ret

; ============================================================================
; Mouse Hardware Initialization with timeout
; ============================================================================
init_mouse_hw_timeout:
    push cx
    push dx

    ; Quick timeout check - only try for ~100ms
    mov cx, 100
.timeout_loop:
    push cx
    call init_mouse_hw_simple
    pop cx
    jnc .success
    loop .timeout_loop

    ; Failed to init - mark as installed anyway but no hardware
    mov byte [mouse_driver_installed], TRUE
    stc
    jmp .done

.success:
    clc
.done:
    pop dx
    pop cx
    ret

; ============================================================================
; Simple mouse init (no IRQ, just setup)
; ============================================================================
init_mouse_hw_simple:
    cli

    ; Flush output buffer
    in al, 0x64
    test al, 0x01
    jz .no_flush
    in al, 0x60
.no_flush:

    ; Enable mouse interface
    call wait_cmd
    mov al, 0xA8
    out 0x64, al

    sti
    clc
    ret

wait_cmd:
    in al, 0x64
    test al, 0x02
    jnz wait_cmd
    ret

wait_data:
    in al, 0x64
    test al, 0x01
    jz wait_data
    ret

; ============================================================================
; INT 33h Mouse Handler
; ============================================================================
mouse_int_handler:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    xor ax, ax
    mov ds, ax

    ; Recover AX from stack
    mov ax, [esp+22]

    cmp ax, 0
    je int33_get_status
    cmp ax, 1
    je int33_show_cursor
    cmp ax, 2
    je int33_hide_cursor
    cmp ax, 3
    je int33_get_pos
    cmp ax, 4
    je int33_set_pos
    cmp ax, 7
    je int33_set_hlimits
    cmp ax, 8
    je int33_set_vlimits
    cmp ax, 0x0C
    je int33_set_handler
    cmp ax, 0x0F
    je int33_set_mickey_ratio

    jmp int33_exit

int33_get_status:
    mov ax, 0xFFFF
    mov bx, 2
    mov cx, 320
    mov dx, 200
    jmp int33_exit

int33_show_cursor:
    mov byte [mouse_cursor_visible], TRUE
    mov ax, -1
    jmp int33_exit

int33_hide_cursor:
    mov byte [mouse_cursor_visible], FALSE
    mov ax, 0
    jmp int33_exit

int33_get_pos:
    mov ax, [mouse_x]
    mov bx, [mouse_y]
    mov cx, 0
    mov cl, [mouse_buttons]
    jmp int33_exit

int33_set_pos:
    mov [mouse_x], cx
    mov [mouse_y], dx
    jmp int33_exit

int33_set_hlimits:
int33_set_vlimits:
    jmp int33_exit

int33_set_handler:
    mov [user_mouse_handler_cs], es
    mov [user_mouse_handler_ip], dx
    mov byte [mouse_event_mask], cl
    jmp int33_exit

int33_set_mickey_ratio:
    jmp int33_exit

int33_exit:
    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    iret

; ============================================================================
; Process mouse byte (called from game loop polling)
; ============================================================================
process_mouse_byte:
    push ax
    push bx

    cmp byte [packet_idx], 0
    jne .store
    test al, 0x08
    jz .done

.store:
    movzx bx, [packet_idx]
    mov [packet_data + bx], al
    inc byte [packet_idx]

    cmp byte [packet_idx], 3
    jb .done

    mov byte [packet_idx], 0

    ; Update X
    mov al, [packet_data + 1]
    cbw
    add [mouse_x], ax

    ; Clamp X 0-319
    mov ax, [mouse_x]
    js .x_zero
    cmp ax, 320
    jb .update_y
    mov ax, 319
    jmp .save_x
.x_zero:
    xor ax, ax
.save_x:
    mov [mouse_x], ax

.update_y:
    mov al, [packet_data + 2]
    cbw
    neg ax
    add [mouse_y], ax

    ; Clamp Y 0-199
    mov ax, [mouse_y]
    js .y_zero
    cmp ax, 200
    jb .update_buttons
    mov ax, 199
    jmp .save_y
.y_zero:
    xor ax, ax
.save_y:
    mov [mouse_y], ax

.update_buttons:
    mov al, [packet_data]
    and al, 0x03
    mov [mouse_buttons], al

    ; Sync with game variables
    call sync_to_game

.done:
    pop bx
    pop ax
    ret

sync_to_game:
    push ax
    push bx
    push es

    mov ax, ds
    mov es, ax

    mov ax, [mouse_x]
    mov bx, 0x0B
    mov [es:bx], ax

    mov ax, [mouse_y]
    mov bx, 0x0D
    mov [es:bx], ax

    mov al, [mouse_buttons]
    mov bx, 0x2B
    mov [es:bx], al

    pop es
    pop bx
    pop ax
    ret
