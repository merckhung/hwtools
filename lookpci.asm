;
; lookpci.asm -- NMI TSR to handle Memory ECC error
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a TSR program to handle memory ECC error
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc
INCLUDE include\pci.inc


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


libpci SEGMENT USE16 PUBLIC

    EXTERN cal_pci_baseaddr:FAR
@CurSeg ENDS


libdbg SEGMENT USE16 PUBLIC

    EXTERN DbgDumpMemory:FAR
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
    ASSUME  SS:_STACK, DS:_DATA, CS:_TEXT, ES:_DATA
    mov     ax, _DATA
    mov     ds, ax

    mov     ax, es
    mov     PSP, ax

    mov     ax, _DATA
    mov     es, ax
    mov     gs, ax      ; This will be used in FLAT mode sys_print



    ; Check arguments
    call    parse_args
    jc      args_error

    

    ;
    ; Main Flow Start
    ;



    ; Calculate PCI Base Address
    mov     bh, BUSNO
    mov     bl, DEVNO
    mov     cl, FUNNO
    call    cal_pci_baseaddr


    ; Save PCI Base Address
    mov     PCIADDR, eax

    
    ; Display Message
    mov     al, BUSNO
    replace_ascii_str   PCIADDRMSG, 2, 34

    mov     al, DEVNO
    replace_ascii_str   PCIADDRMSG, 2, 44

    mov     al, FUNNO
    replace_ascii_str   PCIADDRMSG, 2, 54

    mov     eax, PCIADDR
    replace_ascii_str   PCIADDRMSG, 8, 18

    print_str PCIADDRMSG


    ; Read PCI 256 Bytes
    mov     cx, pci_space_sz
    xor     ebx, ebx


    ; Prepare Data Buffer
    push    SEG PCIDATABUF
    pop     es
    mov     di, OFFSET PCIDATABUF


ReadNextDWORD:


    ; Prepare PCI Address
    mov     eax, PCIADDR
    add     eax, ebx
    mov     dx, pci_ioaddr
    out     dx, eax


    ; Read Data and Write to Buffer
    mov     dx, pci_iodata
    in      eax, dx
    mov     es:[di], eax


    ; Move to next DWORD
    add     ebx, 4
    add     di, 4
    sub     cx, 4
    jnz     ReadNextDWORD


    ; Dump Memory
    DbgDumpMemoryM PCIDATABUF, pci_space_sz



    ;
    ; End of Main Flow
    ;
    jmp     main_exit


args_error:


    print_str argerrmsg
    print_str usage
    jmp     main_exit


main_exit:


    print_str version

    
    ; Return to DOS
    ret


MAIN ENDP



;##############################################################################
; parse_args -- Parse Arguments
;
; Input :
;   PSP
;
; Output:
;   slave_addr
;   reg_offset
;
; Modified:
;   ax
;   bx
;   es
;
parse_args PROC NEAR PRIVATE


    push    ax
    push    bx

    push    es
    mov     ax, PSP
    mov     es, ax

    mov     bx, 80h

    mov     al, es:[bx]

    cmp     al, 0
    jz      parse_args_error


    ; check prefix of first argument
    add     bx, 2
    mov     ax, es:[bx]
    cmp     ax, 'x0'
    jnz     parse_args_error


    ; get first argument
    add     bx, 2
    mov     ax, es:[bx]


    ; Convert ASCII to binary
    call    byte_ascii_to_bin
    jc      parse_args_error
    mov     BUSNO, al


    ; check prefix of second argument
    add     bx, 3
    mov     ax, es:[bx]
    cmp     ax, 'x0'
    jnz     parse_args_error


    ; get second argument
    add     bx, 2
    mov     ax, es:[bx]


    ; Convert ASCII to binary
    call    byte_ascii_to_bin
    jc      parse_args_error
    mov     DEVNO, al

    
    ; Check DEVNO
    cmp     al, MAX_DEVNO
    jae     parse_args_error


    ; check prefix of 3th argument
    add     bx, 3
    mov     ax, es:[bx]
    cmp     ax, 'x0'
    jnz     parse_args_error


    ; get 3th argument
    add     bx, 2
    mov     ax, es:[bx]


    ; Convert ASCII to binary
    call    byte_ascii_to_bin
    jc      parse_args_error
    mov     FUNNO, al


    ; CHeck FUNNO
    cmp     al, MAX_FUNNO
    jae     parse_args_error


    clc
    jmp     parse_args_exit


parse_args_error:

    stc

parse_args_exit:


    pop     es

    pop     bx
    pop     ax


    ret

parse_args ENDP



_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 STACK 'DATA'
align 4


PSP         DW      0


PCIADDR     DD      0
BUSNO       DB      0
DEVNO       DB      0
FUNNO       DB      0


version     DB      13, 10, 'lookpci version 0.1 (C) 2008, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: lookpci BUS DEV FUN', 13, 10
            DB      '   BUS:    PCI Bus Number     (0x00 - 0xFF)', 13, 10
            DB      '   DEV:    PCI Device Number  (0x00 - 0x1F)', 13, 10
            DB      '   FUN:    PCI Function Number(0x00 - 0x07)', 13, 10, 13, 10, 24h


argerrmsg   DB      13, 10, 'Invalid arguments format or missing', 13, 10, 13, 10, 24h

PCIADDRMSG  DB      'Look PCI Address: ????????h, Bus: ??h, Dev: ??h, Fun: ??h', 13, 10, 24h
PCIDATABUF  DB      pci_space_sz DUP( 0 )


_DATA ENDS



;------------------------------------------------------------------------------
; Stack segment
;
_STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

_STACK ENDS


    END MAIN


