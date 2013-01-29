;
; int15tsr.asm -- INT 15h TSR to Hook Original One
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a TSR program to Hook INT 15h Requirements
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc
INCLUDE include\tsr.inc



BLDR_START      EQU     98000h
BLDR_LENGTH     EQU     (32 * 1024)



HookInt15h MACRO


    LOCAL INT15hRet


    ; Make Real Handler Return to us 
    pushf 
    push    SEG INT15hRet 
    push    OFFSET INT15hRet 
 
 
    ; Far Jump to Original INT 15h Handler 
    jmp     GotoOrigInt15hHandler 
 
 
    ; Real Handler return to here 
INT15hRet: 


ENDM



;------------------------------------------------------------------------------
; TSR Segment
;
_TSRTEXT SEGMENT PARA USE16 'RESIDENT'


CurIdx      DD      0



;##############################################################################
; Int15hHandler -- INT 15h Handler (Hook)
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
Int15hHandler PROC NEAR PUBLIC


    ; Check Function
    cmp     ax, 0e820h
    jne     Bypass


    ; Check SMAP
    cmp     edx, 'SMAP'
    jne     Bypass


    ; Save EBX
    mov     cs:CurIdx, ebx


    ; E820 Report Manipulation
    ;
    ; EBX == 0, Modify Length (Head)
    ; 
    cmp     ebx, 0              ; 0 ~ BLDR_START
    je      DoQuery


    ;
    ; EBX == 1, Report Bootloader
    ;
    cmp     ebx, 1              ; BLDR_START ~ A0000h
    je      ReportLoader


    ;
    ; 2 -- 0, Start Address and Length (Tail)
    ;
    cmp     ebx, 2              ; A0000h ~ Orig EBX=0
    je      ReportTail


    ;
    ; EBX >= 3
    ; 3 -- 1
    ; 4 -- 2
    ;
    sub     ebx, 2


DoQuery:


    ; Make Real Handler Return to us
    HookInt15h

    
    ; Handle EBX == 0
    cmp     cs:CurIdx, 0
    jne     @f

    mov     DWORD PTR es:[di+8], BLDR_START

@@:

    iret



ReportLoader:


    ; Query EBX == 0
    xor     ebx, ebx
    HookInt15h

    ; Report Fake EBX+1 == 2
    mov     ebx, cs:CurIdx
    inc     ebx

    ; Report Bootloader Region
    mov     DWORD PTR es:[di+0], BLDR_START
    mov     DWORD PTR es:[di+4], 0
    mov     DWORD PTR es:[di+8], BLDR_LENGTH
    mov     DWORD PTR es:[di+12], 0
    mov     DWORD PTR es:[di+16], 4
    mov     DWORD PTR es:[di+20], 0

    iret



ReportTail:


    ; Query EBX == 0
    xor     ebx, ebx
    HookInt15h

    ; Report Fake EBX+1 == 3
    mov     ebx, cs:CurIdx
    inc     ebx

    ; Modify Tail
    push    eax
    push    ebx

    mov     eax, DWORD PTR es:[di+0]
    add     eax, DWORD PTR es:[di+8]

    mov     ebx, BLDR_START + BLDR_LENGTH
    sub     eax, ebx

    mov     DWORD PTR es:[di+8], eax

    pop     ebx
    pop     eax

    mov     DWORD PTR es:[di+0], BLDR_START + BLDR_LENGTH

    iret



Bypass:


    jmp     GotoOrigInt15hHandler


Int15hHandler ENDP



GotoOrigInt15hHandler PROC NEAR PUBLIC


    ; Far Jump to Original INT 15h Handler
    DB      0EAh

OrigInt15hOff::
    DW      0000h

OrigInt15hSeg::
    DW      0000h

GotoOrigInt15hHandler ENDP



_TSRTEXT ENDS



;
; Extern Sub-Routines for TSR
;
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


    ; Install INT 15h Hook
    TsrInstallHookHandlerM 15h, Int15hHandler, OrigInt15hSeg, OrigInt15hOff


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


VERSION     DB      13, 10, 'int15tsr version 0.1 (C) 2008, Merck Hung', 13, 10, 13, 10, 24h
USAGE       DB      'Usage: int15tsr', 13, 10, 13, 10, 24h
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


