;
; LIBDBG.asm -- Debug Library Routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\mdebug.inc



;
; extern sub-routines
;
routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
routine ENDS



;------------------------------------------------------------------------------
; LIBDBG segment
;
LIBDBG SEGMENT USE16 PUBLIC



;##############################################################################
; DbgCopyStringAndPrint -- Copy String to Tmp Buffer and Print
;
; Input:
;   AX  -- Segment
;   BX  -- Offset
;   BP  -- Length to Do Copy
;
; Output:
;   None
;
; Modified:
;   None
;
DbgCopyStringAndPrint PROC FAR PUBLIC

    pushad
    push    es
    push    ds


    ; Counter
    mov     cx, bp


    ; Setup Source
    mov     ds, ax
    mov     si, bx


    ; Setup Buffer
    push    SEG PrtBuf
    pop     es
    mov     di, OFFSET PrtBuf


copy_next:


    ; Do Copy
    mov     al, ds:[si]
    mov     es:[di], al
    inc     si
    inc     di
    dec     cx
    jnz     copy_next


    ; Next Line
    mov     al, 13
    mov     es:[di], al

    mov     al, 10
    mov     es:[di+1], al

    ; Terminated Char
    mov     al, 24h
    mov     es:[di+2], al


    ; Print Print
    push    SEG PrtBuf
    pop     ds              ; Setup Segment
    print_str PrtBuf


    pop     ds
    pop     es
    popad

    ret

DbgCopyStringAndPrint ENDP



;##############################################################################
; DbgDumpRegisters -- Dump All Registers
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
SEAX    DD      0
SEBX    DD      0
SECX    DD      0
SEDX    DD      0
SESI    DD      0
SEDI    DD      0
SEBP    DD      0
SESP    DD      0
SEFLAGS DD      0
SEIP    DD      0
SCS     DW      0
SDS     DW      0
SES     DW      0
SFS     DW      0
SGS     DW      0
SSS     DW      0
DbgDumpRegisters PROC FAR PUBLIC


    push    eax
    push    ebx


    ; Save All Registers
    mov     cs:SEAX, eax
    mov     cs:SEBX, ebx
    mov     cs:SECX, ecx
    mov     cs:SEDX, edx
    mov     cs:SESI, esi
    mov     cs:SEDI, edi
    mov     cs:SEBP, ebp


    ; ESP
    mov     cs:SESP, esp
    add     cs:SESP, 12     ; EBX + EAX + IP + CS = (4 + 4 + 2 + 2) = 12


    ; FLAGS
    pushf
    pop     ax
    and     eax, 0FFFFh
    mov     cs:SEFLAGS, eax


    ; Segment Registers
    mov     cs:SDS, ds
    mov     cs:SES, es
    mov     cs:SFS, fs
    mov     cs:SGS, gs
    mov     cs:SSS, ss


    ; IP from Stack
    mov     bx, sp
    mov     ax, ss:[bx+8]   ; EBX + EAX = IP = (4 + 4) = 8
    and     eax, 0FFFFh
    mov     cs:SEIP, eax


    ; CS from Stack
    mov     ax, ss:[bx+10]  ; EBX + EAX + IP = (4 + 4 + 2) = 10
    and     eax, 0FFFFh
    mov     cs:SCS, ax


    pop     ebx
    pop     eax


    pushad
    push    ds


    ; Setup DS
    push    SEG DumpRegs01
    pop     ds


    ; EIP
    mov     eax, cs:SEIP
    replace_ascii_str   DumpRegs01, 8, 5 


    ; EFLAGS
    mov     eax, cs:SEFLAGS
    replace_ascii_str   DumpRegs01, 8, 23


    ; EAX
    mov     eax, cs:SEAX
    replace_ascii_str   DumpRegs02, 8, 5


    ; EBX
    mov     eax, cs:SEBX
    replace_ascii_str   DumpRegs02, 8, 21


    ; ECX
    mov     eax, cs:SECX
    replace_ascii_str   DumpRegs02, 8, 37


    ; EDX
    mov     eax, cs:SEDX
    replace_ascii_str   DumpRegs02, 8, 53


    ; ESP
    mov     eax, cs:SESP
    replace_ascii_str   DumpRegs03, 8, 5


    ; EBP
    mov     eax, cs:SEBP
    replace_ascii_str   DumpRegs03, 8, 21


    ; EDI
    mov     eax, cs:SEDI
    replace_ascii_str   DumpRegs03, 8, 37


    ; ESI
    mov     eax, cs:SESI
    replace_ascii_str   DumpRegs03, 8, 53


    ; CS
    mov     ax, cs:SCS
    replace_ascii_str   DumpRegs04, 4, 4


    ; DS
    mov     ax, cs:SDS
    replace_ascii_str   DumpRegs04, 4, 15


    ; ES
    mov     ax, cs:SES
    replace_ascii_str   DumpRegs04, 4, 37


    ; FS
    mov     ax, cs:SFS
    replace_ascii_str   DumpRegs04, 4, 48


    ; SS
    mov     ax, cs:SSS
    replace_ascii_str   DumpRegs04, 4, 26


    ; GS
    mov     ax, cs:SGS
    replace_ascii_str   DumpRegs04, 4, 59


    ; Print All Registers
    print_str DumpRegs


    pop     ds
    popad


    ret

DbgDumpRegisters ENDP



;##############################################################################
; DbgDumpMemory -- Dump Memory Range
;
; Input:
;   AX  -- Segment
;   BX  -- Offset
;   BP  -- Length
;
; Output:
;   None
;
; Modified:
;   None
;
DbgDumpMemory PROC FAR PUBLIC

    pushad
    push    ds
    push    es


    ; Setup Memory Pointr
    mov     es, ax
    mov     di, bx


    ; Setup Counter
    mov     cx, bp


    ; Setup Data Segment
    push    SEG DumpMemTit
    pop     ds


    ;
    ; Print Title
    ;
    pushad
    print_str DumpMemTit
    print_str DumpMemTai
    popad


NextLine:


    ;
    ; Print Offset Address
    ;
    pushad
    xor     eax, eax                    ;
    mov     ax, es                      ;
    and     edi, 0FFFFh                 ;
    shl     eax, 4                      ;
    add     eax, edi                    ; Convert to Linear Address
    replace_ascii_str   AddrBuf, 8, 0   ; Convert to Ascii
    print_str AddrBuf                   ; Print Linear Address
    popad



    mov     bx, BYTE_PER_LINE           ; Counter for Printing 16 Bytes
    

NextByte:


    ;
    ; Print 16 Bytes
    ;
    pushad
    mov     al, es:[di]                 ; Read one byte
    replace_ascii_str   ByteBuf, 2, 0   ; Convert to ASCII
    print_str ByteBuf                   ; Print this byte
    popad


    ; Move to next Byte
    inc     di
    dec     bx
    jnz     NextByte



    ;
    ; Print ASCII
    ;
    pushad
    mov     bx, BYTE_PER_LINE           ; Print 16 Byte in ASCII
    sub     di, BYTE_PER_LINE           ; Move back 16 bytes we just printed


NextASCII:


    ; Read one byte
    mov     al, es:[di]                 ; Read one byte
    mov     AsciiBuf, al                ; Push into buffer


    ; Check non-print-able ASCII
    cmp     al, ' '                     ; 0x20 <WHITE SPACE>
    jb      Cannotprint
    cmp     al, '~'                     ; 0x7E
    ja      Cannotprint
    jmp     PrintASCII

Cannotprint:

    ; Print '.' if it cannot be printed out
    mov     al, '.'
    mov     AsciiBuf, al

PrintASCII:

    ; Print ASCII Character
    pushad
    print_str AsciiBuf
    popad

    ; Move to next Byte
    inc     di
    dec     bx
    jnz     NextASCII   
    popad


    ; Print New Line
    pushad
    print_str NLBuf
    popad


    ; Move to Next Line
    sub     cx, BYTE_PER_LINE
    jnz     NextLine


    ; Print tail
    print_str DumpMemTai


    pop     es
    pop     ds
    popad
    ret

DbgDumpMemory ENDP



;------------------------------------------------------------------------------
; Start of Data Region
;
DumpRegs    DB      '----------------------------------------------------------------', 13, 10
DumpRegs01  DB      'EIP: ????????h, FLAGS: ????????h', 13, 10
DumpRegs02  DB      'EAX: ????????h, EBX: ????????h, ECX: ????????h, EDX: ????????h', 13, 10
DumpRegs03  DB      'ESP: ????????h, EBP: ????????h, EDI: ????????h, ESI: ????????h', 13, 10
DumpRegs04  DB      'CS: ????h, DS: ????h, SS: ????h, ES: ????h, FS: ????h, GS: ????h', 13, 10
DumpRegs05  DB      '----------------------------------------------------------------', 13, 10, 24h

DumpMemTit  DB      '-Address-| 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F|0123456789ABCDEF', 13, 10, 24h
DumpMemTai  DB      '---------------------------------------------------------------------------', 13, 10, 24h

AddrBuf     DB      '????????h: ', 24h
ByteBuf     DB      '?? ', 24h
NLBuf       DB      13, 10, 24h
AsciiBuf    DB      '?', 24h

PrtBuf      DB      LENOF_TMP_BUF DUP( 0 )
;
; End of Data Region
;------------------------------------------------------------------------------



LIBDBG ENDS


    END


