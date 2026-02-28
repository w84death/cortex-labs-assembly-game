; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 840 bytes

landing_image:
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 044h, 000h, 049h, 00Ah, 0B3h, 000h, 031h, 000h, 070h, 00Ah, 09Fh, 000h
    db 029h, 000h, 084h, 00Ah, 093h, 000h, 020h, 000h, 09Ah, 00Ah, 086h, 000h, 018h, 000h, 0ADh, 00Ah
    db 07Bh, 000h, 010h, 000h, 0BEh, 00Ah, 072h, 000h, 00Ah, 000h, 0CCh, 00Ah, 06Ah, 000h, 005h, 000h
    db 0DAh, 00Ah, 061h, 000h, 001h, 000h, 0E7h, 00Ah, 058h, 000h, 0EFh, 00Ah, 051h, 000h, 070h, 00Ah
    db 042h, 000h, 043h, 00Ah, 04Bh, 000h, 064h, 00Ah, 05Bh, 000h, 03Dh, 00Ah, 044h, 000h, 059h, 00Ah
    db 074h, 000h, 036h, 00Ah, 03Dh, 000h, 054h, 00Ah, 083h, 000h, 033h, 00Ah, 036h, 000h, 04Eh, 00Ah
    db 092h, 000h, 030h, 00Ah, 00Eh, 000h, 013h, 00Ah, 00Fh, 000h, 048h, 00Ah, 0A1h, 000h, 051h, 00Ah
    db 006h, 000h, 042h, 00Ah, 0AFh, 000h, 04Fh, 00Ah, 03Eh, 00Ah, 0BAh, 000h, 048h, 00Ah, 03Bh, 00Ah
    db 0BFh, 000h, 046h, 00Ah, 038h, 00Ah, 0BDh, 000h, 04Bh, 00Ah, 035h, 00Ah, 0BBh, 000h, 050h, 00Ah
    db 032h, 00Ah, 0BBh, 000h, 053h, 00Ah, 02Fh, 00Ah, 0BBh, 000h, 056h, 00Ah, 02Bh, 00Ah, 0BCh, 000h
    db 059h, 00Ah, 029h, 00Ah, 0BBh, 000h, 05Ch, 00Ah, 028h, 00Ah, 0BAh, 000h, 05Eh, 00Ah, 026h, 00Ah
    db 0BAh, 000h, 060h, 00Ah, 024h, 00Ah, 0B9h, 000h, 063h, 00Ah, 023h, 00Ah, 0B9h, 000h, 064h, 00Ah
    db 021h, 00Ah, 042h, 000h, 001h, 003h, 001h, 00Ah, 00Dh, 000h, 005h, 007h, 063h, 000h, 00Eh, 00Ah
    db 001h, 007h, 057h, 00Ah, 01Fh, 00Ah, 053h, 000h, 005h, 003h, 062h, 000h, 00Dh, 00Ah, 005h, 007h
    db 055h, 00Ah, 01Eh, 00Ah, 056h, 000h, 001h, 003h, 062h, 000h, 002h, 007h, 00Ch, 00Ah, 009h, 007h
    db 052h, 00Ah, 01Ch, 00Ah, 0BAh, 000h, 002h, 007h, 00Bh, 00Ah, 00Eh, 007h, 04Fh, 00Ah, 01Ah, 00Ah
    db 0BAh, 000h, 005h, 007h, 008h, 00Ah, 013h, 007h, 04Ch, 00Ah, 019h, 00Ah, 0BAh, 000h, 007h, 007h
    db 005h, 00Ah, 017h, 007h, 04Ah, 00Ah, 019h, 00Ah, 0B8h, 000h, 00Bh, 007h, 001h, 00Ah, 01Ch, 007h
    db 047h, 00Ah, 018h, 00Ah, 0B8h, 000h, 02Bh, 007h, 01Eh, 00Ah, 003h, 007h, 024h, 00Ah, 017h, 00Ah
    db 0B8h, 000h, 02Fh, 007h, 019h, 00Ah, 007h, 007h, 022h, 00Ah, 017h, 00Ah, 0B7h, 000h, 032h, 007h
    db 015h, 00Ah, 00Bh, 007h, 019h, 00Ah, 002h, 007h, 005h, 00Ah, 016h, 00Ah, 0B7h, 000h, 036h, 007h
    db 00Fh, 00Ah, 010h, 007h, 013h, 00Ah, 008h, 007h, 003h, 00Ah, 015h, 00Ah, 0B7h, 000h, 039h, 007h
    db 00Bh, 00Ah, 014h, 007h, 00Dh, 00Ah, 00Dh, 007h, 002h, 00Ah, 015h, 00Ah, 0B6h, 000h, 03Ch, 007h
    db 006h, 00Ah, 019h, 007h, 007h, 00Ah, 013h, 007h, 014h, 00Ah, 0B6h, 000h, 040h, 007h, 001h, 00Ah
    db 01Dh, 007h, 002h, 00Ah, 016h, 007h, 014h, 00Ah, 0B6h, 000h, 076h, 007h, 013h, 00Ah, 0B6h, 000h
    db 001h, 003h, 007h, 007h, 003h, 003h, 06Ch, 007h, 012h, 00Ah, 0B7h, 000h, 007h, 007h, 005h, 003h
    db 06Bh, 007h, 012h, 00Ah, 0B6h, 000h, 001h, 003h, 007h, 007h, 007h, 003h, 069h, 007h, 011h, 00Ah
    db 0B7h, 000h, 001h, 003h, 006h, 007h, 009h, 003h, 068h, 007h, 011h, 00Ah, 0B6h, 000h, 003h, 003h
    db 004h, 007h, 00Bh, 003h, 067h, 007h, 011h, 00Ah, 0B5h, 000h, 004h, 003h, 003h, 007h, 00Eh, 003h
    db 065h, 007h, 011h, 00Ah, 0B5h, 000h, 005h, 003h, 001h, 007h, 011h, 003h, 063h, 007h, 011h, 00Ah
    db 0B5h, 000h, 019h, 003h, 01Ch, 007h, 003h, 003h, 042h, 007h, 011h, 00Ah, 0B4h, 000h, 01Ch, 003h
    db 019h, 007h, 007h, 003h, 03Fh, 007h, 011h, 00Ah, 0B4h, 000h, 01Eh, 003h, 016h, 007h, 00Ah, 003h
    db 03Dh, 007h, 012h, 00Ah, 0B2h, 000h, 021h, 003h, 013h, 007h, 00Eh, 003h, 03Ah, 007h, 012h, 00Ah
    db 09Ch, 000h, 002h, 003h, 014h, 000h, 023h, 003h, 00Fh, 007h, 012h, 003h, 01Eh, 007h, 001h, 003h
    db 019h, 007h, 012h, 00Ah, 0B2h, 000h, 026h, 003h, 00Bh, 007h, 016h, 003h, 01Ah, 007h, 004h, 003h
    db 017h, 007h, 012h, 00Ah, 0B2h, 000h, 028h, 003h, 008h, 007h, 01Ah, 003h, 015h, 007h, 009h, 003h
    db 014h, 007h, 012h, 00Ah, 0B1h, 000h, 02Bh, 003h, 005h, 007h, 01Eh, 003h, 011h, 007h, 00Ch, 003h
    db 00Eh, 007h, 004h, 003h, 012h, 00Ah, 0B1h, 000h, 02Dh, 003h, 001h, 007h, 022h, 003h, 00Dh, 007h
    db 010h, 003h, 004h, 007h, 00Ch, 003h, 013h, 00Ah, 0B0h, 000h, 053h, 003h, 009h, 007h, 021h, 003h
    db 013h, 00Ah, 0B0h, 000h, 056h, 003h, 005h, 007h, 022h, 003h, 013h, 00Ah, 0B0h, 000h, 07Dh, 003h
    db 013h, 00Ah, 0B0h, 000h, 07Dh, 003h, 013h, 00Ah, 0B0h, 000h, 07Dh, 003h, 013h, 00Ah, 0B1h, 000h
    db 07Ch, 003h, 013h, 00Ah, 0B1h, 000h, 07Ch, 003h, 014h, 00Ah, 0B0h, 000h, 07Ch, 003h, 015h, 00Ah
    db 0AFh, 000h, 07Ch, 003h, 016h, 00Ah, 0AFh, 000h, 07Bh, 003h, 017h, 00Ah, 0AEh, 000h, 07Bh, 003h
    db 017h, 00Ah, 0AEh, 000h, 07Bh, 003h, 018h, 00Ah, 0AEh, 000h, 07Ah, 003h, 019h, 00Ah, 0ADh, 000h
    db 07Ah, 003h, 01Ah, 00Ah, 0ADh, 000h, 079h, 003h, 01Bh, 00Ah, 0ACh, 000h, 079h, 003h, 01Ch, 00Ah
    db 0ACh, 000h, 078h, 003h, 01Ch, 00Ah, 0ADh, 000h, 077h, 003h, 01Dh, 00Ah, 0ACh, 000h, 077h, 003h
    db 01Eh, 00Ah, 0ACh, 000h, 076h, 003h, 01Fh, 00Ah, 0ACh, 000h, 075h, 003h, 020h, 00Ah, 0ACh, 000h
    db 074h, 003h, 021h, 00Ah, 0ACh, 000h, 073h, 003h, 021h, 00Ah, 0ADh, 000h, 072h, 003h, 022h, 00Ah
    db 0ADh, 000h, 071h, 003h, 023h, 00Ah, 0ADh, 000h, 070h, 003h, 024h, 00Ah, 0ADh, 000h, 06Fh, 003h
    db 025h, 00Ah, 0AEh, 000h, 06Dh, 003h, 025h, 00Ah, 0AFh, 000h, 06Ch, 003h, 026h, 00Ah, 0AFh, 000h
    db 06Bh, 003h, 028h, 00Ah, 0AFh, 000h, 069h, 003h

landing_image_size equ 840
landing_image_end:
