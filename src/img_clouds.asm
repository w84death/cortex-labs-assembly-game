; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 1514 bytes

clouds_image:
    db 0FFh, 000h, 039h, 000h, 004h, 002h, 004h, 000h, 0FFh, 000h, 02Fh, 000h, 004h, 002h, 003h, 000h
    db 00Ah, 002h, 001h, 000h, 0FFh, 000h, 02Ch, 000h, 015h, 002h, 0FFh, 000h, 02Ah, 000h, 017h, 002h
    db 0FFh, 000h, 029h, 000h, 018h, 002h, 0FFh, 000h, 029h, 000h, 018h, 002h, 0FFh, 000h, 02Ah, 000h
    db 017h, 002h, 0FFh, 000h, 02Bh, 000h, 016h, 002h, 0FFh, 000h, 02Eh, 000h, 010h, 002h, 003h, 008h
    db 0FFh, 000h, 02Fh, 000h, 006h, 002h, 00Ch, 008h, 0FFh, 000h, 022h, 000h, 009h, 002h, 003h, 000h
    db 005h, 002h, 00Eh, 008h, 0FFh, 000h, 020h, 000h, 00Dh, 002h, 001h, 000h, 004h, 002h, 00Fh, 008h
    db 001h, 000h, 008h, 002h, 0FFh, 000h, 016h, 000h, 012h, 002h, 010h, 008h, 00Bh, 002h, 0FFh, 000h
    db 013h, 000h, 013h, 002h, 010h, 008h, 00Ch, 002h, 0FFh, 000h, 012h, 000h, 014h, 002h, 00Fh, 008h
    db 00Dh, 002h, 0FFh, 000h, 012h, 000h, 010h, 002h, 012h, 008h, 01Bh, 002h, 005h, 000h, 008h, 002h
    db 0F7h, 000h, 00Ch, 002h, 015h, 008h, 02Ah, 002h, 0F0h, 000h, 010h, 002h, 016h, 008h, 02Bh, 002h
    db 0EDh, 000h, 011h, 002h, 017h, 008h, 02Bh, 002h, 00Bh, 000h, 006h, 002h, 0DBh, 000h, 012h, 002h
    db 016h, 008h, 001h, 00Dh, 00Dh, 002h, 009h, 008h, 015h, 002h, 007h, 000h, 00Eh, 002h, 0D7h, 000h
    db 013h, 002h, 00Eh, 008h, 008h, 00Dh, 00Bh, 002h, 00Dh, 008h, 016h, 002h, 002h, 000h, 012h, 002h
    db 0D6h, 000h, 012h, 002h, 00Bh, 008h, 00Bh, 00Dh, 00Ah, 002h, 00Fh, 008h, 02Bh, 002h, 0D4h, 000h
    db 011h, 002h, 00Ah, 008h, 00Dh, 00Dh, 006h, 002h, 014h, 008h, 02Ch, 002h, 0D0h, 000h, 013h, 002h
    db 009h, 008h, 00Eh, 00Dh, 004h, 002h, 016h, 008h, 001h, 002h, 008h, 008h, 026h, 002h, 0B5h, 000h
    db 00Ah, 002h, 00Dh, 000h, 014h, 002h, 009h, 008h, 00Eh, 00Dh, 025h, 008h, 026h, 002h, 0A4h, 000h
    db 009h, 002h, 004h, 000h, 015h, 002h, 003h, 000h, 016h, 002h, 008h, 008h, 00Eh, 00Dh, 026h, 008h
    db 027h, 002h, 0A0h, 000h, 00Dh, 002h, 001h, 000h, 018h, 002h, 001h, 000h, 017h, 002h, 008h, 008h
    db 00Dh, 00Dh, 026h, 008h, 029h, 002h, 09Dh, 000h, 040h, 002h, 008h, 008h, 00Ch, 00Dh, 027h, 008h
    db 028h, 002h, 09Dh, 000h, 040h, 002h, 008h, 008h, 00Ch, 00Dh, 027h, 008h, 029h, 002h, 09Ch, 000h
    db 040h, 002h, 008h, 008h, 00Ch, 00Dh, 027h, 008h, 029h, 002h, 09Dh, 000h, 030h, 002h, 009h, 008h
    db 005h, 002h, 00Ah, 008h, 00Bh, 00Dh, 00Ah, 008h, 00Bh, 00Dh, 011h, 008h, 02Ah, 002h, 09Eh, 000h
    db 013h, 002h, 009h, 008h, 011h, 002h, 00Dh, 008h, 001h, 002h, 00Ch, 008h, 00Bh, 00Dh, 007h, 008h
    db 010h, 00Dh, 00Fh, 008h, 00Dh, 002h, 006h, 008h, 016h, 002h, 09Eh, 000h, 012h, 002h, 00Dh, 008h
    db 00Dh, 002h, 01Bh, 008h, 00Ch, 00Dh, 006h, 008h, 014h, 00Dh, 00Eh, 008h, 007h, 002h, 00Dh, 008h
    db 012h, 002h, 09Ch, 000h, 014h, 002h, 00Fh, 008h, 008h, 002h, 01Dh, 008h, 00Eh, 00Dh, 022h, 00Dh
    db 008h, 008h, 003h, 002h, 010h, 008h, 011h, 002h, 09Bh, 000h, 015h, 002h, 032h, 008h, 010h, 00Dh
    db 025h, 00Dh, 005h, 008h, 002h, 002h, 015h, 008h, 001h, 002h, 004h, 008h, 00Ah, 002h, 098h, 000h
    db 016h, 002h, 031h, 008h, 011h, 00Dh, 026h, 00Dh, 023h, 008h, 009h, 002h, 001h, 000h, 004h, 002h
    db 091h, 000h, 017h, 002h, 01Ch, 008h, 009h, 00Dh, 009h, 008h, 013h, 00Dh, 011h, 00Dh, 007h, 00Ch
    db 00Fh, 00Dh, 023h, 008h, 010h, 002h, 001h, 000h, 008h, 002h, 085h, 000h, 016h, 002h, 01Ah, 008h
    db 00Fh, 00Dh, 001h, 008h, 018h, 00Dh, 00Fh, 00Dh, 00Bh, 00Ch, 00Dh, 00Dh, 024h, 008h, 01Ah, 002h
    db 084h, 000h, 013h, 002h, 01Ah, 008h, 02Ah, 00Dh, 00Eh, 00Dh, 012h, 00Ch, 009h, 00Dh, 013h, 008h
    db 005h, 00Dh, 010h, 008h, 015h, 002h, 085h, 000h, 010h, 002h, 01Ah, 008h, 021h, 00Dh, 006h, 00Ch
    db 002h, 00Dh, 002h, 00Ch, 00Eh, 00Dh, 014h, 00Ch, 008h, 00Dh, 00Fh, 008h, 00Bh, 00Dh, 010h, 008h
    db 012h, 002h, 087h, 000h, 00Dh, 002h, 01Ah, 008h, 01Ah, 00Dh, 012h, 00Ch, 00Ah, 00Ch, 002h, 00Dh
    db 017h, 00Ch, 009h, 00Dh, 00Bh, 008h, 00Eh, 00Dh, 010h, 008h, 010h, 002h, 088h, 000h, 00Dh, 002h
    db 017h, 008h, 01Bh, 00Dh, 014h, 00Ch, 023h, 00Ch, 023h, 00Dh, 010h, 008h, 00Eh, 002h, 089h, 000h
    db 00Dh, 002h, 015h, 008h, 01Ch, 00Dh, 015h, 00Ch, 022h, 00Ch, 026h, 00Dh, 00Eh, 008h, 00Eh, 002h
    db 08Ah, 000h, 00Dh, 002h, 013h, 008h, 016h, 00Dh, 01Ch, 00Ch, 022h, 00Ch, 027h, 00Dh, 00Ch, 008h
    db 012h, 002h, 089h, 000h, 00Ch, 002h, 012h, 008h, 014h, 00Dh, 01Eh, 00Ch, 02Ch, 00Ch, 01Eh, 00Dh
    db 00Bh, 008h, 014h, 002h, 07Bh, 000h, 009h, 002h, 008h, 000h, 009h, 002h, 010h, 008h, 014h, 00Dh
    db 01Eh, 00Ch, 038h, 00Ch, 012h, 00Dh, 00Eh, 008h, 013h, 002h, 077h, 000h, 00Dh, 002h, 006h, 000h
    db 013h, 002h, 006h, 008h, 014h, 00Dh, 01Eh, 00Ch, 00Ah, 00Ch, 005h, 00Fh, 02Bh, 00Ch, 010h, 00Dh
    db 010h, 008h, 012h, 002h, 060h, 000h, 006h, 002h, 00Fh, 000h, 00Fh, 002h, 006h, 000h, 011h, 002h
    db 008h, 008h, 014h, 00Dh, 01Dh, 00Ch, 004h, 00Fh, 004h, 00Ch, 009h, 00Fh, 029h, 00Ch, 010h, 00Dh
    db 018h, 008h, 00Fh, 002h, 058h, 000h, 015h, 002h, 003h, 000h, 00Fh, 002h, 004h, 000h, 013h, 002h
    db 00Ah, 008h, 014h, 00Dh, 01Bh, 00Ch, 012h, 00Fh, 028h, 00Ch, 00Fh, 00Dh, 01Dh, 008h, 00Dh, 002h
    db 055h, 000h, 028h, 002h, 002h, 000h, 013h, 002h, 00Eh, 008h, 013h, 00Dh, 01Ah, 00Ch, 012h, 00Fh
    db 007h, 00Ch, 00Bh, 00Fh, 015h, 00Ch, 013h, 00Dh, 01Ch, 008h, 00Ch, 002h, 053h, 000h, 031h, 002h
    db 006h, 008h, 005h, 002h, 012h, 008h, 011h, 00Dh, 011h, 00Ch, 009h, 00Fh, 026h, 00Fh, 012h, 00Ch
    db 018h, 00Dh, 01Bh, 008h, 00Ah, 002h, 052h, 000h, 02Dh, 002h, 022h, 008h, 010h, 00Dh, 00Fh, 00Ch
    db 00Bh, 00Fh, 027h, 00Fh, 012h, 00Ch, 006h, 00Dh, 009h, 00Ch, 00Ch, 00Dh, 002h, 008h, 006h, 00Dh
    db 010h, 008h, 009h, 002h, 053h, 000h, 02Ah, 002h, 022h, 008h, 010h, 00Dh, 010h, 00Ch, 00Ch, 00Fh
    db 027h, 00Fh, 014h, 00Ch, 002h, 00Dh, 00Dh, 00Ch, 015h, 00Dh, 00Eh, 008h, 00Ah, 002h, 052h, 000h
    db 027h, 002h, 023h, 008h, 010h, 00Dh, 006h, 00Ch, 009h, 00Fh, 002h, 00Ch, 00Ch, 00Fh, 027h, 00Fh
    db 024h, 00Ch, 016h, 00Dh, 00Ch, 008h, 00Ch, 002h, 052h, 000h, 024h, 002h, 014h, 008h, 007h, 00Dh
    db 008h, 008h, 00Fh, 00Dh, 006h, 00Ch, 00Dh, 00Fh, 001h, 00Ch, 00Bh, 00Fh, 02Ah, 00Fh, 021h, 00Ch
    db 017h, 00Dh, 00Eh, 008h, 00Bh, 002h, 04Fh, 000h, 024h, 002h, 012h, 008h, 00Eh, 00Dh, 003h, 008h
    db 00Fh, 00Dh, 006h, 00Ch, 01Ah, 00Fh, 02Ch, 00Fh, 020h, 00Ch, 017h, 00Dh, 00Fh, 008h, 007h, 002h
    db 006h, 008h, 045h, 000h, 00Eh, 002h, 008h, 008h, 001h, 002h, 001h, 008h, 010h, 002h, 013h, 008h
    db 021h, 00Dh, 006h, 00Ch, 01Ah, 00Fh, 02Dh, 00Fh, 020h, 00Ch, 016h, 00Dh, 020h, 008h, 001h, 000h
    db 005h, 008h, 023h, 000h, 009h, 002h, 005h, 000h, 004h, 008h, 002h, 000h, 010h, 002h, 018h, 008h
    db 002h, 002h, 005h, 008h, 00Ch, 00Dh, 003h, 008h, 022h, 00Dh, 006h, 00Ch, 01Ah, 00Fh, 038h, 00Fh
    db 015h, 00Ch, 016h, 00Dh, 029h, 008h, 01Ch, 000h, 00Fh, 002h, 00Ah, 008h, 00Eh, 002h, 018h, 008h
    db 005h, 00Dh, 001h, 008h, 033h, 00Dh, 007h, 00Ch, 019h, 00Fh, 03Ah, 00Fh, 013h, 00Ch, 016h, 00Dh
    db 02Ch, 008h, 004h, 000h, 007h, 008h, 00Ch, 000h, 010h, 002h, 00Ch, 008h, 00Dh, 002h, 015h, 008h
    db 03Dh, 00Dh, 007h, 00Ch, 018h, 00Fh, 03Bh, 00Fh, 012h, 00Ch, 006h, 00Dh, 006h, 00Ch, 009h, 00Dh
    db 03Dh, 008h, 005h, 000h, 005h, 002h, 007h, 008h, 005h, 002h, 001h, 008h, 009h, 00Dh, 004h, 008h
    db 001h, 002h, 005h, 008h, 007h, 002h, 009h, 008h, 005h, 00Dh, 005h, 008h, 035h, 00Dh, 007h, 00Ch
    db 004h, 00Dh, 007h, 00Ch, 00Ah, 00Fh, 002h, 00Ch, 00Ah, 00Fh, 03Ch, 00Fh, 013h, 00Ch, 002h, 00Dh
    db 00Ah, 00Ch, 009h, 00Dh, 00Fh, 008h, 009h, 00Dh, 025h, 008h, 002h, 000h, 002h, 002h, 00Fh, 008h
    db 00Dh, 00Dh, 015h, 008h, 00Bh, 00Dh, 001h, 008h, 034h, 00Dh, 00Bh, 00Ch, 003h, 00Dh, 012h, 00Ch
    db 00Ah, 00Fh, 03Ch, 00Fh, 021h, 00Ch, 001h, 00Dh, 006h, 00Ch, 00Ah, 00Dh, 002h, 008h, 00Eh, 00Dh
    db 014h, 008h, 00Dh, 00Dh, 004h, 008h, 00Eh, 00Dh, 002h, 008h, 010h, 00Dh, 012h, 008h, 040h, 00Dh
    db 020h, 00Ch, 00Bh, 00Fh, 03Ch, 00Fh, 02Bh, 00Ch, 018h, 00Dh, 007h, 008h, 03Fh, 00Dh, 001h, 008h
    db 006h, 00Dh, 006h, 008h, 043h, 00Dh, 018h, 00Ch, 006h, 00Fh, 001h, 00Ch, 00Ch, 00Fh, 03Bh, 00Fh
    db 02Fh, 00Ch, 00Ah, 00Dh, 009h, 00Ch, 037h, 00Dh, 005h, 00Ch, 043h, 00Dh, 005h, 00Ch, 014h, 00Dh
    db 015h, 00Ch, 016h, 00Fh, 040h, 00Fh, 02Ch, 00Ch, 006h, 00Dh, 00Dh, 00Ch, 032h, 00Dh, 00Ch, 00Ch
    db 03Ch, 00Dh, 00Bh, 00Ch, 013h, 00Dh, 012h, 00Ch, 017h, 00Fh, 042h, 00Fh, 02Bh, 00Ch, 004h, 00Dh
    db 010h, 00Ch, 004h, 00Dh, 00Bh, 00Ch, 00Eh, 00Dh, 005h, 00Ch, 00Dh, 00Dh, 012h, 00Ch, 027h, 00Dh
    db 006h, 00Ch, 009h, 00Dh, 00Dh, 00Ch, 001h, 00Dh, 021h, 00Ch, 019h, 00Fh, 044h, 00Fh, 029h, 00Ch
    db 004h, 00Dh, 024h, 00Ch, 006h, 00Dh, 015h, 00Ch, 009h, 00Fh, 00Fh, 00Ch, 012h, 00Dh, 006h, 00Ch
    db 006h, 00Dh, 00Ch, 00Ch, 005h, 00Dh, 02Fh, 00Ch, 01Ah, 00Fh, 044h, 00Fh, 02Ah, 00Ch, 003h, 00Dh
    db 03Bh, 00Ch, 00Fh, 00Fh, 028h, 00Ch, 002h, 00Dh, 00Eh, 00Ch, 004h, 00Dh, 02Eh, 00Ch, 01Bh, 00Fh
    db 044h, 00Fh, 064h, 00Ch, 014h, 00Fh, 038h, 00Ch, 002h, 00Dh, 014h, 00Ch, 008h, 00Fh, 00Eh, 00Ch
    db 020h, 00Fh, 045h, 00Fh, 054h, 00Ch, 00Ah, 00Fh, 002h, 00Ch, 017h, 00Fh, 004h, 00Ch, 012h, 00Fh
    db 022h, 00Ch, 001h, 00Dh, 013h, 00Ch, 00Ch, 00Fh, 00Ah, 00Ch, 022h, 00Fh, 047h, 00Fh, 007h, 00Ch
    db 009h, 00Fh, 040h, 00Ch, 03Dh, 00Fh, 01Dh, 00Ch, 00Fh, 00Fh, 008h, 00Ch, 00Dh, 00Fh, 004h, 00Ch
    db 027h, 00Fh, 048h, 00Fh, 004h, 00Ch, 00Dh, 00Fh, 03Dh, 00Ch, 040h, 00Fh, 016h, 00Ch, 054h, 00Fh
    db 04Ah, 00Fh, 001h, 00Ch, 010h, 00Fh, 00Ch, 00Ch, 009h, 00Fh, 003h, 00Ch, 00Ch, 00Fh, 00Ch, 00Ch
    db 008h, 00Fh, 002h, 00Ch, 042h, 00Fh, 012h, 00Ch, 057h, 00Fh, 05Ch, 00Fh, 006h, 00Ch, 020h, 00Fh
    db 007h, 00Ch, 04Eh, 00Fh, 009h, 00Ch, 060h, 00Fh, 05Dh, 00Fh, 003h, 00Ch, 025h, 00Fh, 003h, 00Ch
    db 04Fh, 00Fh, 007h, 00Ch, 062h, 00Fh, 0FFh, 00Fh, 041h, 00Fh

    db 0, 0
