;
; scn.inc -- Header file related to Screen routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


VIDEORAM            EQU     0B800h
COLUMN              EQU     80
LINE                EQU     25
CELL                EQU     2

COL_WB              EQU     0700h

F_BLACK             EQU     000h
F_BLUE              EQU     001h
F_GREEN             EQU     002h
F_CYAN              EQU     003h
F_RED               EQU     004h
F_MAGENTA           EQU     005h
F_BROWN             EQU     006h
F_LIGHT_GRAY        EQU     007h
F_DRAK_GRAY         EQU     008h
F_LIGHT_BLUE        EQU     009h
F_LIGHT_GREEN       EQU     00Ah
F_LIGHT_CYAN        EQU     00Bh
F_LIGHT_RED         EQU     00Ch
F_LIGHT_MAGENTA     EQU     00Dh
F_YELLOW            EQU     00Eh
F_WHITE             EQU     00Fh

B_BLACK             EQU     000h
B_BLUE              EQU     010h
B_GREEN             EQU     020h
B_CYAN              EQU     030h
B_RED               EQU     040h
B_MAGENTA           EQU     050h
B_BROWN             EQU     060h
B_LIGHT_GRAY        EQU     070h
B_BLINKING_BLACK    EQU     080h
B_BLINKING_BLUE     EQU     090h
B_BLINKING_GREEN    EQU     0A0h
B_BLINKING_CYAN     EQU     0B0h
B_BLINKING_RED      EQU     0C0h
B_BLINKING_MAGENTA  EQU     0D0h
B_BLINKING_BROWN    EQU     0E0h
B_BLINKING_LIGHT_GRAY   EQU 0F0h

PRECENT_PROGRESS    EQU     35
LINEOF_PROGRAM      EQU     5
LINEOF_ERASE        EQU     4


