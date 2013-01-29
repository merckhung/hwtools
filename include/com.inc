;
; com.inc -- Header file related to COM Port routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


COM_PORT_A_BASE     EQU     03F8h
COM_PORT_B_BASE     EQU     02F8h


BAUD_2400           EQU     30h
BAUD_3600           EQU     20h
BAUD_4800           EQU     18h
BAUD_7200           EQU     10h
BAUD_9600           EQU     0Ch
BAUD_19200          EQU     06h
BAUD_38400          EQU     03h
BAUD_115200         EQU     01h



;##############################################################################
; ComPrintBufM -- Print Buffer via COM Port
;
; Input:
;   BUF     -- Buffer
;
; Output:
;   None
;
; Modified:
;   None
;
ComPrintBufM MACRO BUF


    ; Save Registers
    push    ds
    push    si


    ; Setup Pointer
    push    SEG BUF
    pop     ds
    mov     si, OFFSET BUF


    ; Print Buffer
    call    ComTransmitBuffer


    ; Restore Registers
    pop     si
    pop     ds


ENDM



;##############################################################################
; ComDebugStr -- Send Debug String via COM Port
;
; Input:
;   STRING  -- String Text
;
; Output:
;   None
;
; Modified:
;   None
;
ComDebugStr MACRO STRING


    LOCAL ComDbgString, ComDbgDone


    ; Print this string
    ComPrintBufM    ComDbgString
    jmp     ComDbgDone


ComDbgString    DB      STRING, 13, 10, 24h
ComDbgDone:


ENDM



