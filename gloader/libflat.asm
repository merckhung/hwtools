;
; libflat.asm -- (Reduced size)FLAT mode routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE ..\include\flat.inc
INCLUDE ..\include\routine.inc



;------------------------------------------------------------------------------
; libflat code segment
;
LIBFLAT SEGMENT USE16 'CODE'



;##############################################################################
; __enter_flat_mode -- go to FLAT mode(BigReal mode)
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   ALL
;
; Mode:
;   REAL mode
;
__enter_flat_mode PROC FAR PUBLIC


    ;--------------------------------------------------------------------------
    ; Setup FLAT mode
    ;--------------------------------------------------------------------------


    ; DS = CS
    push    cs
    pop     ds


    ; Convert GDT base physical address to linear one
    xor     eax, eax
    mov     ax, ds
    shl     eax, 4
    add     eax, OFFSET GDT_TABLE
    mov     dword ptr GDT_POINTER+2, eax


    ; Save original GDT and Load new one
    lgdt    fword ptr GDT_POINTER


    ; Save segment for later jump
    mov     ax, cs
    mov     word ptr ORIG_SEG, ax


    ; Disable interrupt
    cli


    ; Enable A20
    in      al, 92h
    or      al, 02h
    out     92h, al

    
    ; Enable protected mode
    mov     eax, cr0
    or      eax, 01h
    mov     cr0, eax
    jmp     @f                  ; Flush


@@:
    ; Setup Segments
    mov     ax, FLAT_DATA_SEG
    mov     ds, ax
    mov     es, ax


    ; Disbale protected mode
    mov     eax, cr0
    and     al, 0feh
    mov     cr0, eax


    ; jump to 16 bit FLAT mode
    DB      0eah
    DW      OFFSET @f
ORIG_SEG:
    DW      0000h


@@:


    ret

__enter_flat_mode ENDP



;##############################################################################
; __exit_flat_mode -- Leave FLAT mode(BigReal mode)
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   ALL
;
; Mode:
;   FLAT mode
;
__exit_flat_mode PROC FAR PUBLIC


    ; Disable A20
    in      al, 92h
    and     al, not 02h
    out     92h, al


    ; Reenable interrupt
    sti


    ret

__exit_flat_mode ENDP


;##############################################################################
; copy_data -- Move data from one to another space
;
; Input :
;   ESI = Source
;   EDI = Destination
;   ECX = Size in byte
;
; Output:
;   ESI = End of souece buffer
;   EDI = End of destination buffer
;   ECX = 0
;
; Modified:
;   ESI
;   EDI
;   ECX
;
copy_data PROC FAR PUBLIC

copy_loop:
    mov     al, [esi]
    mov     [edi], al

    inc     esi
    inc     edi
    dec     ecx
    jnz     copy_loop

    ret

copy_data ENDP


;##############################################################################
; Globel Segment descriptor
;
align 16
GDT_TABLE:


    ; NULL segment
    DW  0, 0, 0, 0


    ; Code segment, exec/read
FLAT_CODE_SEG       EQU     $ - GDT_TABLE
    DW  0ffffh
    DW  0
    DW  9a00h
    DW  00cfh


    ; Data segment, read/write
FLAT_DATA_SEG       EQU     $ - GDT_TABLE
    DW  0ffffh
    DW  0
    DW  9200h
    DW  00cfh

GDT_SIZE            EQU     $ - GDT_TABLE


;
; GDT Pointer
;
GDT_POINTER:
    DW  GDT_SIZE - 1
    DW  0               ;
    DW  0               ; GDT base address


@CurSeg ENDS

    END
