;
; pnpbios.asm -- PnP BIOS Detect tool
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE ..\include\mroutine.inc
INCLUDE ..\include\routine.inc
INCLUDE ..\include\mdebug.inc
INCLUDE ..\include\pnp.inc


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


    ; Lookup $PnP Signature
    mov     ax, 0f000h
    mov     es, ax

    
    xor     ebx, ebx
scan:

    
    ; Compare string
    mov     eax, es:[bx]
    cmp     eax, PNP_ENTRY_SIGNATURE
    jz      found

    add     bx, PNP_ENTRY_BOUND
    cmp     bx, 0fff0h
    jnz     scan

    
    ; No PnP support
    print_str   nopnp
    jmp     main_exit


found:

    
    ; Found PnP BIOS support
    xor     eax, eax

    mov     ax, es
    shl     eax, 4

    and     ebx, 0ffffh
    or      eax, ebx
    replace_ascii_str   foundpnp, 8, 28


    mov     dword ptr eax, es:[bx]
    replace_ascii_str   fp0, 8, 15

    mov     al, es:[bx].pnpInstChkStruc.ver
    replace_ascii_str   fp1, 2, 15

    mov     al, es:[bx].pnpInstChkStruc.len
    replace_ascii_str   fp2, 2, 15

    mov     ax, es:[bx].pnpInstChkStruc.ctlfield
    replace_ascii_str   fp3, 4, 15

    mov     al, es:[bx].pnpInstChkStruc.chksm
    replace_ascii_str   fp4, 2, 15

    mov     eax, es:[bx].pnpInstChkStruc.enfa
    replace_ascii_str   fp5, 8, 15

    mov     ax, es:[bx].pnpInstChkStruc.rm16coff
    replace_ascii_str   fp6, 4, 15

    mov     ax, es:[bx].pnpInstChkStruc.rm16cseg
    replace_ascii_str   fp7, 4, 15

    mov     ax, es:[bx].pnpInstChkStruc.pm16coff
    replace_ascii_str   fp8, 4, 15

    mov     eax, es:[bx].pnpInstChkStruc.pm16csegba
    replace_ascii_str   fp9, 8, 15

    mov     eax, es:[bx].pnpInstChkStruc.oemdevidf
    replace_ascii_str   fp10, 8, 15

    mov     ax, es:[bx].pnpInstChkStruc.rm16dseg
    replace_ascii_str   fp11, 4, 15

    mov     eax, es:[bx].pnpInstChkStruc.pm16dsegba
    replace_ascii_str   fp12, 8, 15


    print_str   foundpnp



    ; Call Function 60h
    push    word ptr 0

    push    SEG verbuf
    push    OFFSET verbuf

    push    word ptr 60h


    push    ds

    mov     ax, es:[bx].pnpInstChkStruc.rm16dseg
    mov     ds, ax

    mov     ax, es:[bx].pnpInstChkStruc.rm16cseg
    mov     word ptr JMP_SEG, ax

    mov     ax, es:[bx].pnpInstChkStruc.rm16coff
    mov     word ptr JMP_OFF, ax

    
    push    cs


    ; jmpi instruction
    DB      66h, 0eah

JMP_OFF:
    DW      0000h

JMP_SEG:
    DW      0000h


    pop     ds


    add     sp, 8
    cmp     ax, 00h
    jz      pnpcallok

    
    debug_print_onlystr 'Call PnP Entry Failed'
    jmp     main_exit


pnpcallok:
    

    debug_print_onlystr 'Call PnP Entry Success'
    and     ebx, 0ffffh
    mov     eax, ebx
    debug_print_str 'Function 60h return version'


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
version     DB      'pnpbios version 0.1 (C) 2007, Merck Hung', 13, 10, 24h
usage       DB      'Usage: pnpbios', 13, 10, 13, 10, 24h


nopnp       DB      'There is no PnP Signature', 13, 10, 24h
foundpnp    DB      'Found PnP BIOS Signature at ????????h', 13, 10
            DB      '====================================================================', 13, 10
fp0         DB      'Signature:     ????????h', 13, 10
fp1         DB      'Version:       ??h', 13, 10
fp2         DB      'Length:        ??h', 13, 10
fp3         DB      'Control Field: ????h', 13, 10
fp4         DB      'Checksum:      ??h', 13, 10
            DB      'Event notification flag address:', 13, 10
fp5         DB      '               ????????h', 13, 10
            DB      'Real Mode 16-bit offset to entry point:', 13, 10
fp6         DB      '               ????h', 13, 10
            DB      'Real Mode 16-bit code segment address:', 13, 10
fp7         DB      '               ????h', 13, 10
            DB      '16-Bit Protected Mode offset to entry point:', 13, 10
fp8         DB      '               ????h', 13, 10
            DB      '16-Bit Protected Mode code segment base address:', 13, 10
fp9         DB      '               ????????h', 13, 10
            DB      'OEM Device Identifier:', 13, 10
fp10        DB      '               ????????h', 13, 10
            DB      'Real Mode 16-bit data segment address', 13, 10
fp11        DB      '               ????h', 13, 10
            DB      '16-Bit Protected Mode data segment base address:', 13, 10
fp12        DB      '               ????????h', 13, 10, 24h



verbuf      DB      10 DUP( 0 )



_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

STACK ENDS


    END MAIN


