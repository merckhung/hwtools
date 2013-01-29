;
; hddddump.asm -- Hard Disk Dumper
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc
INCLUDE include\hdd.inc


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


libdbg SEGMENT USE16 PUBLIC

    EXTERN DbgDumpRegisters:FAR
    EXTERN DbgDumpMemory:FAR
@CurSeg ENDS


libhdd SEGMENT USE16 PUBLIC

    EXTERN HddExtRead:FAR
    EXTERN HddExtWrite:FAR
    EXTERN HddExtReadFlat:FAR
    EXTERN HddExtWriteFlat:FAR
    EXTERN HddCHSToLBA:FAR
    EXTERN HddInitVariables:FAR
    EXTERN HddCheckCHSRange:FAR
    EXTERN HddLBAToCHS:FAR
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
    

    ;
    ; Main Flow Start
    ;
    mov     edi, 00400000h
    mov     ah, HDD_FIRST
    mov     al, 2
    mov     ebx, 0
    mov     ecx, 0
    call    HddExtWriteFlat


    mov     edi, 00800000h
    mov     ah, HDD_FIRST
    mov     al, 2
    mov     ebx, 0
    mov     ecx, 0
    call    HddExtReadFlat


    
    ; Read MBR
    ;HddExtReadM HDD_FIRST, 0, 0, 1, SECTOR_BUF
    ;HddExtWriteM HDD_FIRST, 0, 0, 1, SECTOR_BUF
    ;HddReadM HDD_FIRST, 0, 1, SECTOR_BUF
    ;HddWriteM HDD_FIRST, 0, 1, SECTOR_BUF


    ; Initialize Variables
    mov     dl, HDD_FIRST
    call    HddInitVariables
    

    ; Save Maximun Limit
    mov     cs:M_CYLINDER, ax
    mov     cs:M_HEAD, ch
    mov     cs:M_SECTOR, bl


    ; Print Maximun Information
    mov     ax, cs:M_CYLINDER
    replace_ascii_str   MAXMSG, 4, 18

    mov     al, cs:M_HEAD
    replace_ascii_str   MAXMSG, 2, 31

    mov     al, cs:M_SECTOR
    replace_ascii_str   MAXMSG, 2, 44

    print_str MAXMSG



    ;
    ; Verify CHS to LBA Translating
    ;
TestNextSector:


    ; Check if CHS in the range
    HddCheckCHSRangeM cs:T_CYLINDER, cs:T_HEAD, cs:T_SECTOR
    jc      OutOfRange


    ; Use CHS Native Read
    HddReadNativeM HDD_FIRST, cs:T_CYLINDER, cs:T_HEAD, cs:T_SECTOR, SECTOR_BUF1, 1


    ; Translate CHS to LBA and use Exteneded Read
    HddCHSToLBAM HDD_FIRST, cs:T_CYLINDER, cs:T_HEAD, cs:T_SECTOR


    ; Print LBA Result
    push    eax
    push    ebx
    push    ecx

    push    ecx
    mov     eax, ebx
    replace_ascii_str   LBAMSG, 8, 25
    pop     ecx

    mov     eax, ecx
    replace_ascii_str   LBAMSG, 8, 16

    pushad
    print_str LBAMSG
    popad

    pop     ecx
    pop     ebx
    pop     eax


    ; Translate LBA back to CHS
    pushad
    call    HddLBAToCHS

    push    cx
    mov     al, dh
    replace_ascii_str   CHSMSG, 2, 27
    pop     cx


    push    cx
    mov     al, cl
    and     al, HDD_MAX_SECTOR
    replace_ascii_str   CHSMSG, 2, 34
    pop     cx


    mov     al, ch
    mov     ah, cl
    shl     ah, 6
    and     ax, HDD_MAX_CYLINDER
    replace_ascii_str   CHSMSG, 4, 18

    print_str CHSMSG

    popad


    ; Use extended read
    mov     ax, SEG SECTOR_BUF
    mov     es, ax
    mov     di, OFFSET SECTOR_BUF
    mov     ah, HDD_FIRST
    mov     al, 1
    call    HddExtRead
    

    ; Compare Buffers
    CompareBuffers SECTOR_BUF, SECTOR_BUF1, HDD_SZ_SECTOR
    jc      NotIdent


    ; It's identical
    print_str IDENTICAL


    ; Move to Next CHS
    ; Secotr + 1
    inc     cs:T_SECTOR


    ; Check Sector
    mov     al, cs:T_SECTOR
    cmp     al, cs:M_SECTOR
    jbe     TestNextSector


    ; Head + 1
    mov     cs:T_SECTOR, 1
    inc     cs:T_HEAD


    ; Check Head
    mov     al, cs:T_HEAD
    cmp     al, cs:M_HEAD
    jbe     TestNextSector


    ; Cylinder + 1
    mov     cs:T_HEAD, 0
    inc     cs:T_CYLINDER


    ; Check Cylinder
    mov     ax, cs:T_CYLINDER
    cmp     ax, cs:M_CYLINDER
    ja      main_exit
    jmp     TestNextSector


NotIdent:


    ; Dump Memory
    DbgDumpMemoryM SECTOR_BUF, HDD_SZ_SECTOR
    DbgDumpMemoryM SECTOR_BUF1, HDD_SZ_SECTOR


    ; It's identical
    print_str NOTIDENTICAL
    jmp     main_exit


OutOfRange:


    print_str CHSOUTRANGE



    ;
    ; End of Main Flow
    ;


main_exit:

    print_str version
    
    ; Return to DOS
    ret

MAIN ENDP



T_CYLINDER  DW      2
T_HEAD      DB      2
T_SECTOR    DB      1


M_CYLINDER  DW      0000h
M_HEAD      DB      00h
M_SECTOR    DB      01h



_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 STACK 'DATA'
align 4


PSP         DW      0
version     DB      13, 10, 'hddddump version 0.1 (C) 2008, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: hddddump', 13, 10, 13, 10, 24h


SECTOR_BUF  DB      HDD_SZ_SECTOR DUP( 0 )
SECTOR_BUF1 DB      HDD_SZ_SECTOR DUP( 0 )


IDENTICAL       DB  'Buffers are identical', 13, 10, 13, 10, 24h
NOTIDENTICAL    DB  'Buffers are not identical', 13, 10, 13, 10, 24h
CHSOUTRANGE     DB  'CHS values are out of range', 13, 10, 13, 10, 24h


MAXMSG      DB      'Maximum Cylinder: ????h, Head: ??h, Sector: ??h', 13, 10, 24h
LBAMSG      DB      'Translated LBA: ????????-????????h', 13, 10, 24h
CHSMSG      DB      'Translated CHS: C=????h, H=??h, S=??h', 13, 10, 24h


_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
_STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     1024 DUP(0)

_STACK ENDS


    END MAIN


