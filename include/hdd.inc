;
; hdd.inc -- Header file related to Hard Drive routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;



HDD_READ            EQU     02h
HDD_WRITE           EQU     03h
HDD_READ_LONG       EQU     0Ah
HDD_WRITE_LONG      EQU     0Bh

HDD_EXT_READ        EQU     42h
HDD_EXT_WRITE       EQU     43h

HDD_FIRST           EQU     80h
HDD_SECOND          EQU     81h

HDD_MBR_SIGNATURE   EQU     0AA55h
HDD_SZ_SECTOR       EQU     512

HDD_MAX_CYLINDER    EQU     03FFh
HDD_MAX_HEAD        EQU     0FFh
HDD_MAX_SECTOR      EQU     03Fh



DiskAddrPacket STRUCT

    PacketSize      DB      0

    Reserved0       DB      0

    NrSectors       DB      0

    Reserved1       DB      0

    PacketOff       DW      0
    PacketSeg       DW      0

    LBALow          DD      0
    LBAHigh         DD      0

    FlatAddrLow     DD      0
    FlatAddrHigh    DD      0

DiskAddrPacket ENDS
Sizeof_DiskAddrPacket   EQU     SIZEOF DiskAddrPacket
Sizeof_DiskAddrPacket16 EQU     Sizeof_DiskAddrPacket - 8



PartitionTable STRUCT

    BootFlag        DB      0
    StartHead       DB      0
    StartCylinder   DW      0
    PartType        DB      0
    EndHead         DB      0
    EndCylinder     DW      0
    StartSector     DD      0
    NrSectors       DD      0

PartitionTable ENDS
Sizeof_PartitionTable   EQU     SIZEOF PartitionTable




;##############################################################################
; HddExtReadM -- Read Disk using Exteneded Read
;
; Input:
;   DRIVE   -- Drive Number (C: 80h)
;   SECLOW  -- Start Sector (Low  Part)
;   SECHIGH -- Start Sector (High Part)
;   SECTORS -- Number of Sectors
;   BUF     -- Destination Buffer
;
; Output:
;   BUF     -- Data placed
;
; Modified:
;   None
;
HddExtReadM MACRO DRIVE, SECLOW, SECHIGH, SECTORS, BUF

    push    ax
    push    ebx
    push    ecx
    push    di
    push    es


    ; Setup Buffer
    push    SEG BUF
    pop     es
    mov     di, OFFSET BUF


    ; Drive Number
    mov     ah, DRIVE


    ; Number of Sectors
    mov     al, SECTORS


    ; Start Sector Number
    mov     ebx, SECLOW
    mov     ecx, SECHIGH


    ; Read Disk
    call    HddExtRead


    pop     es
    pop     di
    pop     ecx
    pop     ebx
    pop     ax

ENDM



;##############################################################################
; HddExtWriteM -- Write Disk using Exteneded Write
;
; Input:
;   DRIVE   -- Drive Number (C: 80h)
;   SECLOW  -- Start Sector (Low  Part)
;   SECHIGH -- Start Sector (High Part)
;   SECTORS -- Number of Sectors
;   BUF     -- Destination Buffer
;
; Output:
;   None
;
; Modified:
;   None
;
HddExtWriteM MACRO DRIVE, SECLOW, SECHIGH, SECTORS, BUF

    push    ax
    push    ebx
    push    ecx
    push    di
    push    es


    ; Setup Buffer
    push    SEG BUF
    pop     es
    mov     di, OFFSET BUF


    ; Drive Number
    mov     ah, DRIVE


    ; Number of Sectors
    mov     al, SECTORS


    ; Start Sector Number
    mov     ebx, SECLOW
    mov     ecx, SECHIGH


    ; Read Disk
    call    HddExtWrite


    pop     es
    pop     di
    pop     ecx
    pop     ebx
    pop     ax

ENDM



;##############################################################################
; HddReadM -- Read Disk
;
; Input:
;   DRIVE   -- Drive Number (C: 80h)
;   SECNO   -- Start Sector
;   SECTORS -- Number of Sectors
;   BUF     -- Destination Buffer
;
; Output:
;   BUF     -- Data placed
;
; Modified:
;   None
;
HddReadM MACRO DRIVE, SECNO, SECTORS, BUF

    push    ax
    push    bx
    push    cx
    push    di
    push    es


    ; Setup Buffer
    push    SEG BUF
    pop     es
    mov     di, OFFSET BUF


    ; Drive Number
    mov     ah, DRIVE


    ; Number of Sectors
    mov     al, SECTORS


    ; Start Sector Number
    mov     bx, (SECNO + 1)


    ; Read Disk
    call    HddRead


    pop     es
    pop     di
    pop     cx
    pop     bx
    pop     ax

ENDM



;##############################################################################
; HddWriteM -- Write Disk
;
; Input:
;   DRIVE   -- Drive Number (C: 80h)
;   SECNO   -- Start Sector
;   SECTORS -- Number of Sectors
;   BUF     -- Destination Buffer
;
; Output:
;   None
;
; Modified:
;   None
;
HddWriteM MACRO DRIVE, SECNO, SECTORS, BUF

    push    ax
    push    bx
    push    cx
    push    di
    push    es


    ; Setup Buffer
    push    SEG BUF
    pop     es
    mov     di, OFFSET BUF


    ; Drive Number
    mov     ah, DRIVE


    ; Number of Sectors
    mov     al, SECTORS


    ; Start Sector Number
    mov     bx, (SECNO + 1)


    ; Write Disk
    call    HddWrite


    pop     es
    pop     di
    pop     cx
    pop     bx
    pop     ax

ENDM



;##############################################################################
; HddReadNativeM -- Read Disk by CHS
;
; Input:
;   DRIVE   -- Drive Number (C: 80h)
;   CYLINDER-- Cylinder Number
;   HEAD    -- Head Number
;   SECTOR  -- Sector Number
;
; Output:
;   EBX     -- Start Sector Number (Low  Part)
;   ECX     -- Start Sector Number (High Part)
;
; Modified:
;   EBX
;   ECX
;
HddCHSToLBAM MACRO DRIVE, CYLINDER, HEAD, SECTOR


    push    dx


    ; Fill in Variavles
    mov     ax, CYLINDER
    mov     bl, SECTOR
    mov     dh, HEAD
    mov     dl, DRIVE


    ; Do Translate
    call    HddCHSToLBA


    pop     dx


ENDM



;##############################################################################
; HddReadNativeM -- Read Disk by CHS
;
; Input:
;   DRIVE   -- Drive Number (C: 80h)
;   CYLINDER-- Cylinder Number
;   HEAD    -- Head Number
;   SECTOR  -- Sector Number
;   BUF     -- Destination Buffer
;   NRSECS  -- Number of Sectors
;
; Output:
;   BUF     -- Data placed
;
; Modified:
;   None
;
HddReadNativeM MACRO DRIVE, CYLINDER, HEAD, SECTOR, BUF, NRSECS


    pushad
    push    es


    ; Setup Buffer
    mov     ax, SEG BUF
    mov     es, ax
    mov     bx, OFFSET BUF


    ; Fill in Parameters
    mov     cx, CYLINDER
    xchg    ch, cl
    shl     cl, 6

    or      cl, SECTOR

    mov     dh, HEAD
    mov     dl, DRIVE

    mov     al, NRSECS

    mov     ah, HDD_READ


    ; Issue INT 13h
    int     13h


    pop     es
    popad


ENDM



;##############################################################################
; HddCheckCHSRangeM -- Check if the CHS in the valid range
;
; Input:
;   CYLINDER-- Cylinder Number
;   HEAD    -- Head Number
;   SECTOR  -- Sector Number
;
; Output:
;   None
;
; Modified:
;   None
;
HddCheckCHSRangeM MACRO CYLINDER, HEAD, SECTOR


    push    cx
    push    dx


    ; Cylinder
    mov     cx, CYLINDER
    xchg    ch, cl
    shl     cl, 6

    ; Sector
    or      cl, SECTOR

    ; Head
    mov     dh, HEAD

    
    ; Do check
    call    HddCheckCHSRange
 

    pop     dx
    pop     cx


ENDM



