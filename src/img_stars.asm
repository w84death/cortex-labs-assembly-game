; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 594 bytes

stars_image:
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 048h, 000h, 003h, 003h, 0F5h, 000h, 01Dh, 000h, 001h, 00Fh, 0FFh, 000h, 023h, 000h, 01Ch, 000h
    db 003h, 00Fh, 06Eh, 000h, 001h, 003h, 05Ch, 000h, 003h, 003h, 053h, 000h, 01Ch, 000h, 003h, 00Fh
    db 06Bh, 000h, 007h, 003h, 04Eh, 000h, 003h, 00Fh, 05Eh, 000h, 01Dh, 000h, 001h, 00Fh, 037h, 000h
    db 003h, 003h, 035h, 000h, 001h, 003h, 0B2h, 000h, 0FFh, 000h, 027h, 000h, 001h, 00Fh, 019h, 000h
    db 0FFh, 000h, 026h, 000h, 003h, 00Fh, 018h, 000h, 0FFh, 000h, 026h, 000h, 003h, 00Fh, 018h, 000h
    db 0FFh, 000h, 027h, 000h, 001h, 00Fh, 019h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 02Eh, 000h, 003h, 00Fh, 09Eh, 000h, 003h, 003h, 06Eh, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 009h, 000h, 003h, 003h, 0FFh, 000h, 035h, 000h, 0FFh, 000h, 01Ah, 000h, 003h, 00Fh
    db 024h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 09Ch, 000h
    db 003h, 007h, 0A1h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 013h, 000h
    db 003h, 003h, 02Bh, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 032h, 000h, 001h, 003h, 051h, 000h, 003h, 00Fh, 0B9h, 000h, 02Fh, 000h
    db 007h, 003h, 082h, 000h, 001h, 007h, 087h, 000h, 032h, 000h, 001h, 003h, 082h, 000h, 007h, 007h
    db 084h, 000h, 0B8h, 000h, 001h, 007h, 087h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 04Ah, 000h, 003h, 003h, 0F3h, 000h, 0ECh, 000h, 003h, 003h, 051h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 028h, 000h, 002h, 00Fh, 0FFh, 000h, 017h, 000h, 0FFh, 000h, 041h, 000h, 076h, 000h, 003h, 00Fh
    db 01Fh, 000h, 001h, 003h, 0A7h, 000h, 095h, 000h, 007h, 003h, 0A4h, 000h, 098h, 000h, 001h, 003h
    db 0A7h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 00Bh, 000h, 003h, 00Fh, 033h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0CDh, 000h
    db 001h, 003h, 072h, 000h, 0CAh, 000h, 007h, 003h, 06Fh, 000h, 0CDh, 000h, 001h, 003h, 072h, 000h
    db 0FFh, 000h, 041h, 000h, 0BDh, 000h, 003h, 003h, 064h, 000h, 003h, 007h, 019h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 004h, 000h, 003h, 00Fh
    db 03Ah, 000h, 0A8h, 000h, 003h, 003h, 095h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 025h, 000h, 001h, 003h, 01Bh, 000h, 005h, 000h, 003h, 003h
    db 086h, 000h, 003h, 003h, 092h, 000h, 003h, 003h, 01Ah, 000h, 058h, 000h, 001h, 007h, 0CAh, 000h
    db 003h, 003h, 01Ah, 000h, 057h, 000h, 003h, 007h, 0B0h, 000h, 003h, 007h, 017h, 000h, 001h, 003h
    db 01Bh, 000h, 057h, 000h, 003h, 007h, 084h, 000h, 001h, 00Fh, 061h, 000h, 058h, 000h, 001h, 007h
    db 082h, 000h, 007h, 00Fh, 05Eh, 000h, 0DEh, 000h, 001h, 00Fh, 061h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 01Dh, 000h, 001h, 003h, 0FFh, 000h, 023h, 000h
    db 01Ch, 000h, 003h, 003h, 0FFh, 000h, 022h, 000h, 01Ch, 000h, 003h, 003h, 0FFh, 000h, 022h, 000h
    db 01Dh, 000h, 001h, 003h, 0FFh, 000h, 023h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 054h, 000h, 003h, 00Fh, 0E9h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h

    db 0, 0
