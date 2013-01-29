;
; fat.inc -- Header file related to FAT routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


;
; PCI device information structure
;
sizeof_pci_info_t   equ     13
pci_info_t STRUCT

    BaseAddr    dd      00000000h
    BusNo       db      0ffh
    DeviceNo    db      0ffh
    FunctionNo  db      0ffh
    VendorID    dw      0ffffh
    DeviceID    dw      0ffffh
    BaseClass   db      0ffh
    SubClass    db      0ffh
pci_info_t ENDS


;
; PCI name database
;
sizeof_pci_nametext equ     38
pci_namedb_t struct

    NameText    db  sizeof_pci_nametext DUP( 20h )
pci_namedb_t ENDS


;
; Maximum PCI definition
;
max_bus     equ     255
max_device  equ     32
max_func    equ     8


;
; PCI configuration register
;
pci_ioaddr  equ     0cf8h
pci_iodata  equ     0cfch


