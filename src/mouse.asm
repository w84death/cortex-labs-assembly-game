;org 0x7c00
org 0x0100
use16

VGA_MEMORY_ADR equ 0xA000                   ; VGA memory address
DBUFFER_MEMORY_ADR equ 0x8000


start:
    mov ax,0x13                             ; Init VGA 320x200x256
    int 0x10                                ; Video BIOS interrupt

    push DBUFFER_MEMORY_ADR                 ; Set doublebuffer memory
    pop es                                  ; as target

    ; Set mouse horizontal cursor range to 1-319
    mov ax, 7
    mov cx, 1
    mov dx,319
    int 33h


game_loop:

  .draw_bg:
  xor di,di
  mov cx, 200
  .l:
      push cx
      xchg ax, cx
      add ax, bp
      shr ax, 2
      and al,0x05
      add al, 0x12
      mov cx, 320
      rep stosb
      pop cx
  loop .l

  inc bp
  inc bp

  .mouse_handler:
    mov ax, 0x0003
    int 0x33

    ; draw crosshair dot
    imul dx, 320
    add dx, cx
    mov di,dx
    mov al,0x0f
    stosb

  call vga_blit

  .cpu_delay:
    xor ax, ax                            ; 00h: Read system timer counter
    int 0x1a                              ; Returns tick count in CX:DX
    mov bx, dx                            ; Store low word of tick count
    mov si, cx                            ; Store high word of tick count
    .wait_loop:
      hlt
      xor ax, ax
      int 0x1a
      cmp cx, si                          ; Compare high word
      jne .tick_changed
      cmp dx, bx                          ; Compare low word
      je .wait_loop                       ; If both are the same, keep waiting
    .tick_changed:


  in al,0x60                           ; Read keyboard
  dec al
  jnz game_loop

  mov ax, 0x0003
  int 0x10

vga_blit:
    push es
    push ds

    push VGA_MEMORY_ADR                     ; Set VGA memory
    pop es                                  ; as target
    push DBUFFER_MEMORY_ADR                 ; Set doublebuffer memory
    pop ds                                  ; as source
    mov cx,0x7D00                           ; Half of 320x200 pixels
    xor si,si                               ; Clear SI
    xor di,di                               ; Clear DI
    rep movsw                               ; Push words (2x pixels)

    pop ds
    pop es
    ret

; times 507-($-$$) db 0
db "P1X"
;dw 0xAA55
