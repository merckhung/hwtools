;
; e820.asm -- ACPI e820 Reading Tool
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE ..\include\mroutine.inc
INCLUDE ..\include\routine.inc
INCLUDE ..\include\mdebug.inc
INCLUDE ..\include\e820.inc


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

    mov     ax, _DATA
    mov     es, ax
    mov     gs, ax      ; This will be used in FLAT mode sys_print
    

    ;
    ; Main Flow Start
    ;
    print_str E820Title


    xor     ebx, ebx


GetNextRec:


    ; Setup parameter for E820
    mov     eax, FUNC_E820    
    mov     ecx, Sizeof_E820Result
    mov     edi, OFFSET E820Buffer
    mov     edx, E820_SIGN


    ; Issue INT 15h
    int     15h


    ; Check for Carry flag
    jc      E820Done



    ; Print result
    mov     si, OFFSET E820Buffer
    mov     eax, es:[si].E820Result.BaseAddrHigh
    replace_ascii_str   E820RS, 8, 1

    mov     si, OFFSET E820Buffer
    mov     eax, es:[si].E820Result.BaseAddrLow
    replace_ascii_str   E820RS, 8, 9


    mov     si, OFFSET E820Buffer
    mov     eax, es:[si].E820Result.BaseAddrHigh
    add     eax, es:[si].E820Result.LengthHigh
    replace_ascii_str   E820RS, 8, 21

    mov     si, OFFSET E820Buffer
    mov     eax, es:[si].E820Result.BaseAddrLow
    add     eax, es:[si].E820Result.LengthLow
    replace_ascii_str   E820RS, 8, 29


    mov     si, OFFSET E820Buffer
    mov     eax, es:[si].E820Result.LengthHigh
    replace_ascii_str   E820RS, 8, 40

    mov     si, OFFSET E820Buffer
    mov     eax, es:[si].E820Result.LengthLow
    replace_ascii_str   E820RS, 8, 48


    print_str E820RS


    mov     si, OFFSET E820Buffer
    cmp     es:[si].E820Result.RecType, 1
    jne     @f

    print_str E820Type01
    jmp     CheckNextRec

@@:

    cmp     es:[si].E820Result.RecType, 2
    jne     @f

    print_str E820Type02
    jmp     CheckNextRec

@@:

    cmp     es:[si].E820Result.RecType, 3
    jne     @f

    print_str E820Type03
    jmp     CheckNextRec

@@:

    cmp     es:[si].E820Result.RecType, 4
    jne     @f

    print_str E820Type04
    jmp     CheckNextRec

@@:

    cmp     es:[si].E820Result.RecType, 5
    jne     @f

    print_str E820Type05
    jmp     CheckNextRec


@@:


    print_str E820TypeOt


CheckNextRec:


    cmp     ebx, 0
    jne     GetNextRec


E820Done:


    print_str E820Tail
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
version     DB      13, 10, 'e820 version 0.1 (C) 2008 Olux Organization', 13, 10
            DB      'Please report bugs to Merck Hung <merck@olux.org>, thanks', 13, 10, 13, 10
usage       DB      'Usage: e820', 13, 10, 13, 10, 24h


E820Buffer  E820Result  { 0, 0, 0, 0, 0 }

E820Title   DB      '============================ E820 Memory Population ============================', 13, 10
E820Field   DB      ' |-          Address Range          -|  |-    Length   -| |-       Type       -|', 13, 10, 13, 10, 24h

E820RS      DB      ' ????????????????h - ????????????????h  ????????????????h ', 24h

E820Tail    DB      '================================================================================', 13, 10, 24h;


E820Type01  DB      'Memory RAM          ', 13, 10, 24h
E820Type02  DB      'Reserved Range      ', 13, 10, 24h
E820Type03  DB      'ACPI Reclaim Memory ', 13, 10, 24h
E820Type04  DB      'ACPI NVS Memory     ', 13, 10, 24h
E820Type05  DB      'Unusuable Range     ', 13, 10, 24h
E820TypeOt  DB      'Undefined Range     ', 13, 10, 24h


_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

STACK ENDS


    END MAIN


