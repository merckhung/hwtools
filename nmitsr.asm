;
; nmitsr.asm -- NMI TSR to handle Memory ECC error
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a TSR program to handle Memory ECC error
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc
INCLUDE include\hdd.inc
INCLUDE include\tsr.inc



;------------------------------------------------------------------------------
; TSR Segment
;
_TSRTEXT SEGMENT PARA USE16 'RESIDENT'



;##############################################################################
; NMIHandler -- NMI Handler
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
NMIHandler PROC NEAR PUBLIC


    ; Write VGA
    push    ds
    push    ax
    push    bx

    mov     ax, 0B800h
    mov     ds, ax
    mov     bx, (68 * 2)


    ; Write WORD
    mov     BYTE PTR ds:[bx+00], 'E'
    mov     BYTE PTR ds:[bx+02], 'C'
    mov     BYTE PTR ds:[bx+04], 'C'
    mov     BYTE PTR ds:[bx+06], ' '
    mov     BYTE PTR ds:[bx+08], 'E'
    mov     BYTE PTR ds:[bx+10], 'R'
    mov     BYTE PTR ds:[bx+12], 'R'
    mov     BYTE PTR ds:[bx+14], 'O'
    mov     BYTE PTR ds:[bx+16], 'R'
    mov     BYTE PTR ds:[bx+18], '!'
    mov     BYTE PTR ds:[bx+20], '!'


    ; Write COLOR
    mov     BYTE PTR ds:[bx+01], 04Fh
    mov     BYTE PTR ds:[bx+03], 04Fh
    mov     BYTE PTR ds:[bx+05], 04Fh
    mov     BYTE PTR ds:[bx+07], 04Fh
    mov     BYTE PTR ds:[bx+09], 04Fh
    mov     BYTE PTR ds:[bx+11], 04Fh
    mov     BYTE PTR ds:[bx+13], 04Fh
    mov     BYTE PTR ds:[bx+15], 04Fh
    mov     BYTE PTR ds:[bx+17], 04Fh
    mov     BYTE PTR ds:[bx+19], 04Fh
    mov     BYTE PTR ds:[bx+21], 04Fh


    ; Stop Here
    jmp     $


NMIHandler ENDP



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
    mov     bx, (54 * 2)


    ; Write WORD
    mov     BYTE PTR ds:[bx+00], 'N'
    mov     BYTE PTR ds:[bx+02], 'M'
    mov     BYTE PTR ds:[bx+04], 'I'
    mov     BYTE PTR ds:[bx+06], ' '
    mov     BYTE PTR ds:[bx+08], 'I'
    mov     BYTE PTR ds:[bx+10], 'N'
    mov     BYTE PTR ds:[bx+12], 'S'
    mov     BYTE PTR ds:[bx+14], 'T'
    mov     BYTE PTR ds:[bx+16], 'A'
    mov     BYTE PTR ds:[bx+18], 'L'
    mov     BYTE PTR ds:[bx+20], 'L'
    mov     BYTE PTR ds:[bx+22], 'E'
    mov     BYTE PTR ds:[bx+24], 'D'


    ; Write COLOR
    mov     BYTE PTR ds:[bx+01], 01Fh
    mov     BYTE PTR ds:[bx+03], 01Fh
    mov     BYTE PTR ds:[bx+05], 01Fh
    mov     BYTE PTR ds:[bx+07], 01Fh
    mov     BYTE PTR ds:[bx+09], 01Fh
    mov     BYTE PTR ds:[bx+11], 01Fh
    mov     BYTE PTR ds:[bx+13], 01Fh
    mov     BYTE PTR ds:[bx+15], 01Fh
    mov     BYTE PTR ds:[bx+17], 01Fh
    mov     BYTE PTR ds:[bx+19], 01Fh
    mov     BYTE PTR ds:[bx+21], 01Fh
    mov     BYTE PTR ds:[bx+23], 01Fh
    mov     BYTE PTR ds:[bx+25], 01Fh


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



_ENDTSRTEXT SEGMENT PARA USE16
_ENDTSRTEXT ENDS



;
; Extern Sub-Routines for Main Program
;
routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
@CurSeg ENDS


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


    ; Install INT 10h Hook
    TsrInstallHookHandlerM 10h, Int10hHandler, OrigInt10hSeg, OrigInt10hOff


    ; Install NMI Handler
    TsrInstallHandlerM 02h, NMIHandler


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


VERSION     DB      13, 10, 'nmitsr version 0.1 (C) 2008, Merck Hung', 13, 10, 13, 10, 24h
USAGE       DB      'Usage: nmitsr', 13, 10, 13, 10, 24h
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


