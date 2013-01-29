;
; flat.inc -- Header file related to FLAT routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


VIDEO_BASE  EQU     0b8000h
DEFA_SCR    EQU     0700h

COLUMN      EQU     80
LINE        EQU     25

BCOLUMN     EQU     COLUMN * 2

CRTC_ADDR   EQU     03d4h
CRTC_DATA   EQU     03d5h



;##############################################################################
; enter_flat_mode -- go to FLAT mode(BigReal mode)
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   ALL
;
; Mode:
;   REAL mode
;
enter_flat_mode MACRO

    ; Save segment for FLAT exit
    push    ds
    push    es
    call    __enter_flat_mode
ENDM



;##############################################################################
; exit_flat_mode -- Leave FLAT mode(BigReal mode)
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   ALL
;
; Mode:
;   FLAT mode
;
exit_flat_mode MACRO


    ; Restore original segments
    pop     es
    pop     ds
    call    __exit_flat_mode
ENDM



;##############################################################################
; flat_print -- FLAT mdoe print string
;
; Input :
;   POS = Line position
;   MSG = String offset in CS
;   LEN = String length
;
; Output:
;   EBX = Current cursor position
;
; Modified:
;   ESI
;   CX
;
flat_print MACRO MSG, POS

    push    esi

IFNB <POS>
    mov     edx, BCOLUMN * POS
ENDIF

    xor     esi, esi
    push    gs
    pop     si
    shl     esi, 4
    add     esi, offset MSG
    call    sys_print

    pop     esi
ENDM


;##############################################################################
; flat_replace_ascii_str -- macro version, convert ascii number into string buffer
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CX
;   DI
;
flat_replace_ascii_str MACRO STRP, BA, OFFS

    push    eax
    push    cx
    push    di

    xor     edi, edi
    push    gs
    pop     di
    shl     edi, 4
    add     edi, offset STRP
    add     edi, OFFS

    mov     cl, (BA - 1) * NBPAB
    call    flat_conv_push_ascii

    pop     di
    pop     cx
    pop     eax

ENDM



flat_print_ascii_str MACRO STRP, BA, OFFS

    flat_replace_ascii_str STRP, BA, OFFS
    flat_print STRP
ENDM
