;
; buslock.asm -- PCI Bus Locked Operation
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc
INCLUDE include\flat.inc


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


libflat SEGMENT USE16 PUBLIC

    EXTERN __enter_flat_mode:FAR
    EXTERN __exit_flat_mode:FAR
    EXTERN copy_data:FAR
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

    mov     ax, es
    mov     PSP, ax

    mov     ax, _DATA
    mov     es, ax


;--------------------------------------------------------------------------
; Enter FLAT mode
;--------------------------------------------------------------------------
enter_flat_mode
;--------------------------------------------------------------------------
; FLAT mode code start
;--------------------------------------------------------------------------
    

    ;
    ; Main Flow Start
    ;
    mov     eax, 0DF480000h
    mov     ebx, 0ffffffffh
    lock    xchg    dword ptr [eax], ebx



    ;
    ; End of Main Flow
    ;


;--------------------------------------------------------------------------
; Exit FLAT mode
;--------------------------------------------------------------------------
exit_flat_mode
;--------------------------------------------------------------------------
; REAL mode code
;--------------------------------------------------------------------------


main_exit:

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


PSP         DW      0
version     DB      13, 10, 'buslock version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: buslock', 13, 10, 13, 10, 24h

_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

STACK ENDS


    END MAIN


