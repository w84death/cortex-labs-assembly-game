; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 586 bytes

earth_image:
    db 099h, 000h, 00Dh, 00Bh, 09Ah, 000h, 091h, 000h, 01Dh, 00Bh, 092h, 000h, 08Dh, 000h, 025h, 00Bh
    db 08Eh, 000h, 089h, 000h, 02Ch, 00Bh, 001h, 005h, 08Ah, 000h, 086h, 000h, 02Fh, 00Bh, 004h, 005h
    db 087h, 000h, 084h, 000h, 032h, 00Bh, 005h, 005h, 085h, 000h, 082h, 000h, 034h, 00Bh, 007h, 005h
    db 083h, 000h, 080h, 000h, 037h, 00Bh, 008h, 005h, 081h, 000h, 07Eh, 000h, 002h, 002h, 007h, 00Bh
    db 004h, 002h, 02Ch, 00Bh, 00Ah, 005h, 07Fh, 000h, 07Dh, 000h, 005h, 002h, 001h, 00Bh, 005h, 002h
    db 006h, 00Bh, 003h, 002h, 006h, 00Eh, 021h, 00Bh, 00Ah, 005h, 07Eh, 000h, 07Bh, 000h, 002h, 00Eh
    db 007h, 002h, 007h, 00Bh, 003h, 00Eh, 003h, 002h, 013h, 00Eh, 004h, 00Bh, 00Bh, 00Eh, 005h, 00Bh
    db 00Ch, 005h, 07Ch, 000h, 07Ah, 000h, 004h, 00Eh, 001h, 00Bh, 005h, 002h, 003h, 00Bh, 02Dh, 00Eh
    db 004h, 00Bh, 00Dh, 005h, 07Bh, 000h, 079h, 000h, 006h, 00Eh, 001h, 00Bh, 004h, 002h, 003h, 00Bh
    db 02Eh, 00Eh, 003h, 00Bh, 00Eh, 005h, 07Ah, 000h, 078h, 000h, 00Ah, 00Eh, 001h, 002h, 033h, 00Eh
    db 003h, 00Bh, 00Eh, 005h, 079h, 000h, 077h, 000h, 00Bh, 00Eh, 001h, 002h, 008h, 00Eh, 001h, 002h
    db 02Dh, 00Eh, 00Fh, 005h, 078h, 000h, 077h, 000h, 00Bh, 00Eh, 001h, 002h, 009h, 00Eh, 004h, 002h
    db 029h, 00Eh, 00Fh, 005h, 078h, 000h, 076h, 000h, 00Ch, 00Eh, 002h, 002h, 00Bh, 00Eh, 006h, 002h
    db 024h, 00Eh, 010h, 005h, 077h, 000h, 076h, 000h, 00Ch, 00Eh, 003h, 002h, 00Dh, 00Eh, 007h, 002h
    db 020h, 00Eh, 004h, 002h, 00Ch, 005h, 077h, 000h, 075h, 000h, 00Eh, 00Eh, 002h, 002h, 00Dh, 00Eh
    db 008h, 002h, 00Ah, 00Eh, 005h, 00Bh, 003h, 002h, 001h, 00Bh, 00Ch, 00Eh, 004h, 002h, 00Dh, 005h
    db 076h, 000h, 075h, 000h, 00Fh, 00Eh, 002h, 002h, 008h, 00Eh, 00Dh, 002h, 008h, 00Eh, 005h, 00Bh
    db 007h, 002h, 009h, 00Eh, 001h, 00Bh, 001h, 005h, 003h, 002h, 00Dh, 005h, 076h, 000h, 075h, 000h
    db 00Fh, 00Eh, 004h, 002h, 003h, 00Eh, 011h, 002h, 00Ah, 00Bh, 008h, 002h, 002h, 00Bh, 002h, 00Eh
    db 006h, 00Bh, 003h, 005h, 001h, 002h, 00Eh, 005h, 076h, 000h, 075h, 000h, 011h, 00Eh, 017h, 002h
    db 008h, 00Bh, 009h, 002h, 009h, 00Bh, 003h, 005h, 002h, 002h, 00Eh, 005h, 076h, 000h, 075h, 000h
    db 014h, 00Eh, 015h, 002h, 005h, 00Bh, 00Bh, 002h, 009h, 00Bh, 002h, 005h, 003h, 002h, 00Eh, 005h
    db 076h, 000h, 075h, 000h, 015h, 00Eh, 015h, 002h, 003h, 00Bh, 00Ch, 002h, 008h, 00Bh, 005h, 002h
    db 00Fh, 005h, 076h, 000h, 075h, 000h, 014h, 00Eh, 025h, 002h, 008h, 00Bh, 005h, 002h, 00Fh, 005h
    db 076h, 000h, 076h, 000h, 011h, 00Eh, 027h, 002h, 007h, 00Bh, 002h, 005h, 004h, 002h, 00Eh, 005h
    db 077h, 000h, 076h, 000h, 004h, 00Bh, 00Ch, 00Eh, 028h, 002h, 006h, 00Bh, 003h, 005h, 004h, 002h
    db 00Eh, 005h, 077h, 000h, 077h, 000h, 006h, 00Bh, 007h, 00Eh, 02Bh, 002h, 004h, 00Bh, 004h, 005h
    db 004h, 002h, 00Dh, 005h, 078h, 000h, 077h, 000h, 007h, 00Bh, 005h, 00Eh, 030h, 002h, 005h, 005h
    db 004h, 002h, 00Ch, 005h, 078h, 000h, 078h, 000h, 00Ah, 00Bh, 001h, 00Eh, 034h, 002h, 001h, 005h
    db 005h, 002h, 00Ah, 005h, 079h, 000h, 079h, 000h, 00Ah, 00Bh, 03Bh, 002h, 008h, 005h, 07Ah, 000h
    db 07Ah, 000h, 00Ah, 00Bh, 03Bh, 002h, 006h, 005h, 07Bh, 000h, 07Bh, 000h, 009h, 00Bh, 03Dh, 002h
    db 003h, 005h, 07Ch, 000h, 07Dh, 000h, 007h, 00Bh, 001h, 002h, 002h, 00Bh, 03Bh, 002h, 07Eh, 000h
    db 07Eh, 000h, 006h, 00Bh, 002h, 002h, 003h, 00Bh, 038h, 002h, 07Fh, 000h, 080h, 000h, 004h, 00Bh
    db 003h, 002h, 004h, 00Bh, 034h, 002h, 081h, 000h, 082h, 000h, 002h, 00Bh, 004h, 002h, 002h, 00Bh
    db 033h, 002h, 083h, 000h, 084h, 000h, 001h, 00Bh, 036h, 002h, 085h, 000h, 086h, 000h, 033h, 002h
    db 087h, 000h, 089h, 000h, 02Dh, 002h, 08Ah, 000h, 08Dh, 000h, 025h, 002h, 08Eh, 000h, 091h, 000h
    db 01Dh, 002h, 092h, 000h, 099h, 000h, 00Dh, 002h, 09Ah, 000h

    db 0, 0
