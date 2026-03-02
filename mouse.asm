use16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov ax, 0x0003
    int 0x10

    mov si, msg_init
    call print_string

    call init_mouse
    cmp al, 0xFF
    jne .no_mouse

    mov si, msg_found
    call print_string

.mainloop:
    call get_mouse_pos
    
    mov bx, ax
    mov ax, 0x0003
    int 0x10

    mov si, msg_x
    call print_string
    mov ax, bx
    mov al, [mouse_x]
    xor ah, ah
    call print_number

    mov si, msg_y
    call print_string
    mov al, [mouse_y]
    xor ah, ah
    call print_number

    mov si, msg_buttons
    call print_string
    mov al, [mouse_buttons]
    call print_number

    mov ah, 0x01
    int 0x16
    jz .mainloop

    mov ah, 0x00
    int 0x16
    cmp al, 27
    je .done
    jmp .mainloop

.done:
    cli
    call disable_mouse
    sti

    mov ax, 0x0003
    int 0x10

    mov si, msg_exit
    call print_string

    mov ax, 0x4C00
    int 0x21
    ret

.no_mouse:
    mov si, msg_nomouse
    call print_string
    ret

init_mouse:
    mov ax, 0xC205
    mov bh, 3
    int 0x15
    jc .fail

    mov ax, 0xC203
    mov bh, 3
    int 0x15
    jc .fail

    mov ax, 0xC200
    mov bh, 1
    int 0x15
    jc .fail

    mov ax, 0xC207
    mov bx, mouse_handler
    int 0x15
    jc .fail

    mov al, 0xFF
    ret

.fail:
    xor al, al
    ret

disable_mouse:
    mov ax, 0xC200
    mov bh, 0
    int 0x15
    ret

get_mouse_pos:
    pusha
    mov ax, 0xC201
    int 0x15
    popa
    ret

print_string:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    popa
    ret

print_number:
    pusha
    mov cx, 0
    mov bx, 10
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
.print:
    pop dx
    add dl, '0'
    mov ah, 0x0E
    int 0x10
    loop .print
    popa
    ret

mouse_x:      db 0
mouse_y:      db 0
mouse_buttons: db 0

msg_init:     db "Initializing PS/2 mouse...", 13, 10, 0
msg_found:    db "Mouse found!", 13, 10, 0
msg_nomouse:  db "No mouse detected!", 13, 10, 0
msg_x:        db "X: ", 0
msg_y:        db " Y: ", 0
msg_buttons:  db " Btns: ", 0
msg_exit:     db "Goodbye!", 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55

mouse_handler:
    push ax
    push bx
    push cx
    push dx
    push ds
    
    mov ax, cs
    mov ds, ax
    
    mov [mouse_buttons], al
    
    cmp al, 1
    je .update_pos
    
    mov bx, 40
    mov es, bx
    mov [es:mouse_x], al
    mov [es:mouse_y], ah
    
.update_pos:
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    retf

times 1024-($-$$) db 0
