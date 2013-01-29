;
; above4g.asm -- A tool that can access memory above 4GB
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a simple tool that can access memory above 4GB
; using protected mode with PSE enabled.
;
.586P


INCLUDE ..\include\pm.inc
INCLUDE ..\include\mroutine.inc
INCLUDE ..\include\routine.inc



;------------------------------------------------------------------------------
; Extern sub-routines
;
LIBPM16 SEGMENT USE16

    EXTERN  PM32ExecuteCode:FAR
    EXTERN  CommonPM32Return:FAR
LIBPM16 ENDS


routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
routine ENDS



;------------------------------------------------------------------------------
; 16bit Real Mode Code Segment
;
_TEXT SEGMENT PARA USE16 'CODE'



;##############################################################################
; Real Mode MAIN procedure
;
MAIN PROC FAR PRIVATE


    ; Save for return DOS
    push    ds
    push    ax


    ;--------------------------------------------------------------------------
    ; REAL mode code
    ;--------------------------------------------------------------------------
    ASSUME  SS:_STACK, DS:_DATA, CS:_TEXT, ES:_DATA
    mov     ax, _DATA
    mov     ds, ax


    ;--------------------------------------------------------------------------
    ; Calculate Linear Address of our 32bit Code Entry
    ; Execute Code under protected mode
    ;--------------------------------------------------------------------------
    xor     edi, edi                        ;
    mov     di, SEG Main32Code              ;
    shl     edi, 4                          ;
    add     edi, OFFSET Main32Code          ; EDI = Linear Address of 32bit Routine

    call    PM32ExecuteCode                 ; Execute it under protected mode


main_exit:


    ; Print version
    print_str version


    ; Return to DOS
    ret

MAIN ENDP

_TEXT ENDS



;------------------------------------------------------------------------------
; 32bit Code Segment
;
_TEXT32 SEGMENT PARA USE32 'CODE'



;##############################################################################
; Main32Code -- 32bit Main Routine which intended to run under protected mode
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
Main32Code PROC NEAR PUBLIC


    ;--------------------------------------------------------------------------
    ; Main Code Flow
    ;--------------------------------------------------------------------------


    ; Write Test Data to
    ; Virtual : 3MB (0030_0010h)
    ; Physical: 3MB (0030_0010h)
    mov     esi, 00300010h
    mov     eax, 11223344h
    mov     ds:[esi], eax


    ; Read Data from, then write to 0030_0090h
    ; Virtual : 4MB (  0040_0000h)
    ; Physical: 4GB (1_0000_0000h)
    mov     esi, 00400000h
    mov     eax, ds:[esi]

    mov     edi, 00300090h
    mov     ds:[edi], eax


    ; Write Test Data to
    ; Virtual : 4MB (  0040_0000h)
    ; Physical: 4GB (1_0000_0000h)
    mov     esi, 00400000h
    mov     eax, 55667788h
    mov     ds:[esi], eax


    ; Read Data from, then write to 0030_00A0h
    ; Virtual : 4MB (  0040_0000h)
    ; Physical: 4GB (1_0000_0000h)
    mov     esi, 00400000h
    mov     eax, ds:[esi]

    mov     edi, 003000A0h
    mov     ds:[edi], eax


    ; Return to protected mode facility
    PM32Return


Main32Code ENDP



_TEXT32 ENDS



;------------------------------------------------------------------------------
; 16bit Data Segment
;
_DATA SEGMENT PARA USE16 STACK 'DATA'
align 4


version     DB      13, 10, 'above4g version 0.1 (C) 2008, Merck Hung', 13, 10, 13, 10, 24h


_DATA ENDS



;------------------------------------------------------------------------------
; 16bit Stack Segment
;
_STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

_STACK ENDS


    END MAIN


