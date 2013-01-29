;
; pnp.inc -- Header file related to PNP routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is the header file of PnP BIOS
;


PNP_ENTRY_BOUND     EQU     010h
PNP_ENTRY_SIGNATURE EQU     'PnP$'


;
; PnP Installation Check Structure
;
pnpInstChkStruc STRUCT

    signature       DB      4 DUP(0)
    ver             DB      10h
    len             DB      21h
    ctlfield        DW      ?
    chksm           DB      ?
    enfa            DD      ?
    rm16coff        DW      ?
    rm16cseg        DW      ?
    pm16coff        DW      ?
    pm16csegba      DD      ?
    oemdevidf       DD      ?
    rm16dseg        DW      ?
    pm16dsegba      DD      ?

pnpInstChkStruc ENDS


