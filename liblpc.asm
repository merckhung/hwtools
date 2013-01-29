;
; liblpc.asm -- Flash program library for x86 assembly
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of Flash programming routines for x86 assembly programming.
;
.586P


INCLUDE include\pci.inc
INCLUDE include\mroutine.inc
INCLUDE include\lpc.inc


;
; extern sun-routines
;
libpci SEGMENT USE16 PUBLIC

    EXTERN cal_pci_baseaddr:FAR
    EXTERN pci_read_config_dword:FAR
    EXTERN pci_write_config_dword:FAR
@CurSeg ENDS



;------------------------------------------------------------------------------
; liblpc_data data segment
;
liblpc_data SEGMENT USE16 'DATA'


; LPC PCI base adddress
lpc_pcibase     dd      0


@CurSeg ENDS


;------------------------------------------------------------------------------
; liblpc code segment
;
liblpc SEGMENT USE16 PUBLIC



;----------------------------------- PUBLIC -----------------------------------


;##############################################################################
; lpc_init_base -- Initialize LPC PCI base address
;
; Input :
;   BH  = LPC Bus number
;   BL  = LPC Device number
;   CL  = LPC Function number
;
; Output:
;   EAX = LPC I/O Base Address(16-bit in AX)
;   lpc_pcibase
;   Carry 0: false, 1: true
;
; Modified:
;   BX
;   CX
;
; Mode:
;   REAL mode
;
lpc_init_iobase PROC FAR PUBLIC


    push    bx
    push    cx


    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:liblpc_data, ES:liblpc_data

    mov     ax, liblpc_data
    mov     ds, ax
    mov     es, ax


    ;
    ; Get LPC PCI Base Address
    ;
    call    cal_pci_baseaddr
    mov     dword ptr lpc_pcibase, eax


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds

    pop     cx
    pop     bx

    ret

lpc_init_iobase ENDP



;##############################################################################
; lpc_read_dword -- Read Double Word from LPC registers
;
; Input:
;   BL  =   Register offset
;
; Output:
;   EAX =   Register value
;
; Modified:
;   None
;
; Mode:
;   REAL mode
;
lpc_read_dword PROC FAR PUBLIC


    push    dx


    ;
    ; Save caller's env.
    ;
    push    ds

    ASSUME  DS:liblpc_data

    mov     ax, liblpc_data
    mov     ds, ax
    mov     es, ax


    ; Read data
    mov     eax, dword ptr lpc_pcibase
    call    pci_read_config_dword


    ;
    ; Restore caller's env
    ;
    pop     ds


    pop     dx

    ret

lpc_read_dword ENDP


@CurSeg ENDS

    END


