;
; amdnxe.asm -- AMD Processor NXE bit enable
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

    mov     ax, es
    mov     PSP, ax

    mov     ax, _DATA
    mov     es, ax
    mov     gs, ax      ; This will be used in FLAT mode sys_print




IF 0
    debug_read_msr 0c001001fh



    mov     eax, 8100c360h
    mov     dx, 0cf8h
    out     dx, eax

    mov     dx, 0cfch
    in      eax, dx
    debug_print_str 'Read PCI 8100c360h'

    and     eax, 0dff0f000h
    or      eax, 0000c0000h
    mov     dx, 0cfch
    out     dx, eax
    
    mov     dx, 0cfch
    in      eax, dx
    debug_print_str 'Read PCI 8100c360h'






    mov     ecx, 0c0010050h
    rdmsr
    or      edx, 0c0ffffffh
    mov     eax, 0987h
    wrmsr
    debug_read_msr 0c0010050h
    

    mov     ecx, 0c0010054h
    rdmsr
    or      eax, 000008002h
    wrmsr
    debug_read_msr 0c0010054h
ENDIF




    xor     dx, dx
    mov     ecx, 0ffffh

loop2:

    push    dx

    xor     eax, eax
    mov     ax, dx
    debug_print_str 'Access IO port'

    pop     dx


    in      al, dx


    inc     dx
    dec     ecx
    jnz     loop2


    jmp     main_exit


no_nx_support:

    print_str no_nx_msg

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
version     DB      13, 10, 'amdnxe version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: amdnxe', 13, 10, 13, 10, 24h

no_nx_msg   DB      13, 10, 'Your processor does not support AMD Non-execute page protection feature.', 13, 10, 13, 10, 24h

_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     256 DUP(0)

STACK ENDS






    END MAIN


