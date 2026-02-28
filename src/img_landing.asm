; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 948 bytes

landing_image:
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0C7h, 000h, 003h, 007h
    db 076h, 000h, 0C4h, 000h, 00Bh, 007h, 071h, 000h, 0C4h, 000h, 00Fh, 007h, 032h, 000h, 001h, 003h
    db 001h, 00Ah, 039h, 000h, 0C3h, 000h, 012h, 007h, 030h, 000h, 002h, 003h, 004h, 000h, 001h, 00Ah
    db 001h, 007h, 033h, 000h, 0C3h, 000h, 015h, 007h, 030h, 000h, 007h, 007h, 031h, 000h, 0C3h, 000h
    db 017h, 007h, 02Eh, 000h, 007h, 003h, 031h, 000h, 0C3h, 000h, 019h, 007h, 02Dh, 000h, 006h, 003h
    db 01Ch, 000h, 001h, 00Ah, 014h, 000h, 0C4h, 000h, 01Ah, 007h, 04Ch, 000h, 003h, 003h, 013h, 000h
    db 0C4h, 000h, 00Dh, 007h, 006h, 000h, 009h, 007h, 060h, 000h, 0C5h, 000h, 00Bh, 007h, 00Bh, 000h
    db 007h, 007h, 05Eh, 000h, 0C5h, 000h, 00Ah, 007h, 00Eh, 000h, 007h, 007h, 05Ch, 000h, 0C6h, 000h
    db 009h, 007h, 011h, 000h, 006h, 007h, 05Ah, 000h, 0C6h, 000h, 009h, 007h, 013h, 000h, 006h, 007h
    db 058h, 000h, 0C7h, 000h, 009h, 007h, 014h, 000h, 006h, 007h, 056h, 000h, 0C8h, 000h, 008h, 007h
    db 016h, 000h, 005h, 007h, 055h, 000h, 0C9h, 000h, 008h, 007h, 017h, 000h, 005h, 007h, 053h, 000h
    db 0C9h, 000h, 008h, 007h, 019h, 000h, 005h, 007h, 051h, 000h, 0CAh, 000h, 008h, 007h, 01Ah, 000h
    db 004h, 007h, 050h, 000h, 0CBh, 000h, 007h, 007h, 01Ch, 000h, 004h, 007h, 04Eh, 000h, 0CCh, 000h
    db 007h, 007h, 01Ch, 000h, 005h, 007h, 04Ch, 000h, 0CDh, 000h, 007h, 007h, 01Dh, 000h, 004h, 007h
    db 04Bh, 000h, 0CEh, 000h, 007h, 007h, 01Eh, 000h, 004h, 007h, 049h, 000h, 0CFh, 000h, 007h, 007h
    db 01Eh, 000h, 004h, 007h, 048h, 000h, 0D0h, 000h, 006h, 007h, 020h, 000h, 004h, 007h, 046h, 000h
    db 0D1h, 000h, 006h, 007h, 020h, 000h, 002h, 007h, 003h, 00Ah, 044h, 000h, 0D1h, 000h, 007h, 007h
    db 018h, 000h, 013h, 00Ah, 03Dh, 000h, 0D2h, 000h, 007h, 007h, 013h, 000h, 01Ah, 00Ah, 03Ah, 000h
    db 0D3h, 000h, 007h, 007h, 00Fh, 000h, 020h, 00Ah, 037h, 000h, 0D5h, 000h, 006h, 007h, 00Bh, 000h
    db 025h, 00Ah, 035h, 000h, 0D6h, 000h, 006h, 007h, 008h, 000h, 027h, 00Ah, 002h, 007h, 033h, 000h
    db 0D7h, 000h, 006h, 007h, 006h, 000h, 009h, 00Ah, 002h, 007h, 012h, 00Ah, 003h, 007h, 003h, 00Ah
    db 002h, 007h, 003h, 00Ah, 003h, 007h, 032h, 000h, 0D8h, 000h, 007h, 007h, 002h, 000h, 001h, 007h
    db 002h, 00Ah, 001h, 007h, 003h, 00Ah, 006h, 007h, 003h, 00Ah, 01Eh, 007h, 031h, 000h, 0D9h, 000h
    db 037h, 007h, 030h, 000h, 0DAh, 000h, 018h, 007h, 003h, 003h, 007h, 007h, 003h, 003h, 003h, 007h
    db 003h, 003h, 008h, 007h, 001h, 003h, 003h, 007h, 02Fh, 000h, 0DBh, 000h, 00Ah, 007h, 001h, 003h
    db 008h, 007h, 008h, 003h, 002h, 007h, 00Fh, 003h, 005h, 007h, 003h, 003h, 001h, 007h, 002h, 003h
    db 02Eh, 000h, 0DCh, 000h, 007h, 007h, 004h, 003h, 003h, 007h, 01Eh, 003h, 003h, 007h, 007h, 003h
    db 02Eh, 000h, 0DDh, 000h, 007h, 007h, 02Fh, 003h, 02Dh, 000h, 0DEh, 000h, 001h, 003h, 006h, 007h
    db 02Eh, 003h, 02Dh, 000h, 0DEh, 000h, 002h, 003h, 007h, 007h, 02Ch, 003h, 02Dh, 000h, 0DEh, 000h
    db 003h, 003h, 007h, 007h, 02Bh, 003h, 02Dh, 000h, 0DFh, 000h, 003h, 003h, 007h, 007h, 029h, 003h
    db 02Eh, 000h, 0DFh, 000h, 005h, 003h, 006h, 007h, 028h, 003h, 02Eh, 000h, 0E0h, 000h, 005h, 003h
    db 007h, 007h, 025h, 003h, 001h, 007h, 02Eh, 000h, 0E1h, 000h, 005h, 003h, 007h, 007h, 023h, 003h
    db 004h, 007h, 02Ch, 000h, 0E2h, 000h, 005h, 003h, 007h, 007h, 021h, 003h, 002h, 000h, 004h, 007h
    db 02Bh, 000h, 0E4h, 000h, 005h, 003h, 007h, 007h, 01Dh, 003h, 005h, 000h, 004h, 007h, 02Ah, 000h
    db 0E5h, 000h, 005h, 003h, 007h, 007h, 01Bh, 003h, 007h, 000h, 004h, 007h, 029h, 000h, 0E7h, 000h
    db 005h, 003h, 007h, 007h, 016h, 003h, 00Bh, 000h, 004h, 007h, 028h, 000h, 0EAh, 000h, 003h, 003h
    db 007h, 007h, 012h, 003h, 00Fh, 000h, 004h, 007h, 027h, 000h, 0EDh, 000h, 001h, 003h, 007h, 007h
    db 00Dh, 003h, 014h, 000h, 004h, 007h, 026h, 000h, 0F0h, 000h, 007h, 007h, 005h, 003h, 01Bh, 000h
    db 004h, 007h, 025h, 000h, 0F1h, 000h, 007h, 007h, 020h, 000h, 004h, 007h, 024h, 000h, 0F3h, 000h
    db 007h, 007h, 01Fh, 000h, 004h, 007h, 023h, 000h, 0F4h, 000h, 008h, 007h, 01Eh, 000h, 004h, 007h
    db 022h, 000h, 0F5h, 000h, 008h, 007h, 01Eh, 000h, 004h, 007h, 021h, 000h, 0F7h, 000h, 008h, 007h
    db 01Ch, 000h, 005h, 007h, 020h, 000h, 0F9h, 000h, 007h, 007h, 01Ch, 000h, 005h, 007h, 01Fh, 000h
    db 0FAh, 000h, 008h, 007h, 01Bh, 000h, 005h, 007h, 01Eh, 000h, 0FCh, 000h, 008h, 007h, 01Ah, 000h
    db 005h, 007h, 01Dh, 000h, 0FDh, 000h, 009h, 007h, 018h, 000h, 005h, 007h, 01Dh, 000h, 0FFh, 000h
    db 009h, 007h, 017h, 000h, 005h, 007h, 01Ch, 000h, 0FFh, 000h, 001h, 000h, 00Ah, 007h, 015h, 000h
    db 006h, 007h, 01Bh, 000h, 0FFh, 000h, 003h, 000h, 00Ah, 007h, 014h, 000h, 006h, 007h, 01Ah, 000h
    db 0FFh, 000h, 005h, 000h, 00Ah, 007h, 012h, 000h, 006h, 007h, 01Ah, 000h, 0FFh, 000h, 007h, 000h
    db 00Ah, 007h, 010h, 000h, 007h, 007h, 019h, 000h, 0FFh, 000h, 009h, 000h, 00Bh, 007h, 00Dh, 000h
    db 008h, 007h, 018h, 000h, 0FFh, 000h, 00Ah, 000h, 00Dh, 007h, 009h, 000h, 009h, 007h, 018h, 000h
    db 0FFh, 000h, 00Ch, 000h, 00Fh, 007h, 002h, 000h, 00Dh, 007h, 017h, 000h, 0FFh, 000h, 00Eh, 000h
    db 01Ch, 007h, 017h, 000h, 0FFh, 000h, 010h, 000h, 01Bh, 007h, 016h, 000h, 0FFh, 000h, 013h, 000h
    db 018h, 007h, 016h, 000h, 0FFh, 000h, 015h, 000h, 016h, 007h, 016h, 000h, 0FFh, 000h, 017h, 000h
    db 014h, 007h, 016h, 000h, 0FFh, 000h, 01Ah, 000h, 011h, 007h, 016h, 000h, 0FFh, 000h, 01Ch, 000h
    db 00Fh, 007h, 016h, 000h, 0FFh, 000h, 01Fh, 000h, 00Bh, 007h, 017h, 000h, 0FFh, 000h, 025h, 000h
    db 001h, 007h, 01Bh, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h

landing_image_size equ 948
landing_image_end:
