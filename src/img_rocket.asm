; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 788 bytes

rocket_image:
    db 0FFh, 000h, 014h, 000h, 002h, 002h, 004h, 000h, 002h, 002h, 004h, 000h, 002h, 002h, 003h, 000h
    db 002h, 002h, 01Ah, 000h, 0FFh, 000h, 012h, 000h, 001h, 00Fh, 010h, 002h, 001h, 00Fh, 005h, 002h
    db 018h, 000h, 0FFh, 000h, 010h, 000h, 005h, 00Fh, 001h, 002h, 004h, 00Fh, 002h, 002h, 004h, 00Fh
    db 001h, 002h, 005h, 00Fh, 001h, 002h, 004h, 00Fh, 016h, 000h, 0FFh, 000h, 00Eh, 000h, 01Fh, 00Fh
    db 014h, 000h, 0FFh, 000h, 00Ch, 000h, 022h, 00Fh, 001h, 002h, 012h, 000h, 0FFh, 000h, 00Ah, 000h
    db 022h, 00Fh, 005h, 002h, 010h, 000h, 0FFh, 000h, 008h, 000h, 004h, 00Ah, 022h, 00Fh, 002h, 002h
    db 011h, 000h, 0FFh, 000h, 006h, 000h, 002h, 00Fh, 006h, 00Ah, 015h, 00Fh, 001h, 00Ah, 004h, 00Fh
    db 002h, 00Ah, 004h, 00Fh, 002h, 002h, 011h, 000h, 0FFh, 000h, 004h, 000h, 006h, 00Fh, 006h, 00Ah
    db 011h, 00Fh, 00Bh, 00Ah, 006h, 002h, 00Fh, 000h, 0FFh, 000h, 002h, 000h, 004h, 00Ah, 006h, 00Fh
    db 002h, 00Ah, 011h, 00Fh, 00Fh, 00Ah, 002h, 002h, 011h, 000h, 0FFh, 000h, 003h, 00Fh, 005h, 00Ah
    db 009h, 00Fh, 003h, 00Ah, 009h, 00Fh, 011h, 00Ah, 002h, 002h, 011h, 000h, 0FDh, 000h, 007h, 00Fh
    db 005h, 00Ah, 006h, 00Fh, 006h, 00Ah, 005h, 00Fh, 005h, 00Ah, 001h, 002h, 00Bh, 00Ah, 005h, 002h
    db 010h, 000h, 0FBh, 000h, 00Bh, 00Fh, 005h, 00Ah, 006h, 00Fh, 006h, 00Ah, 001h, 00Fh, 005h, 00Ah
    db 005h, 002h, 00Bh, 00Ah, 001h, 002h, 012h, 000h, 0F9h, 000h, 00Fh, 00Fh, 005h, 00Ah, 006h, 00Fh
    db 003h, 00Ah, 003h, 002h, 005h, 00Ah, 006h, 002h, 008h, 00Ah, 003h, 002h, 011h, 000h, 0F7h, 000h
    db 013h, 00Fh, 005h, 00Ah, 005h, 00Fh, 001h, 00Ah, 006h, 002h, 004h, 00Ah, 007h, 002h, 006h, 00Ah
    db 004h, 002h, 010h, 000h, 0F5h, 000h, 017h, 00Fh, 005h, 00Ah, 001h, 00Fh, 005h, 00Ah, 011h, 002h
    db 006h, 00Ah, 012h, 000h, 0F3h, 000h, 01Bh, 00Fh, 002h, 00Ah, 003h, 002h, 006h, 00Ah, 008h, 002h
    db 003h, 00Ah, 002h, 002h, 006h, 00Ah, 014h, 000h, 0F1h, 000h, 002h, 00Ah, 01Bh, 00Fh, 002h, 00Ah
    db 005h, 002h, 006h, 00Ah, 006h, 002h, 009h, 00Ah, 016h, 000h, 0EFh, 000h, 001h, 00Fh, 005h, 00Ah
    db 017h, 00Fh, 006h, 00Ah, 005h, 002h, 006h, 00Ah, 006h, 002h, 005h, 00Ah, 018h, 000h, 0EDh, 000h
    db 005h, 00Fh, 005h, 00Ah, 013h, 00Fh, 00Ah, 00Ah, 005h, 002h, 006h, 00Ah, 006h, 002h, 001h, 00Ah
    db 01Ah, 000h, 0EBh, 000h, 009h, 00Fh, 005h, 00Ah, 00Fh, 00Fh, 00Eh, 00Ah, 005h, 002h, 006h, 00Ah
    db 003h, 002h, 01Ch, 000h, 0E9h, 000h, 00Dh, 00Fh, 005h, 00Ah, 00Bh, 00Fh, 012h, 00Ah, 005h, 002h
    db 005h, 00Ah, 01Eh, 000h, 0E7h, 000h, 011h, 00Fh, 005h, 00Ah, 007h, 00Fh, 016h, 00Ah, 005h, 002h
    db 001h, 00Ah, 020h, 000h, 0E5h, 000h, 015h, 00Fh, 005h, 00Ah, 003h, 00Fh, 005h, 00Ah, 004h, 002h
    db 011h, 00Ah, 002h, 002h, 022h, 000h, 0E3h, 000h, 019h, 00Fh, 004h, 00Ah, 001h, 002h, 006h, 00Ah
    db 004h, 002h, 011h, 00Ah, 024h, 000h, 0E1h, 000h, 01Dh, 00Fh, 005h, 002h, 017h, 00Ah, 026h, 000h
    db 0DFh, 000h, 01Dh, 00Fh, 004h, 00Ah, 005h, 002h, 002h, 00Ah, 004h, 002h, 002h, 00Ah, 004h, 002h
    db 007h, 00Ah, 028h, 000h, 0DDh, 000h, 01Dh, 00Fh, 008h, 00Ah, 009h, 002h, 002h, 00Ah, 003h, 002h
    db 006h, 00Ah, 02Ah, 000h, 0DBh, 000h, 001h, 00Ah, 01Ch, 00Fh, 005h, 00Ah, 001h, 002h, 005h, 00Ah
    db 006h, 002h, 00Bh, 00Ah, 02Ch, 000h, 0D9h, 000h, 005h, 00Ah, 018h, 00Fh, 005h, 00Ah, 005h, 002h
    db 001h, 00Ah, 00Ah, 002h, 007h, 00Ah, 02Eh, 000h, 0D7h, 000h, 003h, 002h, 006h, 00Ah, 014h, 00Fh
    db 008h, 00Ah, 003h, 002h, 003h, 00Ah, 003h, 002h, 003h, 00Ah, 005h, 002h, 003h, 00Ah, 030h, 000h
    db 0D7h, 000h, 005h, 002h, 006h, 00Ah, 010h, 00Fh, 011h, 00Ah, 001h, 002h, 006h, 00Ah, 004h, 002h
    db 032h, 000h, 0D9h, 000h, 005h, 002h, 006h, 00Ah, 00Ch, 00Fh, 011h, 00Ah, 005h, 002h, 006h, 00Ah
    db 034h, 000h, 0D7h, 000h, 009h, 002h, 006h, 00Ah, 002h, 00Fh, 004h, 00Ah, 002h, 00Fh, 014h, 00Ah
    db 002h, 002h, 006h, 00Ah, 036h, 000h, 0D5h, 000h, 002h, 00Fh, 004h, 002h, 002h, 00Fh, 005h, 002h
    db 026h, 00Ah, 038h, 000h, 0D3h, 000h, 00Bh, 00Fh, 001h, 00Ah, 005h, 002h, 022h, 00Ah, 03Ah, 000h
    db 0D1h, 000h, 006h, 00Fh, 004h, 00Ah, 001h, 00Fh, 005h, 00Ah, 005h, 002h, 01Eh, 00Ah, 03Ch, 000h
    db 0D2h, 000h, 005h, 00Fh, 003h, 00Ah, 003h, 002h, 003h, 00Ah, 008h, 002h, 01Ah, 00Ah, 03Eh, 000h
    db 0D4h, 000h, 004h, 00Fh, 006h, 002h, 001h, 00Fh, 005h, 002h, 001h, 00Fh, 005h, 002h, 016h, 00Ah
    db 040h, 000h, 0D6h, 000h, 006h, 002h, 005h, 00Fh, 001h, 002h, 005h, 00Fh, 005h, 002h, 012h, 00Ah
    db 042h, 000h, 0D8h, 000h, 002h, 002h, 006h, 00Fh, 003h, 00Ah, 002h, 00Fh, 009h, 002h, 00Eh, 00Ah
    db 044h, 000h, 0DAh, 000h, 005h, 00Fh, 004h, 00Ah, 006h, 002h, 002h, 00Fh, 005h, 002h, 00Ah, 00Ah
    db 046h, 000h, 0DCh, 000h, 005h, 00Fh, 006h, 002h, 006h, 00Fh, 005h, 002h, 006h, 00Ah, 048h, 000h
    db 0DEh, 000h, 001h, 00Fh, 006h, 002h, 004h, 00Ah, 002h, 00Fh, 009h, 002h, 002h, 00Ah, 04Ah, 000h
    db 0E0h, 000h, 003h, 002h, 002h, 00Fh, 004h, 00Ah, 002h, 00Fh, 003h, 002h, 003h, 000h, 003h, 002h
    db 04Ch, 000h, 0E2h, 000h, 00Ah, 00Fh, 054h, 000h, 0E4h, 000h, 006h, 00Fh, 056h, 000h, 0E6h, 000h
    db 002h, 00Fh, 058h, 000h

    db 0, 0
