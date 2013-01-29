;
; i2cget.asm -- Command line I2C read byte tool
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This tool was made for MS-DOS command line read byte from user specified
; I2C slave address device.
;
; Support Platform : Intel ICH-x series
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\i2c.inc


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
routine ENDS

libi2c SEGMENT USE16 PUBLIC

    EXTERN i2c_init_iobase:FAR
    EXTERN i2c_pci_enable:FAR
    EXTERN i2c_pci_disable:FAR
    EXTERN i2c_sum_regs:FAR
    EXTERN i2c_byte_read:FAR
    EXTERN i2c_byte_write:FAR
libi2c ENDS



;##############################################################################
; main procedure
;
main PROC FAR

    push    ds
    push    ax


    ASSUME  SS:STACK, DS:_DATA, CS:_TEXT, ES:_DATA
    mov     ax, _DATA
    mov     ds, ax
    
    mov     ax, es
    mov     PSP, ax

    mov     ax, _DATA
    mov     es, ax


    ; check arguments
    call    parse_args
    jc      args_error


    ;
    ; Initialize I2C communication
    ;
    mov     bh, SMBUS_BUS_ID
    mov     bl, SMBUS_DEV_ID
    mov     cl, SMBUS_FUN_ID
    ;-----------------------------
    call    i2c_pci_disable
    call    i2c_pci_enable
    call    i2c_init_iobase
    jc      chip_error
    ;-----------------------------


    ;
    ; Read I2C device
    ;
    mov     al, slave_addr
    replace_ascii_str   resultmsg, 2, 28
    mov     ah, slave_addr

    mov     al, reg_offset
    replace_ascii_str   resultmsg, 2, 47

    call    i2c_byte_read
    replace_ascii_str   resultmsg, 2, 61


    ;
    ; Print result
    ;
    print_str   resultmsg


    jmp     main_exit


args_error:

    print_str argerrmsg
    print_str usage
    jmp     main_exit


chip_error:

    print_str chiperrmsg


main_exit:

    print_str version


    ; Return to OS
    ret

main ENDP




;##############################################################################
; parse_args -- Parse Arguments
;
; Input :
;   PSP
;
; Output:
;   slave_addr
;   reg_offset
;
; Modified:
;   ax
;   bx
;   es
;
parse_args PROC NEAR PRIVATE


    push    ax
    push    bx

    push    es
    mov     ax, PSP
    mov     es, ax

    mov     bx, 80h

    mov     al, es:[bx]

    cmp     al, 0
    jz      parse_args_error

    
    ; check prefix of first argument
    add     bx, 2
    mov     ax, es:[bx]
    cmp     ax, 'x0'
    jnz     parse_args_error


    ; get first argument
    add     bx, 2
    mov     ax, es:[bx]


    ; Convert ASCII to binary
    call    byte_ascii_to_bin
    jc      parse_args_error
    mov     slave_addr, al


    ; check 0x7f
    and     al, not 7fh
    cmp     al, 0
    jnz     parse_args_error

    
    ; check prefix of second argument
    add     bx, 3
    mov     ax, es:[bx]
    cmp     ax, 'x0'
    jnz     parse_args_error


    ; get second argument
    add     bx, 2
    mov     ax, es:[bx]
    

    ; Convert ASCII to binary
    call    byte_ascii_to_bin
    jc      parse_args_error   
    mov     reg_offset, al


    clc
    jmp     parse_args_exit
    

parse_args_error:

    stc

parse_args_exit:


    pop     es

    pop     bx
    pop     ax


    ret

parse_args ENDP


_TEXT ENDS




;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 'DATA'

slave_addr  db      0ffh
reg_offset  db      00h

PSP         dw      0

version     db      13, 10, 'i2cget version 0.2 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h

usage       db      'Usage: i2cget SLAVE_ADDR REG_OFFSET DATA_VALUE', 13, 10, 13, 10
            db      '   SLAVE_ADDR: 7bit Slave address of I2C device (0x00 - 0x7f)', 13, 10
            db      '   REG_OFFSET: Register offset in I2C device    (0x00 - 0xff)', 13, 10, 13, 10, 24h

argerrmsg   db      13, 10, 'Invalid arguments format or missing', 13, 10, 13, 10, 24h

chiperrmsg  db      'Your chipset is not Intel ICH-x family, please contact with author, Merck Hung <merck.hung@mic.com.tw> Ext.1790', 13, 10, 24h

resultmsg   db      13, 10, 13, 10, 'Read I2C slave addr = 0x??, reg offset = 0x??, value = 0x??', 13, 10, 13, 10, 24h
;                                                           28                 47            61

_DATA ENDS



;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'

    ;
    ; Stack Size = 100 bytes
    ;
    DW 100 DUP(0)

STACK ENDS

    END main
