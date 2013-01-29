;
; pm.inc -- Header file related to protected mode routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


; Protected Mode Stack
PM32_STACK_BASE EQU     00180000h
PM32_STACK_SIZE EQU     4096


; Default place Page Table Directory Entry at LINEAR 2MB
PGDIR_BADDR     EQU     00200000h


; Initialize 768 pages (First 3MB)
PGTBL_NUMS      EQU     768


; Address field offset
PGDIR_OFFSET    EQU     12
PGTBL_OFFSET    EQU     12

PGDIR_OFFSET2   EQU     4
PGTBL_OFFSET2   EQU     4


; Bit 0, Present (P) flag
P_NPRESENT      EQU     000h
P_PRESENT       EQU     001h

; Bit 1, Read/write (R/W) flag
P_RDONLY        EQU     000h
P_RDWR          EQU     002h

; Bit 2, User/supervisor (U/S) flag
P_SUPERVISOR    EQU     000h
P_USER          EQU     004h

; Bit 3, Page-level write-through (PWT) flag
P_WBACK         EQU     000h
P_WTHROUGH      EQU     008h

; Bit 4, Page-level cache disable (PCD) flag
P_CACHE_EN      EQU     000h
P_CACHE_DIS     EQU     010h

; Bit 5, Accessed (A) flag
P_NOACCESS      EQU     000h
P_ACCESSED      EQU     020h

; Bit 6, Dirty (D) flag
P_NODIRTY       EQU     000h
P_DIRTY         EQU     040h

; Bit 7, Page size (PS) flag
P_PSIZE_4KB     EQU     000h
P_PSIZE_4MB     EQU     080h

; Bit 8, Global (G) flag
P_GLO_NORMAL    EQU     000h
P_GLO_NOFLUSH   EQU     100h


; Convention definitions of paging
P_SUP_WT_RW_4K  EQU     (P_PRESENT OR P_RDWR OR P_SUPERVISOR OR P_WTHROUGH OR P_CACHE_DIS OR P_NOACCESS OR P_NODIRTY OR P_PSIZE_4KB OR P_GLO_NORMAL)


P_SUP_WT_RW_4M  EQU     (P_PRESENT OR P_RDWR OR P_SUPERVISOR OR P_WTHROUGH OR P_CACHE_DIS OR P_NOACCESS OR P_NODIRTY OR P_PSIZE_4MB OR P_GLO_NORMAL)



;##############################################################################
; PM32Return -- Return to 32 bit code
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
PM32Return MACRO

    LOCAL RET_32CODE, RET_SEG


    ; Calculate linear address of Instruction
    xor     ebx, ebx
    mov     bx, SEG RET_32CODE
    shl     ebx, 4
    add     ebx, OFFSET RET_32CODE


    ; Calculate Return Address
    xor     eax, eax
    mov     ax, SEG CommonPM32Return
    shl     eax, 4
    add     eax, OFFSET CommonPM32Return


    ; Write to Linear address
    mov     DWORD PTR ds:[ebx], eax


    ; Write Segment Selector
    mov     ax, cs
    mov     WORD PTR ds:[ebx + 4], ax


    ; Far jump to return
    DB      0EAh
RET_32CODE:
    DD      0
RET_SEG:
    DW      0


ENDM



