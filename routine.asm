;
; routine.asm -- generic routines library for x86 assembly
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of generic routines for x86 assembly programming.
;
.586P


INCLUDE include\routine.inc


routine SEGMENT USE16 PUBLIC


;##############################################################################
; conv_push_ascii -- Convert binary to ASCII code and then push into buffer
;
; Input :
;   EAX     = Binary (32bits)
;   CL      = maximum bits to offset
;   DS:DI   = buffer pointer we want to push ASCII code into
;
; Output:
;   None
;
; Modified:
;   EAX
;
conv_push_ascii PROC FAR PUBLIC


    push    eax


cpa_start:


    ; Save original input
    push    eax
    

    ; EAX >> CL
    shr     eax, cl
    

    ; Mask all unnecessary bits(remain 4 least significant bit)
    and     eax, 0000000fh


    ;
    ; if( AL < 10 ) {
    ;
    ;   datb_goto cpa_below;
    ; }
    ;
    cmp     al, 0ah
    jb      cpa_below
    

cpa_above_equal:
    add     al, 41h - 0ah
    jmp     cpa_write_buf


cpa_below:
    or      al, 30h


cpa_write_buf:
    mov     ds:[di], al
    inc     di


    ; Restore original input for next loop use
    pop     eax


    ; CL -= 4
    sub     cl, NBPAB


    ;
    ; if( CL != -4 ) {
    ;
    ;   datb_goto cpa_start;
    ; }
    ;
    cmp     cl, -NBPAB
    jnz     cpa_start


    pop     eax


    ret

conv_push_ascii ENDP


;##############################################################################
; paste_string -- Paste string in buffer
;
; Input :
;   DS:SI = Source pointer
;   ES:DI = Destination pointer
;   BX    = Size of Source buffer
;   CX    = Size of Destination buffer
;
; Output:
;   None
;
; Modified:
;   None
;
paste_string PROC FAR PUBLIC

    ;
    ; if( dest >= src ) {
    ;
    ;   datb_goto paste_string_above
    ; }
    ;
    cmp     cx, bx
    jae     paste_string_above

    mov     cx, bx

paste_string_above:

    test    cx, 1
    jz      paste_string_even

paste_string_odd:

    rep     movsb

    ret

paste_string_even:

    ; CX /= 2
    shr     cx, 1
    rep     movsw

    ret

paste_string ENDP


;##############################################################################
; byte_ascii_to_byte -- Convert two byte ASCII to one byte Binary
;
; Input :
;   AX  = ASCII code to convert
;
; Output:
;   AL  = Binary
;   Carry Flag, 0: False, 1: True
;
; Modified:
;   None
;
byte_ascii_to_bin PROC FAR PUBLIC


    xchg    ah, al


    ;----------------------------
batb_lsb:

    ; Check >= 'a'
    cmp     al, 'a'
    jb      batb_lsb_not_lower

    ; Check <= 'f'
    cmp     al, 'f'
    ja      batb_error

    ; Convert and go to msb
    sub     al, 'a'
    add     al, 10
    jmp     batb_msb
    
batb_lsb_not_lower:

    ; Check >= 'a'
    cmp     al, 'A'
    jb      batb_lsb_not_upper

    ; Check <= 'F'
    cmp     al, 'F'
    ja      batb_error

    ; Convert and go to msb
    sub     al, 'A'
    add     al, 10
    jmp     batb_msb

batb_lsb_not_upper:

    ; Check >= '0'
    cmp     al, '0'
    jb      batb_error

    ; Check <= '9'
    cmp     al, '9'
    ja      batb_error

    ; Convert and go to msb
    sub     al, '0'



    ;----------------------------
batb_msb:

    ; Check >= 'a'
    cmp     ah, 'a'
    jb      batb_msb_not_lower

    ; Check <= 'f'
    cmp     ah, 'f'
    ja      batb_error

    ; Convert and exit
    sub     ah, 'a'
    add     ah, 10
    jmp     batb_mul16
    
batb_msb_not_lower:

    ; Check >= 'A'
    cmp     ah, 'A'
    jb      batb_msb_not_upper

    ; Check <= 'F'
    cmp     ah, 'F'
    ja      batb_error

    ; Convert and exit
    sub     ah, 'A'
    add     ah, 10
    jmp     batb_mul16

batb_msb_not_upper:

    ; Check >= '0'
    cmp     ah, '0'
    jb      batb_error

    ; Check <= '9'
    cmp     ah, '9'
    ja      batb_error

    ; Convert and exit
    sub     ah, '0'

batb_mul16:

    shl     ah, 4
    or      al, ah

    clc
    jmp     batb_exit


batb_error:
    
    stc

batb_exit:

    ret

byte_ascii_to_bin ENDP


;##############################################################################
; dword_ascii_to_bin -- Convert 4 bytes ASCII to Binary
;
; Input :
;   EAX = ASCII code to convert
;
; Output:
;   AX  = Binary
;   Carry Flag, 0: False, 1: True
;
; Modified:
;   EBX
;   ECX
;   EDX
;
dword_ascii_to_bin PROC FAR PUBLIC


    push    ebx
    push    ecx
    push    edx


    xor     edx, edx

    mov     ch, 4
    mov     cl, 6 * 4

datb_loop:
    push    eax
    shr     eax, cl
    and     eax, 0ffh
    call    byte_ascii_to_bin
    jc      datb_error


    ; 16^6
    cmp     ch, 4
    jnz     @f
    mov     ebx, 16 * 16 * 16 * 16 * 16 * 16
    jmp     datb_got
@@:

    ; 16^4
    cmp     ch, 3
    jnz     @f
    mov     ebx, 16 * 16 * 16 * 16
    jmp     datb_got
@@:

    ; 16^2
    cmp     ch, 2
    jnz     @f
    mov     ebx, 16 * 16
    jmp     datb_got
@@:

    ; 16^0 = 1
    mov     ebx, 1
    

datb_got:


    ; EAX * EBX = EDX:EAX
    mul     ebx


    ; Save result
    add     edx, eax

    ; restore original input for next loop
    pop     eax

    sub     cl, 2 * 4
    dec     ch
    jnz     datb_loop


    mov     eax, edx

    clc
    jmp     datb_exit

datb_error:
    stc     

datb_exit:

    pop     edx
    pop     ecx
    pop     ebx

    ret

dword_ascii_to_bin ENDP


@CurSeg ENDS
    END
