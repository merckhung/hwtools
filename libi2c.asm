;
; libi2c.asm --  I2C library for x86 assembly
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of I2C routines for x86 assembly programming.
;
.586P


INCLUDE include\i2c.inc
INCLUDE include\pci.inc
INCLUDE include\routine.inc
INCLUDE include\mroutine.inc
INCLUDE include\mdebug.inc


;
; extern sun-routines
;
libpci SEGMENT USE16 PUBLIC

    EXTERN cal_pci_baseaddr:FAR
    EXTERN pci_read_config_byte:FAR
    EXTERN pci_write_config_byte:FAR
@CurSeg ENDS


routine SEGMENT USE16 PUBLIC

    EXTERN conv_push_ascii:FAR
@CurSeg ENDS



;------------------------------------------------------------------------------
; libi2c_data data segment
;
libi2c_data SEGMENT USE16 'DATA'


IFDEF DEBUG

smbus_pci_addr      db      'SMBus PCI Base Address : 0x????????', 13, 10, 24h
smbus_io_addr       db      'SMBus I/O Base Address : 0x????????', 13, 10, 24h
;                                                      27

i2c_bus_busy        db      'DEBUG: I2C Bus Busy', 13, 10, 24h
i2c_bus_failed      db      'DEBUG: I2C Bus Failed', 13, 10 ,24h
i2c_bus_col         db      'DEBUG: I2C Bus collision!', 13, 10, 24h
i2c_bus_err         db      'DEBUG: I2C Bus error!', 13, 10 ,24h
;

smbus_host_cfg      db      'DEBUG: SMBus Host Config Reg  : 0x??', 13, 10, 24h
;                                                             34

smbus_hst_enable    db      'DEBUG: SMBus Host Enable', 13, 10, 24h
smbus_hst_disable   db      'DEBUG: SMBUs Host Disable', 13, 10, 24h
;

smbus_smi_enable    db      'DEBUG: SMBus SMI# Enable', 13, 10, 24h
smbus_smi_disable   db      'DEBUG: SMBus SMI# Disable', 13, 10, 24h
;

smbus_i2c_enable    db      'DEBUG: SMBus I2C Enable', 13, 10, 24h
smbus_i2c_disable   db      'DEBUG: SMBus I2C Disable', 13, 10, 24h
;

i2c_bus_ready       db      'DEBUG: I2C Bus Ready', 13, 10 ,24h
i2c_bus_ok          db      'DEBUG: I2C Bus Ok', 13, 10, 24h
i2c_bus_nocol       db      'DEBUG: I2C Bus no collision', 13, 10, 24h
i2c_bus_noerr       db      'DEBUG: I2C Bus no error', 13, 10, 24h
;

ENDIF


sum_regs            db      'SMBus regs: STS=0x??, CNT=0x??, CMD=0x??, ADD=0x??, D0=0x??, D1=??', 13, 10, 24h
;                                             18        28        38        48       57     64


i2c_iobase          dw      0000h


@CurSeg ENDS


;------------------------------------------------------------------------------
; libi2c code segment
;
libi2c SEGMENT USE16 PUBLIC



;----------------------------------- PUBLIC -----------------------------------


;##############################################################################
; i2c_init_iobase -- Get I2C base address from register of motherboard chipset
;
; Input :
;   BH  = SMBus Bus number
;   BL  = SMBus Device number
;   CL  = SMBus Function number
;
; Output:
;   EAX = SMBus I/O Base Address(16-bit in AX)
;   i2c_iobase
;   Carry 0: false, 1: true
;
; Modified:
;   BX
;   CX
;
i2c_init_iobase PROC FAR PUBLIC


    push    bx
    push    cx


    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:libi2c_data, ES:libi2c_data

    mov     ax, libi2c_data
    mov     ds, ax
    mov     es, ax


    ;
    ; Get SMBus PCI Base Address
    ;
    call    cal_pci_baseaddr


    ;
    ; Print SMBus PCI Base Address
    ;
    debug_ascii_str smbus_pci_addr, 8, 27


    ;
    ; Get SMBus I/O port base address
    ;
    or      eax, 020h                   ; SMBus Base Address
    mov     dx, pci_ioaddr
    out     dx, eax                     ; Write PCI address

    xor     eax, eax
    mov     dx, pci_iodata
    in      eax, dx                     ; Read register


    ;
    ; Bit0 : Hardwired to 1 indicating that the SMB logic is I/O mapped.
    ;
    ; 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
    ; -----------------------------------------------
    ; |<------- Base Address ------->| <-- Rev --> ^^
    ;
    and     eax, not 01h
    mov     i2c_iobase, ax


    ;
    ; Print SMBus I/O Base Address
    ;
    debug_ascii_str smbus_io_addr, 8, 27


    ;
    ; Check IO base address
    ;
    cmp     ax, 0
    jnz     i2c_init_iobase_ok

    stc

i2c_init_iobase_ok:

    clc


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds

    pop     cx
    pop     bx

    ret

i2c_init_iobase ENDP



;##############################################################################
; i2c_pci_enable -- Enable I2C via PCI Host Configuration Register
;
; Input :
;   BH  = SMBus Bus number
;   BL  = SMBus Device number
;   CL  = SMBus Function number
;
; Output:
;   None
;
; Modified:
;   EAX
;   BX
;   CX
;   DX
;
i2c_pci_enable PROC FAR PUBLIC


    push    eax
    push    bx
    push    cx
    push    dx


IFDEF DEBUG
    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:libi2c_data, ES:libi2c_data

    mov     ax, libi2c_data
    mov     ds, ax
    mov     es, ax
ENDIF


    call    cal_pci_baseaddr
    mov     bl, SMBUS_HOST_OFF
    call    pci_read_config_byte


IFDEF DEBUG
    push    eax
    mov     al, bl
    debug_ascii_str smbus_host_cfg, 2, 34
    pop     eax
ENDIF


    ;
    ; Check SMBus Host Enable bit
    ;
i2c_pci_chk_hst:
    test    bl, 01h
    jnz     i2c_pci_hst_en

i2c_pci_hst_dis:
    debug_str smbus_hst_disable
    or      bl, 01h

i2c_pci_hst_en:
    debug_str smbus_hst_enable


    ;
    ; Check SMBus SMI Enable bit
    ;
i2c_pci_chk_smi:
    test    bl, 02h
    jnz     i2c_pci_smi_en

i2c_pci_smi_dis:
    debug_str smbus_smi_disable
    jmp     i2c_pci_chk_i2c

i2c_pci_smi_en:
    debug_str smbus_smi_enable


    ;
    ; Check SMBus I2C Enable bit
    ;
i2c_pci_chk_i2c:
    test    bl, 04h
    jz      i2c_pci_i2c_dis

i2c_pci_i2c_en:
    debug_str smbus_i2c_enable
    and     bl, not 04h

i2c_pci_i2c_dis:
    debug_str smbus_i2c_disable


    ;
    ; Write Host Configuation Register
    ;
i2c_pci_enable_exit:
    mov     bh, SMBUS_HOST_OFF
    call    pci_write_config_byte



IFDEF DEBUG
    mov     bl, SMBUS_HOST_OFF
    call    pci_read_config_byte
    push    eax
    mov     al, bl
    debug_ascii_str smbus_host_cfg, 2, 34
    pop     eax


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds
ENDIF


    pop     dx
    pop     cx
    pop     bx
    pop     eax

    ret

i2c_pci_enable ENDP




;##############################################################################
; i2c_pci_disable -- Disable I2C via PCI Host Configuration Register
;
; Input :
;   BH  = SMBus Bus number
;   BL  = SMBus Device number
;   CL  = SMBus Function number
;
; Output:
;   None
;
; Modified:
;   EAX
;   BX
;   CX
;   DX
;
i2c_pci_disable PROC FAR PUBLIC


    push    eax
    push    bx
    push    cx
    push    dx


IFDEF DEBUG
    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:libi2c_data, ES:libi2c_data

    mov     ax, libi2c_data
    mov     ds, ax
    mov     es, ax
ENDIF


    call    cal_pci_baseaddr
    mov     bl, SMBUS_HOST_OFF
    call    pci_read_config_byte


IFDEF DEBUG
    push    eax
    mov     al, bl
    debug_ascii_str smbus_host_cfg, 2, 34
    pop     eax
ENDIF


    ;
    ; Disable SMBus Host Enable bit (HST_EN) Bit0
    ; Disable SMBus I2C Enable bit (I2C_EN) Bit2
    ;
    and     bl, 0fah


    ;
    ; Write Host Configuation Register
    ;
    mov     bh, SMBUS_HOST_OFF
    call    pci_write_config_byte


IFDEF DEBUG
    mov     bl, SMBUS_HOST_OFF
    call    pci_read_config_byte
    push    eax
    mov     al, bl
    debug_ascii_str smbus_host_cfg, 2, 34
    pop     eax


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds
ENDIF


    pop     dx
    pop     cx
    pop     bx
    pop     eax

    ret

i2c_pci_disable ENDP


;##############################################################################
; i2c_sum_regs -- Summary values of all registers
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;   CX
;   DX
;
i2c_sum_regs PROC FAR PUBLIC


    push    ax
    push    bx
    push    cx
    push    dx


    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:libi2c_data, ES:libi2c_data

    mov     ax, libi2c_data
    mov     ds, ax
    mov     es, ax


    xor     eax, eax
    mov     dx, i2c_iobase
    

    ;
    ; Read HST_STS register
    ;
    in      al, dx
    replace_ascii_str sum_regs, 2, 18
    

    ;
    ; Read HST_CNT register
    ;
    add     dx, 2
    in      al, dx
    replace_ascii_str sum_regs, 2, 28


    ;
    ; Read HST_CMD register
    ;
    add     dx, 1
    in      al, dx
    replace_ascii_str sum_regs, 2, 38


    ;
    ; Read XMIT_SLVA register
    ;
    add     dx, 1
    in      al, dx
    replace_ascii_str sum_regs, 2, 48


    ;
    ; Read HST_D0 register
    ;
    add     dx, 1
    in      al, dx
    replace_ascii_str sum_regs, 2, 57


    ;
    ; Read HST_D1 register
    ;
    add     dx, 1
    in      al, dx
    replace_ascii_str sum_regs, 2, 64


    ;
    ; print register information
    ;
    print_str   sum_regs


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds

    pop     dx
    pop     cx
    pop     bx
    pop     ax

    ret

i2c_sum_regs ENDP


;##############################################################################
; i2c_byte_read -- Perform I2C byte read
;
; Input :
;   i2c_iobase  = I2C IO Base Address
;   AH          = Slave Address
;   AL          = Data Address
;
; Output:
;   AL          = I2C byte result
;
; Modified:
;   AX
;   DX
;
i2c_byte_read PROC FAR PUBLIC


    push    dx
    mov     dx, ax

    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:libi2c_data, ES:libi2c_data

    mov     ax, libi2c_data
    mov     ds, ax
    mov     es, ax


    ;
    ; Prepare Slave address
    ;
    mov     ax, dx
    shl     ah, 1               ; Slave Addr << 1
    or      ah, 1               ; Read

    mov     dx, i2c_iobase 
    add     dx, XMIT_SLVA
    xchg    ah, al
    out     dx, al              ; Write slave addr to reg
    xchg    ah, al
    

    ;
    ; Prepare Data address
    ;
    mov     dx, i2c_iobase
    add     dx, HST_CMD
    out     dx, al              ; write data addr to reg
    

    ;
    ; Set control reg
    ;
    mov     dx, i2c_iobase
    add     dx, HST_CNT
    mov     al, 28h
    out     dx, al              ; perform byte mode


    ;
    ; Clear HST_D0
    ;
    mov     dx, i2c_iobase
    add     dx, HST_D0
    mov     al, 0ffh
    out     dx, al


    ;
    ; Perform transaction
    ;
    call    i2c_transaction

IFDEF DEBUG
    call    i2c_sum_regs
ENDIF


    ;
    ; Read result
    ;
    mov     dx, i2c_iobase
    add     dx, HST_D0
    in      al, dx


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds


    pop     dx

    ret

i2c_byte_read ENDP


;##############################################################################
; i2c_byte_write -- Perform I2C byte write
;
; Input :
;   AH          = Slave Address
;   AL          = Data Address
;   BL          = Value to write
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;
i2c_byte_write PROC FAR PUBLIC


    push    dx
    mov     dx, ax

    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:libi2c_data, ES:libi2c_data

    mov     ax, libi2c_data
    mov     ds, ax
    mov     es, ax


    ;
    ; Prepare Slave address
    ;
    mov     ax, dx
    shl     ah, 1               ; Slave Addr << 1, Write bit0=0

    mov     dx, i2c_iobase 
    add     dx, XMIT_SLVA
    xchg    ah, al
    out     dx, al              ; Write slave addr to reg
    xchg    ah, al
    

    ;
    ; Prepare Data address
    ;
    mov     dx, i2c_iobase
    add     dx, HST_CMD
    out     dx, al              ; write data addr to reg
    

    ;
    ; Set control reg
    ;
    mov     dx, i2c_iobase
    add     dx, HST_CNT
    mov     al, 28h
    out     dx, al              ; perform byte mode


    ;
    ; Set data to write
    ;
    mov     dx, i2c_iobase
    add     dx, HST_D0
    mov     al, bl
    out     dx, al


    ;
    ; Perform transaction
    ;
    call    i2c_transaction

IFDEF DEBUG
    call    i2c_sum_regs
ENDIF


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds


    pop     dx

    ret

i2c_byte_write ENDP


;##############################################################################
; i2c_transaction -- Perform I2C transaction
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;   CX
;   DX
;
i2c_transaction PROC NEAR PRIVATE


    push    ax
    push    dx


    ;
    ; Save caller's env.
    ;
    push    ds
    push    es

    ASSUME  DS:libi2c_data, ES:libi2c_data

    mov     ax, libi2c_data
    mov     ds, ax
    mov     es, ax


    ;
    ; Reset I2C bus
    ; 
    mov     dx, i2c_iobase      ; read Status
    in      al, dx
    and     al, 1fh
    out     dx, al              ; clear status


    ;
    ; Start I2C 
    ;
    mov     dx, i2c_iobase
    add     dx, HST_CNT
    in      al, dx

    or      al, 40h
    out     dx, al


    call    i2c_delay


    ;
    ; Read Status reg.
    ;
    mov     dx, i2c_iobase
    in      al, dx


    ;
    ; Check busy
    ;
    test    al, 01h
    jz      i2c_ready

    debug_str   i2c_bus_busy
    jmp     i2c_trans_err

i2c_ready:
    debug_str   i2c_bus_ready



    ;
    ; Check failed
    ;
    test    al, 10h
    jz      i2c_ok

    debug_str   i2c_bus_failed
    jmp     i2c_trans_err

i2c_ok:
    debug_str   i2c_bus_ok



    ;
    ; Check Collision bit
    ;
    test    al, 08h
    jz      i2c_no_collision

    debug_str   i2c_bus_col 
    jmp     i2c_trans_err

i2c_no_collision:
    debug_str   i2c_bus_nocol



    ;
    ; Check DEV_ERR bit
    ;
    test    al, 04h
    jz      i2c_noerr

    debug_str   i2c_bus_err
    jmp     i2c_trans_err

i2c_noerr:
    debug_str   i2c_bus_noerr


i2c_trans_err:
    stc

i2c_trans_done:
    clc


    ;
    ; Restore caller's env.
    ;
    pop     es
    pop     ds

    pop     dx
    pop     ax

    ret


i2c_transaction ENDP


;##############################################################################
; i2c_delay --  I2C delay routine for transaction
;
; Input :
;   None
;
; Output:
;
; Modified:
;   EBX
;   ECX
;
i2c_delay PROC NEAR PRIVATE

    push    ebx
    push    ecx


    mov     ebx, 000000ffh

delay_loop0:
    mov     ecx, 0000ffffh

delay_loop1:
    dec     ecx
    jnz     delay_loop1

    dec     ebx
    jnz     delay_loop0
    
    pop     ecx
    pop     ebx

    ret

i2c_delay ENDP


@CurSeg ENDS
    END
