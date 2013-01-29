;
; rcitool.asm -- A tool for Dell Remote Configuration Interface(RCI)
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a tool made for handling Dell Remote Configuration Interface(RCI)
;
.586P


INCLUDE ..\include\mroutine.inc
INCLUDE ..\include\routine.inc
INCLUDE ..\include\mdebug.inc
INCLUDE ..\include\flat.inc
INCLUDE ..\include\rci.inc


;------------------------------------------------------------------------------
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'


;
; extern sub-routines
;
routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
@CurSeg ENDS
libflat SEGMENT USE16 PUBLIC

    EXTERN __enter_flat_mode:FAR
    EXTERN __exit_flat_mode:FAR
@CurSeg ENDS


INSTALL_RCI TYPE0, TYPE1, TYPE2, TYPE3, TYPE4


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
    ASSUME  SS:STACK, DS:_DATA, CS:_TEXT, ES:_DATA
    mov     ax, _DATA
    mov     ds, ax

    mov     ax, es
    mov     PSP, ax

    mov     ax, _DATA
    mov     es, ax
    mov     gs, ax      ; This will be used in FLAT mode sys_print


    ;
    ; Main Flow Start
    ;
    mov     ax, 0f000h
    mov     es, ax


    xor     ebx, ebx
scan:

    mov     eax, es:[bx]
    cmp     eax, RCI_ENTRY_SIGNATURE
    jz      found

    add     bx, RCI_ENTRY_BOUND
    cmp     bx, 0fff0h
    jnz     scan
    

    print_str   norci
    jmp     main_exit


found:


    ; Save the address of RCI entry
    and     ebx, 0ffffh
    mov     rcioff, bx


    ; Print out RCI Entry
    xor     eax, eax
    mov     ax, es
    shl     eax, 4
    or      eax, ebx
    replace_ascii_str   re0, 8, 22


    mov     dword ptr eax, es:[bx]
    replace_ascii_str   re1, 8, 13


    mov     al, es:[bx].rciEntryStruc.rciep_len
    replace_ascii_str   re2, 2, 13


    mov     al, es:[bx].rciEntryStruc.rciep_chksm
    replace_ascii_str   re3, 2, 13


    mov     al, es:[bx].rciEntryStruc.rciep_ver
    replace_ascii_str   re4, 2, 13


    mov     eax, es:[bx].rciEntryStruc.rci_addr
    mov     rciadd, eax
    replace_ascii_str   re5, 8, 13

    
    print_str   re


;--------------------------------------------------------------------------
; Enter FLAT mode
;--------------------------------------------------------------------------
enter_flat_mode
;--------------------------------------------------------------------------
; FLAT mode code start
;--------------------------------------------------------------------------


    ; Get address of RCI Tables
    mov     ebx, gs:rciadd

   
    ; Check hdrlen > 0
    cmp     [ebx].rciCommHdrStruc.hdrlen, 0
    jz      no_gtbl

    ; Check hdrlen <= 0ffh
    cmp     [ebx].rciCommHdrStruc.hdrlen, 0ffh
    jz      no_gtbl



    ; Check Type == 0
    cmp     [ebx].rciCommHdrStruc.hdrtype, 0
    jnz     @f

    call    rciShowType0        

@@:
    ; Check Type == 1
    cmp     [ebx].rciCommHdrStruc.hdrtype, 1
    jnz     @f

    call    rciShowType1

@@:
    ; Check Type == 2
    cmp     [ebx].rciCommHdrStruc.hdrtype, 2
    jnz     @f

    call    rciShowType2

@@:
    ; Check Type == 3
    cmp     [ebx].rciCommHdrStruc.hdrtype, 3
    jnz     @f

    call    rciShowType3

@@:
    ; Check Type == 4
    cmp     [ebx].rciCommHdrStruc.hdrtype, 4
    jnz     @f

    call    rciShowType4

@@:


no_gtbl:


;--------------------------------------------------------------------------
; Exit FLAT mode
;--------------------------------------------------------------------------
exit_flat_mode
;--------------------------------------------------------------------------
; REAL mode code
;--------------------------------------------------------------------------


    ;
    ; Print out all structures
    ;
    print_str   ty0
    print_str   ty1
    print_str   ty2
    print_str   ty3
    print_str   ty4


    ;
    ; End of Main Flow
    ;


main_exit:

    print_str version

    
    ; Return to DOS
    ret


MAIN ENDP


;##############################################################################
; rciShowType0 -- Show RCI Table Type 0
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
rciShowType0 PROC FAR PUBLIC

    ret

rciShowType0 ENDP


;##############################################################################
; rciShowType1 -- Show RCI Table Type 1
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
rciShowType1 PROC FAR PUBLIC

    ret

rciShowType1 ENDP


;##############################################################################
; rciShowType2 -- Show RCI Table Type 2
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
rciShowType2 PROC FAR PUBLIC

    ret

rciShowType2 ENDP


;##############################################################################
; rciShowType3 -- Show RCI Table Type 3
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
rciShowType3 PROC FAR PUBLIC

    ret

rciShowType3 ENDP


;##############################################################################
; rciShowType4 -- Show RCI Table Type 4
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
rciShowType4 PROC FAR PUBLIC

    ret

rciShowType4 ENDP


;##############################################################################
; rciEntryCalChksm -- Calculate and then fill in RCI Entry Checksum
;
; Input:
;  ES -- Segment of RCI Entry
;  BX -- Offset of RCI Entry
;
; Output:
;  AL    = Checksum value
;
; Modified:
;  AX
;
rciEntryCalChksm PROC NEAR PUBLIC

    push    bx
    push    cx


    ; Get length
    xor     al, al
    mov     cl, es:[bx].rciEntryStruc.rciep_len

    ; Prepare for skiping RCIEP_CHKSM field
    mov     ch, cl
    sub     ch, 05h

sumvalue:
    
    ; Check for skiping RCIEP_CHKSM field
    cmp     cl, ch
    jz      skipcm

    ; Sum values
    add     al, es:[bx]

skipcm:

    inc     bx
    dec     cl
    jnz     sumvalue


    ; Calculate two's compl
    not     al
    inc     al


    pop     cx
    pop     bx

    ret

rciEntryCalChksm ENDP


;##############################################################################
; rciEntryWrChksm -- Write Checksum to RCI Entry Structure
; 
; Input:
;  AL -- Checksume of RCI Entry in byte
;  ES -- Segment of RCI Entry
;  BX -- Offset of RCI Entry
;
; Output:
;  None
;
; Modified:
;  None
;
rciEntryWrChksm PROC NEAR PUBLIC

    mov     es:[bx].rciEntryStruc.rciep_chksm, al
    ret

rciEntryWrChksm ENDP


;##############################################################################
; rciEntryVerChksm -- Verify RCI Entry Checksum
;
; Input:
;  ES -- Segment of RCI Entry
;  BX -- Offset of RCI Entry
;
; Output:
;  None
;
; Modified:
;  BX
;
rciEntryChksm PROC NEAR PUBLIC

    push    ax
    push    bx
    push    es

    
    ; Get segment and offset of RCI Entry Structure
    mov     ax, 0f000h
    mov     es, ax

    mov     bx, 0000h


    call    rciEntryCalChksm
    call    rciEntryWrChksm


    pop     es
    pop     bx
    pop     ax

    ret

rciEntryChksm ENDP


;##############################################################################
; rciEntryVerChksm -- Verify RCI Entry Checksum
;
; Input:
;  ES -- Segment of RCI Entry
;  BX -- Offset of RCI Entry
;
; Output:
;  Carry = 1, Checksum is missmatch
;  Carry = 0, Checksum is match
;
; Modified:
;  None
;
rciEntryVerChksm PROC NEAR PUBLIC

    push    ax
    push    bx
    push    es

    
    ; Get segment and offset of RCI Entry Structure
    mov     ax, 0f000h
    mov     es, ax

    mov     bx, 0000h


    ; Get original checksum
    mov     ah, es:[bx].rciEntryStruc.rciep_chksm


    ; Re-Calculate new checksum
    call    rciEntryCalChksm


    clc

    ; Compare two values
    cmp     ah, al
    jz      chk_ok    

    stc


chk_ok:


    pop     es
    pop     bx
    pop     ax

    ret

rciEntryVerChksm ENDP


IF 0
;##############################################################################
; rciPutEntry -- Lookup a free range which resides in 0x000F0000 to 0x000FFFF0
;                to put Remote Configuration Interface(RCI) Entry
;
; Input:
;   None
;
; Output:
;   Carry = 1, Cannot put RCI Entry
;   Carry = 0, Put RCI Entry Done Successfully
;
; Modified:
;   Carry Flag
;
rciPutEntry PROC NEAR PUBLIC

    push    eax
    push    bx
    push    cx
    push    es


    ;
    ; Prepare for scan
    ; Range: 0x000F0000 to 0x000FFFF0
    ;
    mov     ax, RCI_SEGMENT_START
    mov     es, ax

    mov     bx, RCI_OFFSET_START

scan:
    ;
    ; Check if this boundary empty?
    ;
    mov     eax, es:[bx]
    cmp     eax, 0
    jnz     scan_next


    ;
    ; First Double Word is empty
    ; Then, check whether we can fill in RCI Entry?
    ;
    push    bx

    mov     cl, RCI_ENTRY_LEN
    test    cl, 03h             ; Check Align 4 bytes
    jz      chk_len

    add     cl, 4
    and     cl, 0fch            ; Make length align 4 bytes boundary

    xor     ch, ch

chk_len:
    add     bx, 4
    sub     cl, 4

    mov     eax, es:[bx] 
    cmp     eax, 0
    jz      is_empty

    or      ch, 1

is_empty:
    cmp     cl, 0
    jnz     chk_len

    pop     bx


    ;
    ; CH = 0? If this is yes, we found a free range.
    ;
    test    ch, 1
    jnz     scan_next


    push    eax
    xor     eax, eax
    mov     ax, bx
    debug_print_str 'Find RCI Entry'
    pop     eax


    ;
    ; Fill in RCI Entry start from this Address
    ;
    mov     eax, RCI_ENTRY_SIGNATURE
    mov     dword ptr es:[bx].rciEntryStruc.rci_anchor, eax
    mov     es:[bx].rciEntryStruc.rciep_len, RCI_ENTRY_LEN
    mov     es:[bx].rciEntryStruc.rciep_ver, RCI_ENTRY_VER

    
    ;
    ; Lookup rci_addr to fill in
    ;
    ; call rciLookupTblAddr


    ;
    ; Calculate checksum of RCI Entry
    ;
    ; call rciCalChecksum

    
    clc
    jmp     put_done


scan_next:

    ;
    ; Prepare for next scan
    ;
    add     bx, RCI_ENTRY_BOUND
    cmp     bx, RCI_OFFSET_END
    jnz     scan


    debug_print_onlystr 'Cannot Find RCI Entry'
    stc


put_done:


    pop     es
    pop     cx
    pop     bx
    pop     eax


    ret

rciPutEntry ENDP
ENDIF


_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 STACK 'STACK'
align 4


PSP         DW      0
version     DB      13, 10, 'rcitool version 0.1 (C) 2007, Merck Hung', 13, 10
usage       DB      'Usage: rcitool', 13, 10, 13, 10, 24h


rcioff      DW      0
rciadd      DD      0
norci       DB      'Cannot Find RCI Entry in address range: 000F0000h ~ 000FFFF0h', 13, 10, 24h


;
; RCI Entry
;
re          DB      'Remote Configuration Interface (RCI)', 13, 10
            DB      '====================================================================', 13, 10
re0         DB      'RCI Entry at Address: ????????h', 13, 10
re1         DB      'RCI_ANCHOR:  ????????h', 13, 10
re2         DB      'RCIEP_LEN:   ??h', 13, 10
re3         DB      'RCIEP_CHKSM: ??h', 13, 10
re4         DB      'RCIEP_VER:   ??h', 13, 10
re5         DB      'RCI_ADDR:    ????????h', 13, 10, 13, 10, 24h


;
; RCI Table Type 0
;
ty0         DB      'Type 0: RCI Table Global Header', 13, 10
            DB      '====================================================================', 13, 10
ty00        DB      'TYPE:              ??h', 13, 10
ty01        DB      'LENGTH:            ????h', 13, 10
ty02        DB      'RCI_SIGNATURE:     ????????h', 13, 10
ty03        DB      'CHANGE_FLG:        ????????h', 13, 10
ty04        DB      'ERR_CODE:          ????????h', 13, 10
ty05        DB      'RCI_MAJ_REV:       ??h', 13, 10
ty06        DB      'RCI_MIN_REV:       ??h', 13, 10
ty07        DB      'STRUCS_NUM:        ????h', 13, 10
ty08        DB      'RCI_LEN:           ????????h', 13, 10
ty09        DB      'RCI_CHKSM:         ????h', 13, 10, 13, 10, 24h


;
; RCI Table Type 1
;
ty1         DB      'Type 1: Dell Extended BBS Structure', 13, 10
            DB      '====================================================================', 13, 10
ty10        DB      'TYPE:              ??h', 13, 10
ty11        DB      'LENGTH:            ????h', 13, 10
ty12        DB      'CHKSM:             ????h', 13, 10
ty13        DB      'MODIFIED_FLGS:     ????????h', 13, 10
ty14        DB      'BBS_VER:           ????h', 13, 10
ty15        DB      'IPL_NUM:           ??h', 13, 10
ty16        DB      'MAX_IPL_NUM:       ??h', 13, 10
ty17        DB      'IPL_ENTRY_SIZE:    ??h', 13, 10
ty18        DB      'BCV_NUM:           ??h', 13, 10
ty19        DB      'MAX_BCV_NUM:       ??h', 13, 10
ty110       DB      'BCV_ENTRY_SIZE:    ??h', 13, 10
ty111       DB      'EXT_ENTRY_SIZE:    ??h', 13, 10
ty112       DB      'ONESHOT_DEV:       ????h', 13, 10, 13, 10, 24h


;
; RCI Table Type 2
;
ty2         DB      'Type 2: Passwords Structure', 13, 10
            DB      '====================================================================', 13, 10
ty20        DB      'TYPE:              ??h', 13, 10
ty21        DB      'LENGTH:            ????h', 13, 10
ty22        DB      'CHKSM:             ????h', 13, 10
ty23        DB      'MODIFIED_FLGS:     ????????h', 13, 10
ty24        DB      'USR_PWD_MAX:       ??h', 13, 10
ty25        DB      'USR_PWD_ATT:       ????h', 13, 10
ty26        DB      'USE_PWD_CHKSM:     ??h', 13, 10
ty27        DB      'ADMIN_PWD_MAX:     ??h', 13, 10
ty28        DB      'ADMIN_PWD_ATT:     ????h', 13, 10
ty29        DB      'ADMIN_PWD_CHKSM:   ??h', 13, 10, 13, 10, 24h


;
; RCI Table Type 3
;
ty3         DB      'Type 3: Front Panel LCD Strings Structure', 13, 10
            DB      '====================================================================', 13, 10
ty30        DB      'TYPE:              ??h', 13, 10
ty31        DB      'LENGTH:            ????h', 13, 10
ty32        DB      'CHKSM:             ????h', 13, 10
ty33        DB      'MODIFIED_FLGS:     ????????h', 13, 10
ty34        DB      'LCD_STR1_MAX:      ??h', 13, 10
ty35        DB      'LCD_STR1_CHKSM:    ??h', 13, 10
ty36        DB      'LCD_STR2_MAX:      ??h', 13, 10
ty37        DB      'LCD_STR2_CHKSM:    ??h', 13, 10, 13, 10, 24h


;
; RCI Table Type 4
;
ty4         DB      'Type 4: CMOS Default Values Structure', 13, 10
            DB      '====================================================================', 13, 10
ty40        DB      'TYPE:                      ??h', 13, 10
ty41        DB      'LENGTH:                    ????h', 13, 10
ty42        DB      'CHKSM:                     ????h', 13, 10
ty43        DB      'MODIFIED_FLGS:             ????????h', 13, 10
ty44        DB      'CMOS_DEF_TABLES_COUNT:     ??h', 13, 10
ty45        DB      'CHKSM_RANGE_ENTRY_SIZE:    ??h', 13, 10
ty46        DB      'NUM_CHKSM_RANGES:          ??h', 13, 10
ty47        DB      'CMOS_CLR_ENTRY_SIZE:       ??h', 13, 10
ty48        DB      'NUM_CLR_RANGES:            ??h', 13, 10, 13, 10, 24h



_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     64 DUP(0)

STACK ENDS


    END MAIN


