; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 834 bytes

p1x1_image:
    db 068h, 000h, 02Ah, 00Fh, 0AEh, 000h, 068h, 000h, 02Ah, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h
    db 02Ah, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 02Ah, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h
    db 007h, 00Fh, 01Ch, 003h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 01Ch, 003h
    db 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh
    db 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h
    db 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h
    db 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h
    db 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh
    db 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h
    db 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh
    db 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h
    db 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h
    db 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h
    db 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh
    db 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h
    db 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh
    db 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h
    db 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h
    db 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h
    db 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh
    db 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h
    db 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh
    db 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h
    db 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h
    db 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h
    db 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh
    db 003h, 003h, 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 019h, 000h, 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h
    db 007h, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 019h, 000h, 007h, 00Fh
    db 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 001h, 003h, 01Bh, 00Ah, 007h, 00Fh, 001h, 003h
    db 0ADh, 000h, 068h, 000h, 02Ah, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 02Ah, 00Fh, 001h, 003h
    db 0ADh, 000h, 068h, 000h, 02Ah, 00Fh, 001h, 003h, 0ADh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h, 0CEh, 000h, 068h, 000h, 007h, 00Fh, 003h, 003h
    db 0CEh, 000h, 068h, 000h, 007h, 00Fh, 002h, 003h, 0CFh, 000h, 068h, 000h, 007h, 00Fh, 001h, 003h
    db 0D0h, 000h

    db 0, 0
