;
; e820.inc -- Header file related to e820 routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is the header file of e820
;


FUNC_E820       EQU     0E820h
E820_SIGN       EQU     534d4150h


E820Result STRUCT

    BaseAddrLow     DD      ?
    BaseAddrHigh    DD      ?
    LengthLow       DD      ?
    LengthHigh      DD      ?
    RecType         DD      ?
    Attributes      DD      ?

E820Result ENDS


Sizeof_E820Result   EQU     SIZEOF  E820Result



