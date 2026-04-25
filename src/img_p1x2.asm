; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 472 bytes

p1x2_image:
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 099h, 000h, 00Eh, 00Fh, 099h, 000h, 099h, 000h
    db 00Eh, 00Fh, 099h, 000h, 099h, 000h, 00Eh, 00Fh, 099h, 000h, 099h, 000h, 00Eh, 00Fh, 099h, 000h
    db 09Ah, 000h, 006h, 003h, 007h, 00Fh, 099h, 000h, 09Ah, 000h, 006h, 003h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h
    db 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h
    db 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h, 0A0h, 000h, 007h, 00Fh
    db 099h, 000h, 0A0h, 000h, 007h, 00Fh, 099h, 000h

    db 0, 0
