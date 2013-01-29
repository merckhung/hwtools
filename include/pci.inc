;
; pci.inc -- Header file related to PCI interface
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


;
; PCI device information structure
;
pci_info_t STRUCT

    BaseAddr    DD      00000000h
    BusNo       DB      0ffh
    DeviceNo    DB      0ffh
    FunctionNo  DB      0ffh
    VendorID    DW      0ffffh
    DeviceID    DW      0ffffh
    BaseClass   DB      0ffh
    SubClass    DB      0ffh
pci_info_t ENDS
sizeof_pci_info_t   EQU     SIZEOF pci_info_t


;
; PCI name database
;
sizeof_pci_nametext EQU     38
pci_namedb_t struct

    NameText    DB  sizeof_pci_nametext DUP( 20h )
pci_namedb_t ENDS


;
; Maximum PCI definition
;
MAX_BUSNO       EQU     0FFh
MAX_DEVNO       EQU     1Fh
MAX_FUNNO       EQU     07h


;
; PCI configuration register
;
pci_ioaddr      EQU     0CF8h
pci_iodata      EQU     0CFCh
pci_space_sz    EQU     256


;##############################################################################
; place_sctext -- Place Subclass Text
;
; Input :
;   STRP
;   OFF
;   LEN
;   DI      = PCI struct index
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;   CX
;   DI
;   SI
;
place_sctext MACRO STRP, OFF, LEN

    push    ax
    push    bx
    push    cx
    push    di
    push    si

    mov     ah, p_pci_info[di].SubClass
    mov     al, p_pci_info[di].BaseClass
    mov     bl, 1                           ; Get SubClass Text

    call    get_classtext

    mov     si, bx
    mov     di, offset STRP
    add     di, OFF

    mov     bx, LEN
    mov     cx, LEN

    call    paste_string

    pop     si
    pop     di
    pop     cx
    pop     bx
    pop     ax

ENDM


