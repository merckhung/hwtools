;
; libfat.asm -- FAT12, FAT16, and FAT32 file system routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of FAT storage routines for x86 assembly programming.
;
.586P


INCLUDE include\fat.inc


;------------------------------------------------------------------------------
; libfat code segment
;
libfat SEGMENT USE16 PUBLIC


;----------------------------------- PUBLIC -----------------------------------


;##############################################################################
; FatLibInit -- Initialize FAT library
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatLibInit PROC FAR PUBLIC


	ret

FatLibInit ENDP


;##############################################################################
; FatUseFdd -- Specify Floppy Disk Drive(BIOS A:) as Storage
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatUseFdd PROC FAR PUBLIC


	ret

FatUseFdd ENDP


;##############################################################################
; FatUseHdd -- Specify Hard Disk Drive(BIOS C:) as Storage
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatUseHdd PROC FAR PUBLIC


	ret

FatUseHdd ENDP


;##############################################################################
; FatFileOpen -- Search filename user specified in path and then open it for
;		 later operatins
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatFileOpen PROC FAR PUBLIC


	ret

FatFileOpen ENDP


;##############################################################################
; FatFileClose -- Close current session of opened file
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatFileClose PROC FAR PUBLIC


	ret

FatFileClose ENDP


;##############################################################################
; FatFileOpen -- Read one byte from opened file session
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatFileRead PROC FAR PUBLIC


	ret

FatFileRead ENDP


;##############################################################################
; FatFileWrite -- Write one byte to opened file session
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatFileWrite PROC FAR PUBLIC


	ret

FatFileWrite ENDP




;----------------------------------- PRIVATE -----------------------------------


;##############################################################################
; FatLookupSectorNumByName -- Lookup sector number by path and filename
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
FatLookupSectorNumByName PROC NEAR PUBLIC


	ret

FatLookupSectorNumByName ENDP


libfat ENDS

    END


