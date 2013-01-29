;
; scnshot.asm -- VGA Text Mode Screenshot capturer
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a small tool for capturing VGA Text Mode Screenshot and directly save
; into FAT12, FAT16 ,or FAT32 format file system storage.(Floppy or Hard Disk)
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc


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

    mov     ax, es
    mov     PSP, ax

    push    es
    mov     ax, _DATA
    mov     es, ax
    

    ;
    ; Main Flow Start
    ;




    ;
    ; End of Main Flow
    ;


main_exit:


    print_str version
    pop    es

    
    ; Return to DOS
    ret

MAIN ENDP

_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 'DATA'
align 4


PSP         DW      0
version     DB      13, 10, 'scnshot version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: scnshot', 13, 10, 13, 10, 24h

_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

STACK ENDS


    END MAIN


