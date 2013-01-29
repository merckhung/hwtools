;
; dosldr.asm -- X-BIOS Linux DOS loader
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\flat.inc
INCLUDE include\flash.inc
INCLUDE include\mdebug.inc


;------------------------------------------------------------------------------
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'


;
; extern sub-routines
;
libflat SEGMENT USE16 PUBLIC

    EXTERN __enter_flat_mode:FAR
    EXTERN __exit_flat_mode:FAR
    EXTERN copy_data:FAR
@CurSeg ENDS

routine SEGMENT USE16 PUBLIC

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

    mov     ax, _DATA
    mov     es, ax
    mov     gs, ax      ; This will be used in FLAT mode sys_print
    



;--------------------------------------------------------------------------
; Enter FLAT mode
;--------------------------------------------------------------------------
enter_flat_mode
;--------------------------------------------------------------------------
; FLAT mode code start
;--------------------------------------------------------------------------


    scan_rom
    jc      skip_setup
     
    debug_linux_hdrs

skip_setup:
exit_flat_mode
;--------------------------------------------------------------------------

    cmp     scan_flag, 0
    jz      sign_not_found


    ; Print ROM address
    mov     eax, rom_address    
    print_ascii_str foundmsg, 8, 34



IFDEF DEBUG
    ;
    ; print kernel parameters
    ;

    ; Kernel version
    xor     eax, eax
    mov     ax, linux_hdrs.kernel_version
    debug_print_str 'Kernel version  '

    ; Root device
    mov     ax, linux_hdrs.root_dev
    debug_print_str 'Root device     '

    ; Root read/write permission
    mov     ax, linux_hdrs.root_flags
    debug_print_str 'Root Flag       '

    ; Ramdisk start address
    mov     eax, linux_hdrs.ramdisk_image
    debug_print_str 'Ramdisk address '

    ; Ramdisk size address
    mov     eax, linux_hdrs.ramdisk_size
    debug_print_str 'Ramdisk size    '

    ; Ramdisk rom size
    mov     eax, linux_hdrs.ramdisk_max
    debug_print_str 'Ramdisk rom size'

ENDIF


    ; Print booting message
    print_str bootmsg

;--------------------------------------------------------------------------
enter_flat_mode

    load_linux

;--------------------------------------------------------------------------
; Exit FLAT mode
;--------------------------------------------------------------------------
exit_flat_mode
;--------------------------------------------------------------------------
; REAL mode code
;--------------------------------------------------------------------------

sign_not_found:
     

    ; Disable A20
    in      al, 92h
    and     al, not 02h
    out     92h, al


    ; Reenable interrupt
    sti


    print_str failedmsg
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

foundmsg        DB      13, 10, 'Found linux system at address 0x????????h', 13 ,10, 24h
bootmsg         DB      13, 10, 'Booting linux, please wait......', 13, 10, 24h

failedmsg       DB      13, 10, 'Scan Signature failed, cannot boot linux system.', 13, 10, 24h
version         DB      13, 10, 'dosldr version 0.3 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h

rom_address     DD              000000000h
scan_flag       DB              0h


IFDEF DEBUG
linux_hdrs      linux_hdrs_t    1 DUP({?})
sizeof_linux_hdrs       EQU     $ - linux_hdrs
ENDIF

_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

STACK ENDS

    END MAIN


