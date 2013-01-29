;
; comt.asm -- COM Port loopback test tool
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; COM Port loopback test Tool
;
.586P


INCLUDE ..\include\mroutine.inc
INCLUDE ..\include\routine.inc
INCLUDE ..\include\mdebug.inc
INCLUDE ..\include\flat.inc


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


COMA_BASE   EQU     03f8h
COMB_BASE   EQU     02f8h


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
    mov     gs, ax      ; This will be used in FLAT mode sys_print
    

    ;
    ; Main Flow Start
    ;
    mov     dx, COMA_BASE

    ; Turn off interrupt
    inc     dx
    xor     al, al
    out     dx, al

    ; DLAB ON
    add     dx, 2       ; BASE + 3
    mov     al, 80h
    out     dx, al

    ; Baud rate = 19200
    ; Divisor Low Byte
    sub     dx, 3       ; BASE + 0
    mov     al, 06h
    out     dx, al

    ; Divisor High Byte
    inc     dx          ; BASE + 1
    xor     al, al
    out     dx, al

    ; DLAB = OFF, 8 Bits, No Parity, 1 Stop Bit
    add     dx, 2       ; BASE + 3
    mov     al, 03h
    out     dx, al

    ; FIFO control
    dec     dx          ; BASE + 2
    mov     al, 0c7h
    out     dx, al

    ; Turn on DTR, RTS, and OUT2
    add     dx, 2       ; BASE + 4
    mov     al, 0bh
    out     dx, al


    inc     dx          ; BASE + 5

recv:
    in      al, dx      ; BASE + 5
   
    sub     dx, 5       ; BASE + 0
    test    al, 01h
    jz      no_input

    ; Read input
    in      al, dx      ; BASE + 0

    and     eax, 0ffh
    debug_print_str 'Get input'
no_input:

    ; Output ASCII 'A'
    mov     al, 'B'
    out     dx, al

    debug_print_onlystr 'Press enter to Next Loop'
    add     dx, 5       ; BASE + 5

    wait_input
    cmp     ax, KENTER
    jnz     main_exit

    jmp     recv


    ;
    ; End of Main Flow
    ;


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
version     DB      13, 10, 'comt version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: comt', 13, 10, 13, 10, 24h
fd          DB      0
smaddr      DD      0

_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

STACK ENDS


    END MAIN


