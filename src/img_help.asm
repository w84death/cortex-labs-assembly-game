; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 838 bytes

help_image:
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 020h, 000h, 001h, 003h, 002h, 00Ah, 0FFh, 000h
    db 01Eh, 000h, 020h, 000h, 004h, 003h, 0FBh, 000h, 005h, 007h, 01Ch, 000h, 081h, 000h, 009h, 00Ah
    db 095h, 000h, 005h, 003h, 01Ch, 000h, 080h, 000h, 012h, 00Ah, 0AEh, 000h, 02Ch, 000h, 007h, 007h
    db 04Eh, 000h, 017h, 00Ah, 0A8h, 000h, 02Bh, 000h, 002h, 007h, 005h, 003h, 002h, 007h, 04Fh, 000h
    db 01Bh, 00Ah, 0A2h, 000h, 02Ch, 000h, 008h, 003h, 051h, 000h, 01Fh, 00Ah, 09Ch, 000h, 02Ch, 000h
    db 008h, 003h, 053h, 000h, 00Dh, 00Ah, 00Dh, 000h, 008h, 00Ah, 097h, 000h, 08Ah, 000h, 00Bh, 00Ah
    db 012h, 000h, 007h, 00Ah, 092h, 000h, 08Ch, 000h, 00Bh, 00Ah, 016h, 000h, 006h, 00Ah, 01Fh, 000h
    db 013h, 00Ah, 05Bh, 000h, 08Fh, 000h, 00Ah, 00Ah, 019h, 000h, 006h, 00Ah, 015h, 000h, 01Dh, 00Ah
    db 056h, 000h, 092h, 000h, 009h, 00Ah, 01Ch, 000h, 006h, 00Ah, 00Dh, 000h, 023h, 00Ah, 053h, 000h
    db 095h, 000h, 009h, 00Ah, 00Ch, 000h, 003h, 003h, 00Fh, 000h, 005h, 00Ah, 007h, 000h, 007h, 00Ah
    db 005h, 007h, 01Ch, 00Ah, 050h, 000h, 098h, 000h, 009h, 00Ah, 020h, 000h, 006h, 00Ah, 005h, 007h
    db 001h, 00Ah, 00Bh, 007h, 007h, 00Ah, 002h, 007h, 011h, 00Ah, 04Eh, 000h, 09Bh, 000h, 009h, 00Ah
    db 021h, 000h, 017h, 007h, 001h, 00Ah, 007h, 007h, 001h, 00Ah, 004h, 007h, 00Bh, 00Ah, 04Ch, 000h
    db 09Eh, 000h, 009h, 00Ah, 01Ch, 000h, 028h, 007h, 003h, 00Ah, 006h, 007h, 001h, 00Ah, 04Bh, 000h
    db 0A2h, 000h, 008h, 00Ah, 018h, 000h, 007h, 007h, 003h, 003h, 02Bh, 007h, 049h, 000h, 0A5h, 000h
    db 008h, 00Ah, 014h, 000h, 001h, 007h, 003h, 003h, 002h, 007h, 009h, 003h, 008h, 007h, 004h, 003h
    db 01Ch, 007h, 048h, 000h, 0A9h, 000h, 008h, 00Ah, 010h, 000h, 012h, 003h, 004h, 007h, 008h, 003h
    db 004h, 007h, 003h, 003h, 002h, 007h, 011h, 003h, 047h, 000h, 0ACh, 000h, 008h, 00Ah, 00Ch, 000h
    db 039h, 003h, 047h, 000h, 0B0h, 000h, 008h, 00Ah, 008h, 000h, 039h, 003h, 047h, 000h, 0B3h, 000h
    db 008h, 00Ah, 004h, 000h, 03Bh, 003h, 046h, 000h, 0B7h, 000h, 008h, 00Ah, 03Bh, 003h, 046h, 000h
    db 0BAh, 000h, 008h, 00Ah, 037h, 003h, 047h, 000h, 0BEh, 000h, 008h, 00Ah, 033h, 003h, 047h, 000h
    db 0BFh, 000h, 003h, 003h, 008h, 00Ah, 02Fh, 003h, 047h, 000h, 0BFh, 000h, 007h, 003h, 008h, 00Ah
    db 02Ah, 003h, 003h, 00Ah, 045h, 000h, 0C0h, 000h, 00Ah, 003h, 008h, 00Ah, 025h, 003h, 003h, 000h
    db 004h, 00Ah, 042h, 000h, 0C0h, 000h, 00Eh, 003h, 008h, 00Ah, 021h, 003h, 007h, 000h, 004h, 00Ah
    db 03Eh, 000h, 060h, 000h, 001h, 003h, 002h, 00Ah, 05Eh, 000h, 011h, 003h, 008h, 00Ah, 01Bh, 003h
    db 00Ch, 000h, 005h, 00Ah, 03Ah, 000h, 060h, 000h, 003h, 003h, 060h, 000h, 013h, 003h, 008h, 00Ah
    db 016h, 003h, 011h, 000h, 004h, 00Ah, 037h, 000h, 0C4h, 000h, 016h, 003h, 009h, 00Ah, 010h, 003h
    db 015h, 000h, 005h, 00Ah, 033h, 000h, 0C6h, 000h, 018h, 003h, 009h, 00Ah, 00Bh, 003h, 019h, 000h
    db 005h, 00Ah, 030h, 000h, 0C8h, 000h, 01Ah, 003h, 009h, 00Ah, 005h, 003h, 01Fh, 000h, 004h, 00Ah
    db 02Dh, 000h, 0CBh, 000h, 01Bh, 003h, 00Ah, 00Ah, 022h, 000h, 005h, 00Ah, 029h, 000h, 0CEh, 000h
    db 01Dh, 003h, 009h, 00Ah, 021h, 000h, 005h, 00Ah, 026h, 000h, 0D3h, 000h, 014h, 003h, 008h, 000h
    db 00Ah, 00Ah, 01Eh, 000h, 006h, 00Ah, 023h, 000h, 0F4h, 000h, 00Ah, 00Ah, 01Ch, 000h, 006h, 00Ah
    db 020h, 000h, 0F8h, 000h, 00Bh, 00Ah, 019h, 000h, 007h, 00Ah, 01Dh, 000h, 0FDh, 000h, 00Ch, 00Ah
    db 016h, 000h, 007h, 00Ah, 01Ah, 000h, 0FFh, 000h, 003h, 000h, 00Dh, 00Ah, 011h, 000h, 009h, 00Ah
    db 017h, 000h, 0FFh, 000h, 008h, 000h, 00Eh, 00Ah, 00Ch, 000h, 00Ah, 00Ah, 015h, 000h, 0FFh, 000h
    db 00Dh, 000h, 022h, 00Ah, 012h, 000h, 0FFh, 000h, 012h, 000h, 01Fh, 00Ah, 010h, 000h, 0FFh, 000h
    db 018h, 000h, 01Bh, 00Ah, 00Eh, 000h, 05Ch, 000h, 001h, 003h, 002h, 00Ah, 0BDh, 000h, 018h, 00Ah
    db 00Ch, 000h, 05Dh, 000h, 002h, 003h, 0C4h, 000h, 012h, 00Ah, 00Bh, 000h, 0FFh, 000h, 02Ch, 000h
    db 00Ah, 00Ah, 00Bh, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0B3h, 000h, 001h, 00Ah, 08Ch, 000h, 0B2h, 000h, 003h, 003h, 08Bh, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 02Ch, 000h, 005h, 007h, 001h, 003h, 0EEh, 000h
    db 004h, 00Ah, 01Ch, 000h, 02Ch, 000h, 005h, 007h, 002h, 003h, 0ECh, 000h, 006h, 007h, 01Bh, 000h
    db 02Ch, 000h, 006h, 003h, 0EDh, 000h, 005h, 003h, 01Ch, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h

help_image_size equ 838
help_image_end:
