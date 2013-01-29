;
; amdvm.asm -- AMD Processor SVM Enable
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
    


    ;
    ; Identify Virtual Machine Feature
    ;

    ; Check SVM feature present or not
    debug_print_onlystr 'CPUID: 0x80000001'

    mov     eax, 080000001h
    cpuid

    mov     eax, ecx
    debug_print_str 'ECX'

    and     ecx, 000000004h                 ; Check SVME, bit12
    jz      no_svm_support



    ; Print 0x8000_000A SVM Information
    debug_print_onlystr 'CPUID: 0x8000000A'

    mov     eax, 08000000ah
    cpuid

    debug_print_str 'EAX'

    mov     eax, ebx

    debug_print_str 'EBX'

    mov     eax, ecx

    debug_print_str 'ECX'

    mov     eax, edx

    debug_print_str 'EDX'


    ; Read MSR
    debug_read_msr 0c0000080h


IF 0
    ; Enable SVME
    or      eax, 000001000h
    debug_write_msr 0c0000080h


    ; Check result
    debug_read_msr 0c0000080h
ENDIF
    

    jmp     main_exit


no_svm_support:

    print_str   no_svm_msg

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
version     DB      13, 10, 'amdsvm version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: amdsvm', 13, 10, 13, 10, 24h


no_svm_msg  DB      13, 10, 'Your processor does not support AMD Secure Virtual Machine feature.', 13, 10, 13, 10, 24h


_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     256 DUP(0)

STACK ENDS






    END MAIN


