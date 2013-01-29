;
; libfun32.asm -- protected mode routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a library of common routines under protected mode
;
.586P


INCLUDE ..\include\routine.inc



;------------------------------------------------------------------------------
; libfun32 32bit protected mode code segment
;
LIBFUN32 SEGMENT USE32 PUBLIC 'CODE'



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
;   None
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
;   None
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
; pm_conv_push_ascii -- Convert binary to ASCII code and then push into buffer
;                       protected mode version
; Input :
;   EAX     = Binary (32bits)
;   CL      = maximum bits to offset
;   EDI     = buffer pointer we want to push ASCII code into (linear address)
;
; Output:
;   None
;
; Modified:
;   None
;
pm_conv_push_ascii PROC FAR PUBLIC


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

pm_conv_push_ascii ENDP



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
;   None
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



LIBFUN32 ENDS


    END


