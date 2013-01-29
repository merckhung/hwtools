;
; showpci.asm -- Tool was made for scaning PCI device on all bus
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This tool was made for scaning PCI device on all bus
; DO NOT use this tool for products, otherwise at your own risk.
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\pci.inc


;------------------------------------------------------------------------------
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'



;
; extern sub-routines
;
libpci SEGMENT USE16 PUBLIC

    EXTERN scan_pci:FAR
    EXTERN pci_list_menu:FAR
libpci ENDS


;##############################################################################
; main procedure
;
main PROC FAR

    push    ds
    push    ax


    ASSUME  SS:STACK, DS:_DATA, CS:_TEXT, ES:_DATA
    mov     ax, _DATA
    mov     ds, ax
    mov     es, ax
  
  
    ; Do PCI device scanning
    call    scan_pci


	; Display PCI device list menu
	call	pci_list_menu


    ; Print version information
    print_str version


    ; Return to OS
    ret

main ENDP

_TEXT ENDS




;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 'DATA'

version     db      13, 10, 'showpci version 1.4 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h

_DATA ENDS


;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'

    ;
    ; Stack Size = ikb
    ;
    DW 1024 DUP(0)

STACK ENDS

    END main
