;
; libhdd.asm -- Debug Library Routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE include\routine.inc
INCLUDE include\mroutine.inc
INCLUDE include\mdebug.inc
INCLUDE include\hdd.inc



IFDEF DEBUG
routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
@CurSeg ENDS


libdbg SEGMENT USE16 PUBLIC

    EXTERN DbgDumpRegisters:FAR
    EXTERN DbgDumpMemory:FAR
@CurSeg ENDS
ENDIF



;------------------------------------------------------------------------------
; libhdd segment
;
LIBHDD SEGMENT USE16 PUBLIC



;##############################################################################
; HddExtRead -- Read Disk using Extended Read
;
; Input:
;   ES:DI   -- Destination Buffer
;   AH      -- Drive Number
;   AL      -- Number of Sectors
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Output:
;   None
;
; Modified:
;   None
;
HddExtRead PROC FAR PUBLIC


    ; Save Registers
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
    push    ds


    ; Drive Number
    mov     dl, ah


    ; Prepare Data Structure
    mov     cs:DAP.PacketSize, Sizeof_DiskAddrPacket16
    mov     cs:DAP.NrSectors, al
    mov     cs:DAP.PacketOff, di
    mov     cs:DAP.PacketSeg, es
    mov     cs:DAP.LBALow, ebx
    mov     cs:DAP.LBAHigh, ecx


    ; Use Extended Read
    mov     ah, HDD_EXT_READ


    ; Setup Packet Location
    push    SEG DAP
    pop     ds
    mov     si, OFFSET DAP


    ; Issue INT 13h
    int     13h


    ; Restore Registers
    pop     ds
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax


    ret

HddExtRead ENDP



;##############################################################################
; HddExtWrite -- Write Disk using Extended Write
;
; Input:
;   ES:DI   -- Destination Buffer
;   AH      -- Drive Number
;   AL      -- Number of Sectors
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Output:
;   None
;
; Modified:
;   None
;
HddExtWrite PROC FAR PUBLIC


    ; Save Registers
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
    push    ds


    ; Drive Number
    mov     dl, ah


    ; Prepare Data Structure
    mov     cs:DAP.PacketSize, Sizeof_DiskAddrPacket16
    mov     cs:DAP.NrSectors, al
    mov     cs:DAP.PacketOff, di
    mov     cs:DAP.PacketSeg, es
    mov     cs:DAP.LBALow, ebx
    mov     cs:DAP.LBAHigh, ecx


    ; Use Extended Write
    mov     ah, HDD_EXT_WRITE
    xor     al, al


    ; Setup Packet Location
    push    SEG DAP
    pop     ds
    mov     si, OFFSET DAP


    ; Issue INT 13h
    int     13h


    ; Restore Registers
    pop     ds
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax


    ret

HddExtWrite ENDP



;##############################################################################
; HddExtReadFlat -- Flat Mode Read Disk using Extended Read
;
; Input:
;   EDI     -- Destination Buffer
;   AH      -- Drive Number
;   AL      -- Number of Sectors
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Output:
;   None
;
; Modified:
;   None
;
HddExtReadFlat PROC FAR PUBLIC


    ; Save Registers
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
    push    ds


    ; Drive Number
    mov     dl, ah


    ; Prepare Data Structure
    mov     cs:DAP.PacketSize, Sizeof_DiskAddrPacket
    mov     cs:DAP.NrSectors, al
    mov     cs:DAP.PacketOff, 0FFFFh
    mov     cs:DAP.PacketSeg, 0FFFFh
    mov     cs:DAP.LBALow, ebx
    mov     cs:DAP.LBAHigh, ecx
    mov     cs:DAP.FlatAddrLow, edi
    mov     cs:DAP.FlatAddrHigh, 0


    ; Use Extended Read
    mov     ah, HDD_EXT_READ


    ; Setup Packet Location
    push    SEG DAP
    pop     ds
    mov     si, OFFSET DAP


    ; Issue INT 13h
    int     13h


    ; Restore Registers
    pop     ds
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax


    ret

HddExtReadFlat ENDP



;##############################################################################
; HddExtWriteFlat -- Flat Mode Write Disk using Extended Write
;
; Input:
;   EDI     -- Destination Buffer
;   AH      -- Drive Number
;   AL      -- Number of Sectors
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Output:
;   None
;
; Modified:
;   None
;
HddExtWriteFlat PROC FAR PUBLIC


    ; Save Registers
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
    push    ds


    ; Drive Number
    mov     dl, ah


    ; Prepare Data Structure
    mov     cs:DAP.PacketSize, Sizeof_DiskAddrPacket
    mov     cs:DAP.NrSectors, al
    mov     cs:DAP.PacketOff, 0FFFFh
    mov     cs:DAP.PacketSeg, 0FFFFh
    mov     cs:DAP.LBALow, ebx
    mov     cs:DAP.LBAHigh, ecx
    mov     cs:DAP.FlatAddrLow, edi
    mov     cs:DAP.FlatAddrHigh, 0


    ; Use Extended Write
    mov     ah, HDD_EXT_WRITE
    xor     al, al


    ; Setup Packet Location
    push    SEG DAP
    pop     ds
    mov     si, OFFSET DAP


    ; Issue INT 13h
    int     13h


    ; Restore Registers
    pop     ds
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax


    ret

HddExtWriteFlat ENDP



;##############################################################################
; HddRead -- Read Disk
;
; Input:
;   ES:DI   -- Destination Buffer
;   AH      -- Drive Number
;   AL      -- Number of Sectors
;   BX      -- Start Sector Number
;
; Output:
;   None
;
; Modified:
;   None
;
HddRead PROC FAR PUBLIC


    ; Save Registers
    push    ax
    push    bx
    push    cx
    push    dx
    push    di


    ; Head Number
    xor     dh, dh


    ; Drive Number
    mov     dl, ah


    ; Use Read
    mov     ah, HDD_READ


    ; Sector Number to Read
    mov     cx, bx


    ; Setup Buffer
    mov     bx, di


    ; Issue INT 13h
    int     13h


    ; Restore Registers
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax


    ret

HddRead ENDP



;##############################################################################
; HddWrite -- Write Disk
;
; Input:
;   ES:DI   -- Destination Buffer
;   AH      -- Drive Number
;   AL      -- Number of Sectors
;   BX      -- Start Sector Number
;
; Output:
;   None
;
; Modified:
;   None
;
HddWrite PROC FAR PUBLIC


    ; Save Registers
    push    ax
    push    bx
    push    cx
    push    dx
    push    di


    ; Head Number
    xor     dh, dh


    ; Drive Number
    mov     dl, ah


    ; Use Read
    mov     ah, HDD_WRITE


    ; Sector Number to Read
    mov     cx, bx


    ; Setup Buffer
    mov     bx, di


    ; Issue INT 13h
    int     13h


    ; Restore Registers
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax


    ret

HddWrite ENDP



;##############################################################################
; HddInitVariables -- Initialize CHS to LBA Variables
;
; Input:
;   DL      -- Drive Number
;
; Output:
;   AX      -- Max Cylinder Number
;   BL      -- Max Sector Number
;   CH      -- Max Head Number
;
; Modified:
;   All possible
;
HddInitVariables PROC FAR PUBLIC


    ; Read Drive Parameters
    mov     ah, 08h
    int     13h


    ; Save MaxHead
    mov     cs:MaxHead, dh


    ; Save MaxSector
    mov     cs:MaxSector, cl
    and     cs:MaxSector, HDD_MAX_SECTOR


    ; Save MaxCylinder
    xor     ax, ax
    and     cl, NOT HDD_MAX_SECTOR          ; AND 1100 0000

    mov     ah, cl                          ; ??00 = CL = AH
    shr     ax, 2                           ; 00?? 0000
    mov     al, ch                          ; 00?? ????

    mov     cs:MaxCylinder, ax


    ; Fill in Result
    mov     bl, cs:MaxSector


    ret

HddInitVariables ENDP



;##############################################################################
; HddCheckCHSRange -- Check if the CHS in the valid range
;
; Input:
;   CH      -- Cylinder Number (Low Part)
;   CL      -- Sector Number (High Two Bits are High Part of Cylinder Number)
;   DH      -- Head Number
;
; Output:
;   Carry   -- 1: Out of Range
;           -- 0: In the Range
;
; Modified:
;   None
;
HddCheckCHSRange PROC FAR PUBLIC


    push    ax
    push    cx
    push    dx


    ; Check Head Number
    cmp     dh, cs:MaxHead
    ja      OutOfRange


    ; Check Sector Number
    mov     al, cl
    and     al, HDD_MAX_SECTOR
    cmp     al, cs:MaxSector
    ja      OutOfRange 


    ; Check Cylinder Number
    mov     ah, cl
    shr     ah, 6
    mov     al, ch
    and     ax, HDD_MAX_CYLINDER
    cmp     ax, cs:MaxCylinder
    ja      OutOfRange


    ; Carry = 0
    clc
    jmp     Exit


OutOfRange:


    ; Carry = 1
    stc


Exit:
    

    pop     dx
    pop     cx
    pop     ax


    ret

HddCheckCHSRange ENDP



;##############################################################################
; HddOrigCHSToLBA -- Translate CHS to LBA for standard CHS input
;
; Input:
;   CH      -- Head Number
;   CL      -- Sector Number (High Two Bits are High Part of Cylinder Number)
;   DH      -- Cylinder Number (Low Part)
;
; Output:
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Modified:
;   EBX
;   ECX
;
HddOrigCHSToLBA PROC FAR PUBLIC


    push    ax


    ; Manipulate Sector Number
    mov     bl, cl
    and     bl, HDD_MAX_SECTOR


    ; Check Cylinder Number
    mov     ah, cl
    shr     ah, 6
    mov     al, ch
    and     ax, HDD_MAX_CYLINDER


    ; Do Translate
    call    HddCHSToLBA


    pop     ax


    ret

HddOrigCHSToLBA ENDP



;##############################################################################
; HddCHSToLBA -- Translate CHS to LBA
;
; Input:
;   AX      -- Cylinder Number
;   BL      -- Sector Number
;   DH      -- Head Number
;
; Output:
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Modified:
;   EBX
;   ECX
;
HddCHSToLBA PROC FAR PUBLIC


    push    eax
    push    edx


    ; Mask maximun values
    and     ax, HDD_MAX_CYLINDER    ; Current Cylinder in AX
    and     bl, HDD_MAX_SECTOR      ; Current Sector in BL
    mov     bh, dh                  ; Current Head in BH


IFDEF DEBUG
    push    eax
    debug_print_str 'CurrCylinder'

    xor     eax, eax
    mov     al, dh
    debug_print_str 'CurrHead'

    xor     eax, eax
    mov     al, bl
    debug_print_str 'CurrSector'
    pop     eax
ENDIF


    ; (Cylinder * (MaxHead + 1)) + Head = EAX
    xor     dx, dx                  ; Zero DX
    mov     dl, cs:MaxHead          ; dl = MaxHead
    inc     dl                      ; dl = MaxHead + 1
    mul     dx                      ; * (MaxHead + 1) = DX:AX

    xchg    ax, dx
    shl     eax, 16
    xchg    ax, dx                  ; EAX = DX:AX
    
    xor     edx, edx                ;
    mov     dl, bh                  ;
    add     eax, edx                ; + Head


    ; (Result * MaxSector) + Sector - 1 = EDX:EAX
    xor     edx, edx
    mov     dl, cs:MaxSector        ;
    mul     edx                     ; * MaxSector = EDX:EAX
    
    and     ebx, 0FFh               ; Current Sector in bl
    dec     bl                      ; (Current Sector - 1) in bl


    ; Perform 64bit Plus Operation  : ECX:EBX + EDX:EAX
    xor     ecx, ecx                ; Zero ECX, EBX = (Sector - 1)

    add     ebx, eax                ; Low  Part
    adc     ecx, edx                ; High Part


    pop     edx
    pop     eax


    ret

HddCHSToLBA ENDP



;##############################################################################
; HddLBAToCHS -- Translate LBA to CHS
;
; Input:
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Output:
;   CH      -- Cylinder Number (Low)
;   CL      -- Sector Number and High two bits of Cylinder Number
;   DH      -- Head Number
;
; Modified:
;   ECX
;   EDX
;
HddLBAToCHS PROC FAR PUBLIC


    push    eax
    push    ebx


    ; LBA + 1 = EDX:EAX
    mov     eax, 1
    xor     edx, edx

    add     eax, ebx
    adc     edx, ecx


    ; Calculate ((MaxHead + 1) * MaxSector) = EBX
    push    eax
    xor     eax, eax

    mov     al, cs:MaxHead      ; MaxHead
    inc     al                  ; (MaxHead + 1)
    mov     ah, cs:MaxSector    ; MaxSector
    mul     ah                  ; Result in AX

    movzx   ebx, ax             ; Expand Zero to EBX
    pop     eax


    ; (LBA + 1) / ((MaxHead + 1) * MaxSector)
    div     ebx


    ; Save Cylinder Number in AX (Quotient)
    push    ax


    ; Remainder is remain Heads (DX:AX / BX)
    mov     ax, dx
    xor     dx, dx
    movzx   bx, cs:MaxSector
    div     bx


    ; Restore Cylinder in CX
    pop     cx


    ; Handle Cylinder Result
    and     cx, HDD_MAX_CYLINDER
    xchg    ch, cl
    shl     cl, 6


    ; Handle Sector Result
    and     dl, HDD_MAX_SECTOR
    or      cl, dl


    ; Handle Head Result
    mov     dh, al


    pop     ebx
    pop     eax


    ret

HddLBAToCHS ENDP




;------------------------------------------------------------------------------
; Start of Data Region
;
DAP         DiskAddrPacket      {}

MaxCylinder     DW      0
MaxHead         DB      0
MaxSector       DB      0
;
; End of Data Region
;------------------------------------------------------------------------------



LIBHDD ENDS


    END


