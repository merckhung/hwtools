;
; sio.inc -- Header file related to SuperIO routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;

SIO_IOADDR      EQU     02eh
SIO_IODATA      EQU     02fh


; LDN listing
SIO_EC_LDN      EQU     004h
SIO_GPIO_LDN    EQU     007h


; Register listing
SIO_LDN_REG     EQU     007h
SIO_ACTI_ADD    EQU     030h
SIO_BASE_ADD    EQU     060h
SIO_INTL_ADD    EQU     070h


; GPIO register listing
SIO_PULL1_ADD   EQU     0b8h
SIO_PULL2_ADD   EQU     0b9h
SIO_PULL3_ADD   EQU     0bah
SIO_PULL4_ADD   EQU     0bbh
SIO_PULL5_ADD   EQU     0bdh

SIO_SMIO1_ADD   EQU     0c0h
SIO_SMIO2_ADD   EQU     0c1h
SIO_SMIO3_ADD   EQU     0c2h
SIO_SMIO4_ADD   EQU     0c3h
SIO_SMIO5_ADD   EQU     0c4h

SIO_OUTM1_ADD   EQU     0c8h
SIO_OUTM2_ADD   EQU     0c9h
SIO_OUTM3_ADD   EQU     0cah
SIO_OUTM4_ADD   EQU     0cbh
SIO_OUTM5_ADD   EQU     0cch

SIO_CSMI1_ADD   EQU     0f0h
SIO_CSMI2_ADD   EQU     0f1h

SIO_SSMI1_ADD   EQU     0f2h
SIO_SSMI2_ADD   EQU     0f3h

SIO_MSMI_ADD    EQU     0f4h


SIO_GPIO_13     EQU     00bh
SIO_GPIO_14     EQU     00ch
SIO_GPIO_15     EQU     00dh


SIO_DEVIO_ADD   EQU     005h
SIO_DEVIO_DATA  EQU     006h


;
; ITE 8716 chip
;
ITE_CONF_CHIPID1        EQU     020h
ITE_CONF_CHIPID2        EQU     021h
ITE_CONF_GPIO1          EQU     025h
ITE_CONF_EX1MFUN        EQU     02ah
ITE_CONF_LBLR           EQU     02bh




;##############################################################################
; Set SIO register
;
sio_set_reg MACRO REG, VALUE

    mov     al, REG
    mov     ah, VALUE
    call    sio_write_byte
ENDM


;##############################################################################
; Read, OR and write back
;
sio_or_reg MACRO REG, MASK

    mov     al, REG
    call    sio_read_byte

    mov     ah, al
    or      ah, MASK
    mov     al, REG
    call    sio_write_byte
ENDM


;##############################################################################
; Read, AND and write back
;
sio_and_reg MACRO REG, MASK

    mov     al, REG
    call    sio_read_byte

    mov     ah, al
    and     ah, MASK
    mov     al, REG
    call    sio_write_byte
ENDM


;##############################################################################
;
;
sio_read_reg MACRO REG

    mov     al, REG
    call    sio_read_byte
ENDM


;##############################################################################
; Set IO register
;
sio_io_set_reg MACRO IOADDR, REG, VALUE

    mov     dx, IOADDR
    mov     al, REG
    mov     bl, VALUE
    call    sio_io_write_byte
ENDM


;##############################################################################
; Read, OR and write back
;
sio_io_or_reg MACRO IOADDR, REG, MASK

    mov     dx, IOADDR
    mov     al, REG
    call    sio_io_read_byte

    mov     bl, al
    or      bl, MASK

    mov     dx, IOADDR
    mov     al, REG
    call    sio_io_write_byte
ENDM


;##############################################################################
; Read, AND and write back
;
sio_io_and_reg MACRO IOADDR, REG, MASK

    mov     dx, IOADDR
    mov     al, REG
    call    sio_io_read_byte

    mov     bl, al
    and     bl, MASK

    mov     dx, IOADDR
    mov     al, REG
    call    sio_io_write_byte
ENDM


;##############################################################################
;
;
sio_io_read_reg MACRO IOADDR, REG

    mov     dx, IOADDR
    mov     al, REG
    call    sio_io_read_byte
ENDM


;##############################################################################
;
;
sio_debug_superio_reg MACRO STRING, REG

IFDEF DEBUG
    xor     eax, eax
    mov     al, REG
    call    sio_read_byte
    debug_print_str STRING
ENDIF

ENDM


;##############################################################################
;
;
sio_debug_io_reg MACRO STRING, IOADDR, REG

IFDEF DEBUG
    xor     eax, eax
    mov     dx, IOADDR
    mov     al, REG
    call    sio_io_read_byte
    debug_print_str STRING
ENDIF

ENDM


