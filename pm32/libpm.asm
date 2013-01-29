;
; libpm.asm -- protected mode routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a library for protected mode operation
;
.586P


INCLUDE ..\include\pm.inc



;------------------------------------------------------------------------------
; libpm16 16bit code segment
;
LIBPM16 SEGMENT USE16 PUBLIC 'CODE'



;##############################################################################
; PM32ExecuteCode -- go to protected mode
;
; Input:
;   EDI -- Linear address of 32 bit code to execute
;
; Output:
;   None
;
; Modified:
;   All possible
;
PM32ExecuteCode PROC FAR PUBLIC


    ; Save all registers
    pushfd
    pushad
    push    ds
    push    es
    push    fs
    push    gs


    ; Save Custom 32bit Code Entry
    mov     bx, OFFSET SAVE_32CODE
    mov     cs:[bx], edi


    ; Save SS, SP
    mov     bx, OFFSET SAVE_SS
    mov     ax, ss
    mov     cs:[bx], ax

    mov     bx, OFFSET SAVE_SP
    mov     cs:[bx], sp


    ;--------------------------------------------------------------------------
    ; Setup protected mode
    ;--------------------------------------------------------------------------


    ; Convert GDT base physical address to linear one
    xor     eax, eax
    mov     ax, SEG GDT_TABLE
    shl     eax, 4
    add     eax, OFFSET GDT_TABLE


    ; Write GDT pointer
    mov     DWORD PTR cs:GDT_POINTER+2, eax


    ; Load GDT pointer
    lgdt    FWORD PTR GDT_POINTER


    ; Calculate 32bit entry offset
    xor     eax, eax
    mov     ax, SEG PM32Entry
    shl     eax, 4
    add     eax, OFFSET PM32Entry


    ; Write to jmpi instruction
    mov     DWORD PTR cs:ENTRY32_LINEAR_ADDR, eax


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


    ; FAR Jump instruction (jmpi) to 32bit code segment
    DB      66h, 0EAh

ENTRY32_LINEAR_ADDR:
    DD      00000000h
    DW      PM_CODE_SEG


    ; Should not be here
    jmp     $


    ; Save ss, sp, edi
SAVE_SS::
    DW      0

SAVE_SP::
    DW      0

SAVE_32CODE::
    DD      0


PM32ExecuteCode ENDP



;##############################################################################
; ExitProtectedMode -- exit protected mode and back to real mode
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
ExitProtectedMode PROC FAR PUBLIC


    ; Load 64k data segment
    mov     ax, REAL_DATA_SEG
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     ss, ax


    ; Disable protected mode
    mov     eax, cr0
    and     eax, NOT 01h
    mov     cr0, eax


    ; Far jump to 16bit code
    DB      0EAh
    DW      OFFSET @f
    DW      SEG @f
@@:


    ; Restore SS, SP
    mov     bx, OFFSET SAVE_SS
    mov     ax, cs:[bx]
    mov     ss, ax

    mov     bx, OFFSET SAVE_SP
    mov     sp, cs:[bx]


    ; Restore all registers
    pop     gs
    pop     fs
    pop     es
    pop     ds
    popad
    popfd


    ; Return to main procedure
    ret

ExitProtectedMode ENDP



;##############################################################################
; Globel Segment descriptor
;
align 16
GDT_TABLE:


    ; NULL segment
    DW  0, 0, 0, 0


    ; 32bit 4G Code segment, exec/read
PM_CODE_SEG         EQU     $ - GDT_TABLE
    DW  0FFFFh
    DW  0
    DW  9A00h
    DW  00CFh


    ; 32bit 4G Data segment, read/write
PM_DATA_SEG         EQU     $ - GDT_TABLE
    DW  0FFFFh
    DW  0
    DW  9200h
    DW  00CFh


    ; 16bit 64k Code segment, exec/read
REAL_CODE_SEG       EQU     $ - GDT_TABLE
    DW  0FFFFh
    DW  0
    DW  9A00h
    DW  0


    ; 16bit 64k Data segment, read/write
REAL_DATA_SEG       EQU     $ - GDT_TABLE
    DW  0FFFFh
    DW  0
    DW  9200h
    DW  0


GDT_SIZE            EQU     $ - GDT_TABLE


;
; GDT Pointer
;
GDT_POINTER:
    DW  GDT_SIZE - 1
    DD  0               ; GDT base address


LIBPM16 ENDS



;------------------------------------------------------------------------------
; libpm32 32bit protected mode code segment
;
LIBPM32 SEGMENT USE32 PUBLIC 'CODE'



;##############################################################################
; PM32Entry -- Protected Mode Program Entry
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
PM32Entry PROC FAR PUBLIC


    ; Setup segments
    mov     ax, PM_DATA_SEG
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     ss, ax


    ; Initialize new stack pointer
    mov     esp, (PM32_STACK_BASE + PM32_STACK_SIZE)


IFDEF PSE_SUPPORT


    ; Initialize PDE for PSE
    call    InitPageforPSE


    ; Enable PSE bit
    call    EnablePSE


ELSE    ; IFDEF PSE_SUPPORT


    ; Initialize PDE and PTE for memory below 1MB
    call    InitPageBelow1MB


ENDIF   ; IFDEF PSE_SUPPORT


    ; Enable Paging
    call    EnablePaging


    ; Calculate Linear address of CUSTOM_32CODE
    xor     edi, edi
    mov     di, SEG CUSTOM_32CODE
    shl     edi, 4
    add     edi, OFFSET CUSTOM_32CODE


    ; Get custom 32 bit code entry address
    xor     ebx, ebx
    mov     bx, SEG SAVE_32CODE
    shl     ebx, 4
    add     ebx, OFFSET SAVE_32CODE
    mov     eax, ds:[ebx]


    ; Write to Instruction
    mov     DWORD PTR ds:[edi], eax


    ; Jump to custom 32 bit code
    DB      0EAh
CUSTOM_32CODE:
    DD      0
    DW      PM_CODE_SEG


    ; Public return address
    PUBLIC CommonPM32Return
CommonPM32Return::


    ; Exit Protected Mode
    jmp     PM32Exit


PM32Entry ENDP



;##############################################################################
; PM32Exit -- Protected Mode Exit Entry
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
PM32Exit PROC NEAR PUBLIC


    ; Disable Paging
    call    DisablePaging


IFDEF PSE_SUPPORT
    ; Disable PSE
    call    DisablePSE
ENDIF   ; IFDEF PSE_SUPPORT


    ; Calculate linear address of EXIT16_LINEAR_ADDR
    xor     ebx, ebx
    mov     bx, SEG EXIT16_LINEAR_ADDR
    shl     ebx, 4
    add     ebx, OFFSET EXIT16_LINEAR_ADDR


    ; Calculate and write address of 16bit code
    xor     eax, eax
    mov     ax, SEG ExitProtectedMode
    shl     eax, 4
    add     eax, OFFSET ExitProtectedMode


    ; Write linear address of 16bit code to instruction
    mov     [ebx], eax


    ; Far jump to load 64k Code Segment
    DB      0EAh
EXIT16_LINEAR_ADDR:
    DD      0
    DW      REAL_CODE_SEG
    

    ret


PM32Exit ENDP



IFDEF PSE_SUPPORT
;##############################################################################
; InitPageforPSE -- Initialize PDE & PTE for PSE support
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
InitPageforPSE PROC NEAR PUBLIC


    ;
    ; Base Address: EAX = 0 ~ 4MB
    ; Location:     EDI = 0020_0000h
    ;
    xor     edx, edx
    xor     eax, eax
    mov     edi, PGDIR_BADDR
    call    UpdatePDEforPSE


    ;
    ; Base Address: EDX:EAX = 1_0000_0000h ~ 1_0040_0000h
    ; Location:     EDI     = 0020_0004h
    ;
    mov     edx, 1
    mov     eax, 0000000h
    call    UpdatePDEforPSE


    ret

InitPageforPSE ENDP



;##############################################################################
; UpdatePDEforPSE -- Update PDE for PSE support
;
; Input :
;   EAX -- Base Address
;   DL  -- Bit 0 to 3 contain upper bits of PSE 36bit address
;   EDI -- Destination address of PDE
;
; Output:
;   EAX -- Next page base address
;   DL  -- Bit 0 to 3 contain upper bits of PSE 36bit address
;   EDI -- Point to the end of current PDE
;
; Modified:
;   EAX
;   EDX
;   EDI
;
UpdatePDEforPSE PROC NEAR PUBLIC


    ; Write flags (Imply that clear memory by the way)
    mov     DWORD PTR [edi], P_SUP_WT_RW_4M


    ; Write lower portion of base address
    and     eax, 0FFFFF000h
    or      DWORD PTR [edi], eax


    ; Write upper portion of base address
    and     edx, 0Fh
    shl     edx, 13
    or      DWORD PTR [edi], edx


    ; Move to end of PDE
    add     edi, 4


    ; Plus 4MB to next PDE
    add     eax, 400000h


    ret

UpdatePDEforPSE ENDP



ELSE    ; IFDEF PSE_SUPPORT



;##############################################################################
; InitPageBelow1MB -- Initialize PDE & PTE to memory below 1MB
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
InitPageBelow1MB PROC NEAR PUBLIC


    ; Write PTE
    mov     eax, PGDIR_BADDR + 4096    ; First PTE Addr = current + 4KB
    mov     edi, PGDIR_BADDR
    call    UpdatePDEPTE


    ; PGTBL_NUMS * PTE(4K) == 768 * 4Kb == 3MB
    mov     cx, PGTBL_NUMS
    
    ; Base Address: Start from 0 ~ 2MB
    ; EDI = PGDIR_BADDR + 4096
    xor     eax, eax
    mov     edi, PGDIR_BADDR + 4096

WrPTE:

    call    UpdatePDEPTE
    dec     cx
    jnz     WrPTE


    mov     eax, 800000h
    call    UpdatePDEPTE


    ret

InitPageBelow1MB ENDP



;##############################################################################
; UpdatePDEPTE -- Update PDE or PTE
;
; Input :
;   EAX -- Base Address
;   EDI -- Destination address of PDE or PTE
;
; Output:
;   EAX -- Next page base address
;   EDI -- Point to the end of current PDE or PTE
;
; Modified:
;   EAX
;   EDI
;
UpdatePDEPTE PROC NEAR PUBLIC


    ; Write flags (Imply that clear memory by the way)
    mov     DWORD PTR [edi], P_SUP_WT_RW_4K


    ; Write base address
    and     eax, 0FFFFF000h
    or      DWORD PTR [edi], eax


    ; Move to end of PDE or PTE
    add     edi, 4


    ; Plus 4KB to next page
    add     eax, 1000h


    ret

UpdatePDEPTE ENDP
ENDIF   ; IFDEF PSE_SUPPORT



;##############################################################################
; EnablePaging -- Enable paging
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CR0
;   CR3
;
EnablePaging PROC NEAR PUBLIC


    ; Set PTE Base
    mov     eax, PGDIR_BADDR
    mov     cr3, eax


    ; Enable paging
    mov     eax, cr0
    or      eax, 80000000h
    mov     cr0, eax


    ; Flush TLBs
    jmp     FTLB
FTLB:


    ret

EnablePaging ENDP



;##############################################################################
; DisablePaging -- Disable paging
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CR0
;   CR3
;
DisablePaging PROC NEAR PUBLIC


    ; Disable Paging
    mov     eax, cr0
    and     eax, NOT 80000000h
    mov     cr0, eax


    ; Flush TLB
    xor     eax, eax
    mov     cr3, eax


    ret

DisablePaging ENDP



IFDEF PSE_SUPPORT
;##############################################################################
; EnablePSE -- Enable PSE bit
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CR4
;
EnablePSE PROC NEAR PUBLIC


    ; Set Bit4 of CR4
    mov     eax, cr4
    or      eax, 10h
    mov     cr4, eax


    ret

EnablePSE ENDP



;##############################################################################
; DisablePSE -- Disable PSE bit
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CR4
;
DisablePSE PROC NEAR PUBLIC


    ; Clear Bit4 of CR4
    mov     eax, cr4
    and     eax, NOT 10h
    mov     cr4, eax


    ret

DisablePSE ENDP
ENDIF   ; IFDEF PSE_SUPPORT



LIBPM32 ENDS


    END


