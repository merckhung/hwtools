;
; tsr.inc -- Header file related to TSR routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;



;##############################################################################
; TsrInstallHandlerM -- TSR Handler Installer Macro
;
; Input:
;   VECTOR  -- Vector Number to Install
;   HANDLER -- Label of Interrupt Handler
;
; Output:
;   CX      -- Segment Address of Original Handler
;   DX      -- Offset Address of Original Handler
;
; Modified:
;   CX
;   DX
;
TsrInstallHandlerM MACRO VECTOR, HANDLER

    push    bx

    mov     bl, VECTOR
    mov     cx, SEG HANDLER
    mov     dx, OFFSET HANDLER

    call    TsrInstallHandler

    pop     bx

ENDM



;##############################################################################
; TsrSaveOriginalHandler -- Save Original Handler Segment:Offset to Variables
;
; Input:
;   SEGVAR  -- Segment Variable
;   OFFVAR  -- Offset Variable
;   CX      -- Segment Address of Original Handler
;   DX      -- Offset Address of Original Handler
;
; Output:
;   None
;
; Modified:
;   None
;
TsrSaveOriginalHandler MACRO SEGVAR, OFFVAR


    push    fs
    push    di


    ; Point to Buffer Segment
    push    SEG SEGVAR
    pop     fs


    ; Save the Address of Original INT Handler
    mov     di, OFFSET SEGVAR
    mov     fs:[di], cx

    mov     di, OFFSET OFFVAR
    mov     fs:[di], dx


    pop     di
    pop     fs


ENDM



;##############################################################################
; TsrInstallHookHandlerM -- TSR Hook Handler Installer Macro
;
; Input:
;   VECTOR  -- Vector Number to Install
;   HANDLER -- Label of Interrupt Handler
;   SEGVAR  -- Segment Variable
;   OFFVAR  -- Offset Variable
;
; Output:
;   CX      -- Segment Address of Original Handler
;   DX      -- Offset Address of Original Handler
;
; Modified:
;   CX
;   DX
;
TsrInstallHookHandlerM MACRO VECTOR, HANDLER, SEGVAR, OFFVAR


    ; Save Flags
    pushf


    ; Disable Interrupt
    cli


    ; Install Handler
    TsrInstallHandlerM VECTOR, HANDLER


    ; Save Original Handler Address
    TsrSaveOriginalHandler SEGVAR, OFFVAR


    ; Restore Flags (Included Interrupt)
    popf


ENDM



