format binary
use16
org 0x7C00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

; Set 320x200 graphics mode (mode 13h)
mov ax, 0x13
int 0x10

    mov si, msg_boot
    call print_string

    ; Remap PIC: Master to 0x20, Slave to 0x28 (avoid BIOS conflicts)
    call remap_pic

    ; Install IRQ12 handler at INT 0x2C (IRQ12 + 0x20)
    cli
    xor ax, ax
    mov es, ax
    mov word [es:0x2C*4], irq12_handler
    mov [es:0x2C*4+2], cs

    ; Unmask IRQ12 (bit 4 of slave PIC)
    in al, 0xA1
    and al, 0x10           ; Clear bit 4 (enable IRQ12)
    out 0xA1, al
    sti

    ; Initialize mouse
    call init_mouse

    mov si, msg_ok
    call print_string

    ; Draw initial cursor
    call update_cursor

.main_loop:
    ; Polling fallback: check if mouse has data
    in al, 0x64
    test al, 0x21           ; Bit 0 = output full, Bit 5 = mouse data
    jz .main_loop           ; No data, loop

    ; Read and process byte
    in al, 0x60
    call process_mouse_byte
    jmp .main_loop

; =============================================================================
; Remap PICs to avoid BIOS interrupt conflicts
; =============================================================================

remap_pic:
    ; Save masks
    in al, 0x21
    mov bl, al
    in al, 0xA1
    mov bh, al

    ; Start initialization (ICW1)
    mov al, 0x11
    out 0x20, al
    out 0xA0, al

    ; ICW2: Vector offsets
    mov al, 0x20            ; Master: 0x20-0x27
    out 0x21, al
    mov al, 0x28            ; Slave: 0x28-0x2F
    out 0xA1, al

    ; ICW3: Cascade identity
    mov al, 0x04            ; Master: IRQ2 has slave
    out 0x21, al
    mov al, 0x02            ; Slave: connected to IRQ2
    out 0xA1, al

    ; ICW4: 8086 mode
    mov al, 0x01
    out 0x21, al
    out 0xA1, al

    ; Restore masks (but keep IRQ2 enabled for cascade)
    mov al, bl
    and al, 0x04           ; Ensure IRQ2 (cascade) is enabled
    out 0x21, al
    mov al, bh
    out 0xA1, al
    ret

; =============================================================================
; Mouse Data Processing (works for both interrupt and polling)
; =============================================================================

packet_idx db 0
packet_data rb 3
cursor_x dw 160
cursor_y dw 100
prev_x dw 160
prev_y dw 100

process_mouse_byte:
    push ax
    push bx

    ; Check if this is first byte (bit 3 must be set)
    cmp byte [packet_idx], 0
    jne .store
    test al, 0x08
    jz .done                ; Out of sync, wait for sync byte

.store:
    movzx bx, [packet_idx]
    mov [packet_data + bx], al
    inc byte [packet_idx]

    cmp byte [packet_idx], 3
    jb .done                ; Need more bytes

    ; Process complete packet
    mov byte [packet_idx], 0

; Update X (signed byte to word)
	mov al, [packet_data + 1]
	cbw
	add [cursor_x], ax

	; Clamp X 0-319
	mov ax, [cursor_x]
	js .x_zero
	cmp ax, 320
	jb .update_y
	mov ax, 319
	jmp .save_x
.x_zero:
	xor ax, ax
.save_x:
	mov [cursor_x], ax

.update_y:
	; Update Y (inverted, signed byte to word)
	mov al, [packet_data + 2]
	cbw
	neg ax
	add [cursor_y], ax

	; Clamp Y 0-199
	mov ax, [cursor_y]
	js .y_zero
	cmp ax, 200
	jb .draw
	mov ax, 199
	jmp .save_y
.y_zero:
	xor ax, ax
.save_y:
	mov [cursor_y], ax

.draw:
    call update_cursor

.done:
    pop bx
    pop ax
    ret

; =============================================================================
; IRQ12 Handler (INT 0x2C)
; =============================================================================

irq12_handler:
    pusha
    push ds
    push es

    xor ax, ax
    mov ds, ax

    ; Read mouse data
    in al, 0x60
    call process_mouse_byte

    ; Send EOI to both PICs (slave first, then master)
    mov al, 0x20
    out 0xA0, al            ; Slave EOI
    out 0x20, al            ; Master EOI

    pop es
    pop ds
    popa
    iret

; =============================================================================
; Update Cursor Display
; =============================================================================

update_cursor:
	push es
	pusha

	mov ax, 0xA000
	mov es, ax

	; Erase previous pixel
	mov ax, [prev_y]
	mov cx, 320
	mul cx
	add ax, [prev_x]
	mov di, ax
	mov byte [es:di], 0

	; Draw new cursor (white pixel = color 15)
	mov ax, [cursor_y]
	mov cx, 320
	mul cx
	add ax, [cursor_x]
	mov di, ax
	mov byte [es:di], 15

	; Save position
	mov ax, [cursor_x]
	mov [prev_x], ax
	mov ax, [cursor_y]
	mov [prev_y], ax

	popa
	pop es
	ret

; =============================================================================
; Mouse Initialization (8042 Controller)
; =============================================================================

init_mouse:
    cli

    ; Disable devices
    call wait_cmd
    mov al, 0xAD            ; Disable keyboard
    out 0x64, al
    call wait_cmd
    mov al, 0xA7            ; Disable mouse
    out 0x64, al

    ; Flush output buffer
    in al, 0x64
    test al, 0x01
    jz .no_flush
    in al, 0x60
.no_flush:

    ; Set controller config
    call wait_cmd
    mov al, 0x20            ; Read config
    out 0x64, al
    call wait_data
    in al, 0x60
    or al, 0x02             ; Enable IRQ12
    and al, 0x20           ; Enable mouse clock
    push ax

    call wait_cmd
    mov al, 0x60            ; Write config
    out 0x64, al
    call wait_cmd
    pop ax
    out 0x60, al

    ; Enable mouse interface
    call wait_cmd
    mov al, 0xA8
    out 0x64, al

    ; Reset mouse and get ACK
    call mouse_cmd
    mov al, 0xFF            ; Reset
    out 0x60, al
    call wait_data
    in al, 0x60             ; ACK (0xFA)
    call wait_data
    in al, 0x60             ; Self-test result (0xAA)

    ; Set defaults
    call mouse_cmd
    mov al, 0xF6            ; Set defaults
    out 0x60, al
    call wait_data
    in al, 0x60             ; ACK

    ; Enable data reporting
    call mouse_cmd
    mov al, 0xF4            ; Enable
    out 0x60, al
    call wait_data
    in al, 0x60             ; ACK

    ; Enable keyboard again
    call wait_cmd
    mov al, 0xAE
    out 0x64, al

    sti
    ret

mouse_cmd:
    call wait_cmd
    mov al, 0xD4            ; Write to mouse
    out 0x64, al
    ret

wait_cmd:
    in al, 0x64
    test al, 0x02           ; Input buffer full?
    jnz wait_cmd
    ret

wait_data:
    in al, 0x64
    test al, 0x01           ; Output buffer full?
    jz wait_data
    ret

; =============================================================================
; Print String
; =============================================================================

msg_boot    db "Booting...", 13, 10, 0
msg_ok      db "Mouse OK! Move mouse...", 0

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

; Padding
times 510-($-$$) db 0
dw 0xAA55
