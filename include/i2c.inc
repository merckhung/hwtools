;
; i2c.inc -- Header file related to I2C routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


;
; Intel ICH6 SMBus information
;
SMBUS_BUS_ID    equ     00h
SMBUS_DEV_ID    equ     1fh
SMBUS_FUN_ID    equ     03h


SMBUS_HOST_OFF  equ     40h


;
; Intel ICH6 SMBus register offset
;
HST_STS         equ     00h
HST_CNT         equ     02h
HST_CMD         equ     03h
XMIT_SLVA       equ     04h
HST_D0          equ     05h
HST_D1          equ     06h
HOST_BLOCK_DB   equ     07h
PEC             equ     08h
AUX_STS         equ     0ch
AUX_CTL         equ     0dh



;##############################################################################
; i2c_read_push -- Read data from I2C device and push result into buffer
;
; Input :
;   REGOFF  = Register Offset
;   STRP    = String pointer to push result
;   ABS     = ASCII bytes of result
;   OFF     = Offset of string pointer to push result
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;
i2c_read_push MACRO REGOFF, STRP, ABS, OFF

    push    ax
    push    bx


    mov     ah, slave_addr
    mov     al, REGOFF
    call    i2c_byte_read
    replace_ascii_str   STRP, ABS, OFF


    pop     bx
    pop     ax

ENDM


;##############################################################################
;
; Input:
;   SLAVE   = I2C slave address
;   OFFSET  = Register offset
;
; Output:
;   AL      = Result
;
; Modified:
;   AX
;
; Mode:
;   REAL mode
;
i2cget MACRO SLAVE, OFFSET

    mov     ah, SLAVE
    mov     al, OFFSET
    call    i2c_byte_read
ENDM


;##############################################################################
; i2cset -- Write value to I2C device
;
; Input:
;   SLAVE   = I2C slave address
;   OFFSET  = Register offset
;   VALUE   = Value to write
;
; Output:
;   None
;
; Modified:
;   None
;
; Mode:
;   REAL mode
;
i2cset MACRO SLAVE, OFFSET, VALUE

    mov     bl, VALUE
    mov     ah, SLAVE
    mov     al, OFFSET
    call    i2c_byte_write
ENDM


