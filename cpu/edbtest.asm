;
; edbtest.asm -- AMD Processor NXE bit enable
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE ..\include\mroutine.inc
INCLUDE ..\include\routine.inc
INCLUDE ..\include\mdebug.inc


;------------------------------------------------------------------------------
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'


;
; extern sub-routines
;
routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
@CurSeg ENDS



;##############################################################################
; MAIN procedure
;
MAIN PROC FAR PRIVATE



    ; Save for DOS return
    push    ds
    push    ax



    ;--------------------------------------------------------------------------
    ; REAL mode code
    ;--------------------------------------------------------------------------
    ASSUME  SS:STACK, DS:_DATA, CS:_TEXT, ES:_DATA
    mov     ax, _DATA
    mov     ds, ax


    ;
    ; Before jump to
    ;
    print_str bef_msg
    wait_input


    ;
    ; jump to execute instruction in DATA segment
    ;
    DB      0eah
    DW      0000h
    DW      _DATA


    jmp     main_exit


main_exit:

    print_str en_msg
    print_str version

    ; Return to DOS
    ret

MAIN ENDP

_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 STACK 'STACK'
align 4

            ; print_str no_sup_msg
            DB      50h             ; push  ax
            DB      52h             ; push  dx
            DB      0B4h, 09h       ; mov   ah, 09h
            DB      0BAh, 09Eh, 00h ; mov   dx, offset no_sup_msg
            DB      0CDh, 21h       ; int   21h
            DB      5Ah             ; pop   dx
            DB      58h             ; pop   ax


            ; print_str version
            DB      50h             ; push  ax
            DB      52h             ; push  dx
            DB      0B4h, 09h       ; mov   ah, 09h
            DB      0BAh, 017h, 00h ; mov   dx, offset version
            DB      0CDh, 21h       ; int   21h
            DB      5Ah             ; pop   dx
            DB      58h             ; pop   ax


            ; retf
            DB      0CBh


version     DB      13, 10, 'edbtest version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h
bef_msg     DB      13, 10, 'Press any key to start verify Execute Disable Bit......', 13, 10, 24h
no_sup_msg  DB      13, 10, 'Execute Disable Bit feature does NOT ENABLE or SUPPORT by processor', 13, 10, 24h
en_msg      DB      13, 10, 'Execute Disable Bit WORKS!', 13, 10, 24h

_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     256 DUP(0)

STACK ENDS






    END MAIN


