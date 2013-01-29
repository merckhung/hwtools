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
INCLUDE include\tsr.inc



;------------------------------------------------------------------------------
; Code segment
;
LIBTSR SEGMENT PARA USE16 PUBLIC



;##############################################################################
; RegisterTSR -- Register Resident Program
;
; Input:
;   DX  -- End Address of TSR Code
;
; Output:
;   None
;
; Modified:
;   None
;
TsrRegister PROC FAR PUBLIC


    push    ax
    push    bx
    push    dx


    ; Save DX
    push    dx


    ; Get PSP Value
    mov     ah, 62h
    int     21h


    ; Restore DX  
    pop     dx


    ; Get the size of TSR
    sub     dx, bx


    ; Register TSR
    mov     ax, 3100h
    int     21h


    pop     dx
    pop     bx
    pop     ax

    ret

TsrRegister ENDP



;##############################################################################
; TsrInstallHandler -- Install Interrupt Handler to Vector Table
;
; Input:
;   BL  -- Interrupt Vector Number
;   CX  -- Segment Address of New Handler
;   DX  -- Offset Address of New Handler
;
; Output:
;   CX  -- Segment Address of Original Handler
;   DX  -- Offset Address of Original Handler
;
; Modified:
;   None
;
OrigIntOffset   DW      0000h
OrigIntSegment  DW      0000h
TsrInstallHandler PROC FAR PUBLIC


    ; Save Registers
    push    ax
    push    ebx
    push    di
    push    es
    push    fs
    pushf


    ; Disable Interrupt
    cli


    ; Point to Vector Table
    xor     ax, ax
    mov     es, ax
    and     ebx, 0FFh


    ; Setup Segment for New Handler
    push    SEG TsrInstallHandler
    pop     fs


    ; Save the Address of original INT handler
    mov     di, OFFSET OrigIntOffset
    mov     ax, WORD PTR es:[ebx*4]
    mov     fs:[di], ax

    mov     di, OFFSET OrigIntSegment
    mov     ax, WORD PTR es:[ebx*4+2]
    mov     fs:[di], ax


    ; Install NEW INT Handler
    mov     es:[ebx*4], dx
    mov     es:[ebx*4+2], cx


    ; Prepare Return Variable
    mov     cx, fs:[di]
    mov     di, OFFSET OrigIntOffset
    mov     dx, fs:[di]


    ; Restore Registers (Included Interrupt Flag)
    popf
    pop     fs
    pop     es
    pop     di
    pop     ebx
    pop     ax


    ret

TsrInstallHandler ENDP



LIBTSR ENDS


    END


