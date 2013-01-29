;
; PROGRAM.asm -- PROGRAM_BRIEF_DESCRIPTION
;
; Copyright (C) 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; PROGRAM_DETIAL_DESCRIPTION
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc



;
; Extern Sub-Routines for Main Program
;
routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
@CurSeg ENDS



;------------------------------------------------------------------------------
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'



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
    ASSUME  SS:_STACK, DS:_DATA, CS:_TEXT, ES:_DATA
    mov     ax, _DATA
    mov     ds, ax

    mov     ax, es
    mov     PSP, ax

    mov     ax, _DATA
    mov     es, ax
    mov     gs, ax      ; This will be used in FLAT mode sys_print
    

    ;
    ; Main Flow Start
    ;




    ;
    ; End of Main Flow
    ;


main_exit:

    print_str VERSION
    
    ; Return to DOS
    ret

MAIN ENDP

_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 STACK 'DATA'
align 4


PSP         DW      0
VERSION     DB      13, 10, 'PROGRAM version 0.1 (C) 2008, Merck Hung', 13, 10, 13, 10, 24h
USAGE       DB      'Usage: PROGRAM', 13, 10, 13, 10, 24h


_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
_STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

_STACK ENDS


    END MAIN


