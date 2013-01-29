;
; int13tsr.asm -- INT 13h TSR to Hook Original One
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a TSR program to Hook INT 13h Requirements
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc
INCLUDE include\hdd.inc
INCLUDE include\tsr.inc
INCLUDE include\com.inc



;------------------------------------------------------------------------------
; TSR Segment
;
_TSRTEXT SEGMENT PARA USE16 'RESIDENT'



NewCount    DB      0
OrgCount    DB      0
CurrColor   DB      1



;##############################################################################
; Int13hHandler -- INT 13h Handler (Hook)
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
align 4
Int13hHandler PROC NEAR PUBLIC


    ; Save All Registers
    pushad
    push    ds
    push    es
    push    fs
    push    gs


    ; Debug Registers
    call    ComDumpRegisters


    ; Restore All Registers
    pop     gs
    pop     fs
    pop     es
    pop     ds
    popad



    ; Make Real Handler Return to us
    pushf
    push    SEG INT13hRet
    push    OFFSET INT13hRet


    ; Far Jump to Original INT 13h Handler
    DB      0EAh

OrigInt13hOff::
    DW      0000h

OrigInt13hSeg::
    DW      0000h


    ; Real Handler return to here
INT13hRet:


    ; Increase Counter
    inc     cs:NewCount


    ; Return to user program
    iret


Int13hHandler ENDP



;##############################################################################
; Int10hHandler -- INT 10h Handler (Hook)
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
align 4
Int10hHandler PROC NEAR PUBLIC


    ; Make Real Handler Return to us
    pushf
    push    SEG INT10hRet
    push    OFFSET INT10hRet


    ; Far Jump to Original INT 13h Handler
    DB      0EAh

OrigInt10hOff::
    DW      0000h

OrigInt10hSeg::
    DW      0000h


    ; Real Handler return to here
INT10hRet:


    ; Write VGA
    push    ds
    push    ax
    push    bx

    mov     ax, 0B800h
    mov     ds, ax
    mov     bx, (70 * 2)


    ; Write WORD
    mov     BYTE PTR ds:[bx+00], 'D'
    mov     BYTE PTR ds:[bx+02], 'I'
    mov     BYTE PTR ds:[bx+04], 'S'
    mov     BYTE PTR ds:[bx+06], 'K'
    mov     BYTE PTR ds:[bx+08], 'H'
    mov     BYTE PTR ds:[bx+10], 'O'
    mov     BYTE PTR ds:[bx+12], 'O'
    mov     BYTE PTR ds:[bx+14], 'K'


    ; Change Color
    mov     al, cs:NewCount
    cmp     al, cs:OrgCount
    je      DontChangeColor


    ; Do Change Color
    inc     BYTE PTR cs:CurrColor
    mov     cs:OrgCount, al


DontChangeColor:


    ; Read Color
    mov     al, cs:CurrColor
    shl     al, 4
    and     al, 0F0h
    or      al, 00Fh


    ; Write COLOR
    mov     BYTE PTR ds:[bx+01], al
    mov     BYTE PTR ds:[bx+03], al
    mov     BYTE PTR ds:[bx+05], al
    mov     BYTE PTR ds:[bx+07], al
    mov     BYTE PTR ds:[bx+09], al
    mov     BYTE PTR ds:[bx+11], al
    mov     BYTE PTR ds:[bx+13], al
    mov     BYTE PTR ds:[bx+15], al


    pop     bx
    pop     ax
    pop     ds


    ; Return to user program
    iret


Int10hHandler ENDP



_TSRTEXT ENDS



;
; Extern Sub-Routines for TSR
;
LIBHDD SEGMENT USE16 PUBLIC

    EXTERN HddExtRead:FAR
    EXTERN HddExtWrite:FAR
    EXTERN HddRead:FAR
    EXTERN HddWrite:FAR
@CurSeg ENDS


LIBCOM SEGMENT PARA USE16 PUBLIC

    EXTERN ComInitialize:FAR
    EXTERN ComDumpRegisters:FAR
@CurSeg ENDS


routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
@CurSeg ENDS



_ENDTSRTEXT SEGMENT PARA USE16
_ENDTSRTEXT ENDS



;
; Extern Sub-Routines for Main Program
;
LIBTSR SEGMENT PARA USE16 PUBLIC

    EXTERN TsrRegister:FAR
    EXTERN TsrInstallHandler:FAR
@CurSeg ENDS



;------------------------------------------------------------------------------
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'



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
    mov     es, ax
    

    ;
    ; Main Flow Start
    ;


    ; Get PSP Value
    mov     ah, 62h
    int     21h


    ; Get the size of resident portion
    mov     dx, _ENDTSRTEXT
    sub     dx, bx


    ; Display PSP Adress
    mov     ax, bx
    replace_ascii_str PSPMSG, 4, 5


    ; Display TSR Segment Address
    mov     ax, _ENDTSRTEXT
    replace_ascii_str PSPMSG, 4, 21


    ; Display TSR Size
    mov     ax, dx
    replace_ascii_str PSPMSG, 4, 38


    ; Display Information
    print_str PSPMSG


    ; Initialize COM PORT
    mov     dx, COM_PORT_A_BASE
    mov     bl, BAUD_115200
    call    ComInitialize


    ; Install INT 13h Hook
    TsrInstallHookHandlerM 13h, Int13hHandler, OrigInt13hSeg, OrigInt13hOff


    ; Install INT 10h Hook
    TsrInstallHookHandlerM 10h, Int10hHandler, OrigInt10hSeg, OrigInt10hOff


    ; Register TSR
    mov     dx, _ENDTSRTEXT
    call    TsrRegister


    ;
    ; End of Main Flow
    ;


main_exit:


    print_str VERSION
    

    ; Return to DOS
    ret


MAIN ENDP



_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 STACK 'DATA'
align 4


VERSION     DB      13, 10, 'int13tsr version 0.1 (C) 2008, Merck Hung', 13, 10, 13, 10, 24h
USAGE       DB      'Usage: int13tsr', 13, 10, 13, 10, 24h
PSPMSG      DB      'PSP: ????h, TSR Seg: ????h, TSR Size: ????h', 13, 10, 13, 10, 24h


_DATA ENDS






;------------------------------------------------------------------------------
; Stack segment
;
_STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

_STACK ENDS


    END MAIN


