;
; gloader.asm -- X-BIOS Linux floppy bootloader
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a bootloader for backup BIOS project
;
.586P


INCLUDE ..\include\mroutine.inc
INCLUDE ..\include\routine.inc
INCLUDE ..\include\flat.inc
INCLUDE ..\include\flash.inc
INCLUDE ..\include\mdebug.inc


;------------------------------------------------------------------------------
; 16bit Code segment
;
_TEXT16 SEGMENT PARA USE16 'CODE'


;
; extern sub-routines
;
libflat SEGMENT USE16 PUBLIC

    EXTERN __enter_flat_mode:FAR
    EXTERN __exit_flat_mode:FAR
    EXTERN copy_data:FAR
@CurSeg ENDS


;##############################################################################
; MAIN procedure
;
MAIN PROC NEAR PRIVATE


BOOT_ENTRY:

    jmp     AFTER_BPB
    nop

    ;
    ; Boot SPEC.
    ;
    DB   0
    DD   0
    DD   0
    DW   0
    DB   0
    DB   0
    DW   0

AFTER_BPB:


    ; DS = GS = CS
    mov     ax, 07c0h
    mov     ds, ax
    mov     gs, ax


;--------------------------------------------------------------------------
; Enter FLAT mode
;--------------------------------------------------------------------------
enter_flat_mode
;--------------------------------------------------------------------------
; FLAT mode code start
;--------------------------------------------------------------------------


    scan_rom
    jc      scan_failed

    load_linux
    jmp     boot_failed

scan_failed:

    mov     ebx, 0b8000h
    mov     al, 'S'
    mov     [ebx], al

boot_failed:
    
    mov     ebx, 0b8000h
    mov     al, 'L'
    mov     [ebx], al


    mov     al, 0f0h
    mov     [ebx+1], al

    jmp     $


MAIN endp


;
; Data area
;
rom_address     DD      000000000h
scan_flag       DB      0h


_TEXT16 ENDS


;##############################################################################
; Stack
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4
STACK_SIZE      EQU     30
STACK_BASE      DB  STACK_SIZE DUP(0)
                DW  0aa55h

STACK ENDS


    END MAIN


