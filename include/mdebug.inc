;
; mdebug.inc -- Debug Macro routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


BYTE_PER_LINE       EQU     16
LENOF_TMP_BUF       EQU     512



;##############################################################################
; debug_ascii_str -- print ascii number and debug string
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CX
;   DI
;
debug_ascii_str MACRO STRP, BA, OFFS

IFDEF DEBUG
    push    eax
    push    cx
    push    di

    mov     cl, (BA - 1) * NBPAB
    mov     di, offset STRP
    add     di, OFFS
    call    conv_push_ascii
    print_str STRP

    pop     di
    pop     cx
    pop     eax
ENDIF

ENDM


;##############################################################################
; debug_str -- print debug string
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
debug_str MACRO STRP

IFDEF DEBUG
    print_str STRP
ENDIF

ENDM


;##############################################################################
; debug_eax -- Print EAX
;
; Input:
;   EAX
;
; Output:
;   None
;
; Modified:
;   EAX
;
debug_eax MACRO

    push    eax

    print_ascii_str debug_msg, 8, 12

    pop     eax

ENDM


;##############################################################################
; debug_print_str
;
debug_print_str MACRO STRING

    LOCAL   debug_string, debug_value, dps_done

IFDEF DEBUG

    
    pushad
    push    ds


    ; DS = CS
    push    cs
    pop     ds
    

    replace_ascii_str debug_value, 8, 12
    print_str debug_string


    pop     ds
    popad


    jmp     dps_done

debug_string    DB  STRING
debug_value     DB  ', value = 0x00000000h', 13, 10, 24h

dps_done:
ENDIF

ENDM


;##############################################################################
; debug_print_onlystr
;
debug_print_onlystr MACRO STRING

    LOCAL   debug_string, debug_value, dps_done

IFDEF DEBUG

    
    push    ds


    ; DS = CS
    push    cs
    pop     ds
    
    print_str debug_string

    pop     ds


    jmp     dps_done

debug_string    DB  STRING, 13, 10, 24h

dps_done:
ENDIF

ENDM


;##############################################################################
; debug_read_msr
;
debug_read_msr MACRO ADDRESS

IFDEF DEBUG

    mov     eax, ADDRESS
    debug_print_str 'Read MSR Address'

    xor     eax, eax
    xor     edx, edx
    mov     ecx, ADDRESS
    rdmsr

    
    ; Save result
    push    eax
    push    edx
    

    debug_print_str '     MSR EAX'


    mov     eax, edx
    debug_print_str '     MSR EDX'


    ; Restore result
    pop     edx
    pop     eax


ENDIF

ENDM


;##############################################################################
; debug_write_msr
;
debug_write_msr MACRO ADDRESS, DVALUE, AVALUE

IFDEF DEBUG

    push    eax

    mov     eax, ADDRESS
    debug_print_str 'Write MSR Address'

    pop     eax

IFNB <DVALUE>

    mov     eax, DVALUE
    debug_print_str 'Write MSR DValue '

    mov     eax, AVALUE
    debug_print_str 'Write MSR AValue '

    mov     edx, DVALUE
    mov     eax, AVALUE

ELSE

    push    eax
    push    edx

    xchg    eax, edx
    debug_print_str 'Write MSR DValue '

    mov     eax, edx
    debug_print_str 'Write MSR AValue '

    pop     edx
    pop     eax

ENDIF


    mov     ecx, ADDRESS
    wrmsr

ENDIF

ENDM


;##############################################################################
; SaveRegsValues32Bit -- Save Register Value, Convert to ASCII, and Push into
;                        Buffer. (32 bits)
;
; Input:
;   REG     -- Register Name
;   BUF     -- Buffer to Write
;   OFF     -- Offset in Buffer
;
;   DS      -- Segment of Buffer
;
; Output:
;   None
;
; Modified:
;   None
;
SaveRegsValues32Bit MACRO REG, BUF, OFF

    push    eax
    push    cx
    push    di
    
    mov     eax, REG
    replace_ascii_str   BUF, 8, OFF

    pop     di
    pop     cx
    pop     eax

ENDM


;##############################################################################
; SaveRegsValues16Bit -- Save Register Value, Convert to ASCII, and Push into
;                        Buffer. (16 bits)
;
; Input:
;   REG     -- Register Name
;   BUF     -- Buffer to Write
;   OFF     -- Offset in Buffer
;
;   DS      -- Segment of Buffer
;
; Output:
;   None
;
; Modified:
;   None
;
SaveRegsValues16Bit MACRO REG, BUF, OFF

    push    eax
    push    cx
    push    di

    mov     ax, REG
    replace_ascii_str   BUF, 4, OFF

    pop     di
    pop     cx
    pop     eax

ENDM



;##############################################################################
; DbgDumpMemoryM -- Dump Memory Macro
;
; Input:
;   BUF     -- Buffer to Dump
;   Len     -- Length of Buffer
;
; Output:
;   None
;
; Modified:
;   None
;
DbgDumpMemoryM MACRO BUF, LEN

    push    ax
    push    bx
    push    bp


    mov     ax, SEG BUF
    mov     bx, OFFSET BUF
    mov     bp, LEN
    call    DbgDumpMemory


    pop     bp
    pop     bx
    pop     ax

ENDM



