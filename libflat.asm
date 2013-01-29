;
; libflat.asm -- FLAT mode routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a library for FLAT mode operation
;
.586P


INCLUDE include\flat.inc
INCLUDE include\routine.inc



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
; sys_print -- print string on console
;
; Input:
;   ESI =   Buffer pointer
;   EDX =   Cursor position
;
; Output:
;   EDX =   Lastest cursor position
;
; Modified:
;   AX
;   EDI
;
; Mode:
;   FLAT mode
;
sys_print PROC FAR PUBLIC


    ; Save registers
    push    ax
    push    edi


    ; AL : ASCII code
    xor     al, al


    ; point to Video ram
    mov     edi, VIDEO_BASE


_sys_print_loop:


    ; get ASCII char
    mov     al, [esi]


    ; Check terminal char NULL
    cmp     al, 0
    jz      _sys_print_exit


    ; Check new line
    cmp     al, 10
    jnz     _sys_print_not_nl


    ; go to next line
    mov     ax, dx
    mov     dl, BCOLUMN
    div     dl

    inc     al
    mul     dl

    dec     ax
    dec     ax
    mov     dx, ax

    jmp     _sys_print_next_char


_sys_print_not_nl:
    ; Print on screen
    mov     [edi+edx], al


_sys_print_next_char:

    ; Pointer++
    inc     esi
    inc     edx
    inc     edx


    jmp     _sys_print_loop


_sys_print_exit:
    ; Restore registers
    pop     edi
    pop     ax


    ret
    
sys_print ENDP


;##############################################################################
; sys_cls -- Clear screen
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   EBX
;   EBP
;
; Mode:
;   FLAT mode
;
sys_cls PROC FAR PUBLIC

    push    ax
    push    ebx
    push    ebp

    xor     ebx, ebx
    mov     ebp, VIDEO_BASE
    mov     ax, DEFA_SCR

sys_cls_loop:
    mov     [ebp+ebx], ax

    add     ebx, 2 
    cmp     ebx, BCOLUMN * LINE
    jnz     sys_cls_loop


    ; Reset cursor
    xor     ax, ax
    call    direct_set_cursor


    pop     ebp
    pop     ebx
    pop     ax

    ret

sys_cls ENDP



;##############################################################################
; flat_conv_push_ascii -- Convert binary to ASCII code and then push into buffer
;                         FLAT mode version
; Input :
;   EAX     = Binary (32bits)
;   CL      = maximum bits to offset
;   EDI     = buffer pointer we want to push ASCII code into (linear address)
;
; Output:
;   None
;
; Modified:
;   EAX
;
; Mode:
;   FLAT mode
;
flat_conv_push_ascii PROC FAR PUBLIC


    push    eax


fcpa_start:


    ; Save original input
    push    eax
    

    ; EAX >> CL
    shr     eax, cl
    

    ; Mask all unnecessary bits(remain 4 least significant bit)
    and     eax, 0000000fh


    ;
    ; if( AL < 10 ) {
    ;
    ;   goto cpa_below;
    ; }
    ;
    cmp     al, 0ah
    jb      fcpa_below
    

fcpa_above_equal:
    add     al, 41h - 0ah
    jmp     fcpa_write_buf


fcpa_below:
    or      al, 30h


fcpa_write_buf:
    mov     [edi], al
    inc     edi


    ; Restore original input for next loop use
    pop     eax


    ; CL -= 4
    sub     cl, NBPAB


    ;
    ; if( CL != -4 ) {
    ;
    ;   goto cpa_start;
    ; }
    ;
    cmp     cl, -NBPAB
    jnz     fcpa_start


    pop     eax


    ret

flat_conv_push_ascii ENDP




;##############################################################################
; direct_set_cursor -- Set console cursor
;
; Input:
;   AH  = COLUMN
;   AL  = LINE
;
; Output:
;   None
;
; Modified:
;   BX
;   DX
;
; Mode:
;   FLAT mode
;
direct_set_cursor PROC FAR PUBLIC

    push    bx
    push    dx


    ; AL * 80 = LINE * 80 = AX
    mov     bh, ah
    mov     bl, COLUMN
    mul     bl
    

    ; AX + COLUMN
    shr     bx, 8
    and     bx, 0ffh
    add     ax, bx
    mov     bx, ax


    ; Write cursor MSB
    mov     dx, CRTC_ADDR
    mov     al, 0eh
    out     dx, al

    mov     dx, CRTC_DATA
    mov     al, bh
    out     dx, al


    ; Write cursor LSB
    mov     dx, CRTC_ADDR
    mov     al, 0fh
    out     dx, al

    mov     dx, CRTC_DATA
    mov     al, bl
    out     dx, al


    pop     dx
    pop     bx

    ret

direct_set_cursor ENDP






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


