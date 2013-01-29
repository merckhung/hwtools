;
; it871x.asm -- ITE IT871x SuperIO
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; it871x is a ITE IT871x SuperIO chip software tool
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\sio.inc
INCLUDE include\file.inc
INCLUDE include\mdebug.inc


INFO_LINES      EQU     7


;                                                                              
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'



;
; extern sub routines
;
routine SEGMENT USE16 PUBLIC

    EXTERN byte_ascii_to_bin:FAR
    EXTERN conv_push_ascii:FAR
@CurSeg ENDS


libsio SEGMENT USE16 PUBLIC

    EXTERN sio_enter_config:FAR
    EXTERN sio_exit_config:FAR
    EXTERN sio_select_ldn:FAR
    EXTERN sio_read_byte:FAR
    EXTERN sio_read_word:FAR
    EXTERN sio_write_byte:FAR
    EXTERN sio_io_read_byte:FAR
    EXTERN sio_io_write_byte:FAR
@CurSeg ENDS


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


    ; check arguments
    call    parse_args
    jc      args_error


    ;---------------------------------------------------------
    ; Enter into SuperIOConfiguration
    ;
    call    sio_enter_config

    ;
    ; Check Chip ID now
    ;
    ; Read chip id 1
    sio_read_reg ITE_CONF_CHIPID1
    cmp     al, 087h
    jnz     chip_error

    ; Read chip id 2
    sio_read_reg ITE_CONF_CHIPID2
    cmp     al, 005h
    jz      it871x_chipfound
    cmp     al, 012h
    jz      it871x_chipfound
    cmp     al, 016h
    jz      it871x_chipfound
    cmp     al, 018h
    jz      it871x_chipfound

    ; CHIP not found
    jmp     chip_error


it871x_chipfound:
    ; Print found message
    replace_ascii_str it871x_find_msg, 2, 11
    print_str   it871x_find_msg


    ;---------------------------------------------------------
    ; Initial Flow
    ;


    ;
    ; Select to Environment Controller area
    ;
    mov     ah, SIO_EC_LDN
    call    sio_select_ldn


    ; Read Environment Base IO port address
    mov     al, SIO_BASE_ADD
    call    sio_read_word


    mov     it871x_ec_ioaddr, ax
    print_ascii_str it871x_ec_ioaddr_msg, 4, 36


    ; Enable Environment controller
    sio_or_reg SIO_ACTI_ADD, 001h
    sio_debug_superio_reg 'Activate EC regs idx=0x30', SIO_ACTI_ADD



    ;
    ; Select to GPIO area
    ;
    mov     ah, SIO_GPIO_LDN
    call    sio_select_ldn


    ; Enable EC select
    sio_and_reg  ITE_CONF_LBLR, 0efh
    sio_debug_superio_reg 'Logical Block Lock Reg idx=0x2b', ITE_CONF_LBLR


    ; Enable GPIO14 multi-function
    sio_or_reg  ITE_CONF_EX1MFUN, 010h
    sio_debug_superio_reg 'Ext 1 Multi-Function idx=0x2a', ITE_CONF_EX1MFUN


    ; Setup GPIO14 as General Purpose IO function
    sio_or_reg  ITE_CONF_GPIO1, 010h
    sio_debug_superio_reg 'GPIO14 function idx=0x25', ITE_CONF_GPIO1


    ; Internal Pull-up GPIO14
    sio_or_reg  SIO_PULL1_ADD, 010h
    sio_debug_superio_reg 'Internal Pull-up GPIO14 idx=0xb8', SIO_PULL1_ADD


    ; Set GPIO14 to alternative function
    sio_and_reg SIO_SMIO1_ADD, 0efh
    sio_debug_superio_reg 'GPIO14 alternative function idx=0xc0', SIO_SMIO1_ADD


    ; Set GPIO14 to Output mode
    sio_or_reg SIO_OUTM1_ADD, 010h
    sio_debug_superio_reg 'GPIO14 Output mode idx=0xc8', SIO_OUTM1_ADD


    ; Map SMI# Pin to GPIO14
    sio_set_reg SIO_MSMI_ADD, SIO_GPIO_14
    sio_debug_superio_reg 'Map SMI# to GPIO14 idx=0xf4', SIO_MSMI_ADD


    ; Force clear all SMI# status and set to level trigger
    sio_or_reg  SIO_CSMI2_ADD, 0c0h
    sio_debug_superio_reg 'Force clear all SMI# status and set level trigger idx=0xf1', SIO_CSMI2_ADD


    ; Enable SMI# due to EC IRQ
    sio_or_reg  SIO_CSMI1_ADD, 010h
    sio_debug_superio_reg 'Enable SMI due to EC IRQ idx=0xf0', SIO_CSMI1_ADD


    ;---------------------------------------------------------
    ; Exit from configuration
    ;
    call    sio_exit_config






    ;---------------------------------------------------------
    ; Test SMI
    ;


    ;
    ; Setup temp1 max and min
    ;
    sio_io_read_reg it871x_ec_ioaddr, 029h

    mov     bl, al
    add     bl, 10

    mov     dx, it871x_ec_ioaddr
    mov     al, 040h
    call    sio_io_write_byte

    mov     al, 041h
    call    sio_io_write_byte


    ;
    ; Setup temp2 max and min
    ;
    sio_io_read_reg it871x_ec_ioaddr, 02ah

    mov     bl, al
    add     bl, 5

    mov     dx, it871x_ec_ioaddr
    mov     al, 042h
    call    sio_io_write_byte

    mov     al, 043h
    call    sio_io_write_byte


    ;
    ; Setup temp3 max and min
    ;
    sio_io_read_reg it871x_ec_ioaddr, 02bh

    mov     bl, al
    add     bl, 5

    mov     dx, it871x_ec_ioaddr
    mov     al, 044h
    call    sio_io_write_byte

    mov     al, 045h
    call    sio_io_write_byte


    



    ; get temp1 max
    sio_io_read_reg it871x_ec_ioaddr, 040h
    replace_ascii_str   temp1_msg, 2, 38

    ; get temp1 min
    sio_io_read_reg it871x_ec_ioaddr, 041h
    replace_ascii_str   temp1_msg, 2, 51

    ; get temp2 max
    sio_io_read_reg it871x_ec_ioaddr, 042h
    replace_ascii_str   temp2_msg, 2, 38

    ; get temp2 min
    sio_io_read_reg it871x_ec_ioaddr, 043h
    replace_ascii_str   temp2_msg, 2, 51

    ; get temp3 max
    sio_io_read_reg it871x_ec_ioaddr, 044h
    replace_ascii_str   temp3_msg, 2, 38

    ; get temp3 min
    sio_io_read_reg it871x_ec_ioaddr, 045h
    replace_ascii_str   temp3_msg, 2, 51



    ;
    ; Enable TMPIN3-1 enhanced interrupt mode
    ;
    sio_io_and_reg it871x_ec_ioaddr, 00ch, 037h
    sio_debug_io_reg 'TMPIN3-1 enhanced int mode idx=0x0c', it871x_ec_ioaddr, 00ch


    ;
    ; Enable Temperature 3-1 SMI#
    ;
    sio_io_and_reg it871x_ec_ioaddr, 006h, 0f8h
    sio_debug_io_reg 'TMPIN3-1 enable SMI# idx=0x06', it871x_ec_ioaddr, 006h


    ;
    ; Enable Temperature 3-1 interrupt
    ;
    ;sio_io_and_reg it871x_ec_ioaddr, 009h, 0f8h
    ;sio_io_set_reg it871x_ec_ioaddr, 009h, 0ffh
    sio_debug_io_reg 'TMPIN3-1 enable INT idx=0x09', it871x_ec_ioaddr, 009h


    ;
    ; Clear temperature interrupt Status
    ;
    sio_io_read_reg it871x_ec_ioaddr, 003h
    ;sio_debug_io_reg 'Clear temps int status idx=0x03', it871x_ec_ioaddr, 003h


    ;
    ; Enable SMI#
    ;
    sio_io_set_reg it871x_ec_ioaddr, 000h, 007h
    sio_debug_io_reg 'EC enable SMI# idx=0x00', it871x_ec_ioaddr, 000h


    mov     cx, 1000
test_loop:
    
    call    it871x_interval
    dec     cx
    jnz     test_loop

    
    ; add cursor back
    get_cursor
    add     dh, INFO_LINES
    set_cursor


    ;---------------------------------------------------------
    ; Everything done
    ;
    jmp     main_exit


args_error:

    print_str argerrmsg
    print_str usage
    jmp     main_exit


chip_error:

    print_str it871x_chip_error_msg
    print_str usage
    ;jmp     main_exit


main_exit:


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
    jnz     parse_args_chk
    jmp     parse_args_exit


parse_args_chk:
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
    mov     new_ioaddr, al

    inc     al
    mov     new_iodata, al

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


;##############################################################################
; it871x_interval -- Loop fot test SMI function
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   ECX
;   EDX
;
it871x_interval PROC NEAR PRIVATE

    push    eax
    push    ecx


    mov     ecx, 0fffffffh

    ; Get current temp1
    sio_io_read_reg it871x_ec_ioaddr, 029h
    replace_ascii_str temp1_msg, 2, 25

    ; Get current temp2
    sio_io_read_reg it871x_ec_ioaddr, 02ah
    replace_ascii_str temp2_msg, 2, 25

    ; Get current temp3
    sio_io_read_reg it871x_ec_ioaddr, 02bh
    replace_ascii_str temp3_msg, 2, 25


    ; Get EC interrupt status
    sio_io_read_reg it871x_ec_ioaddr, 001h
    replace_ascii_str ec_int1_msg, 2, 34


    ; Get EC interrupt status
    sio_io_read_reg it871x_ec_ioaddr, 002h
    replace_ascii_str ec_int2_msg, 2, 34


    ; Get EC interrupt status
    sio_io_read_reg it871x_ec_ioaddr, 003h
    replace_ascii_str ec_int3_msg, 2, 34


    ;
    ; Select GPIO LDN for testing
    ;
    call    sio_enter_config

    mov     ah, SIO_GPIO_LDN
    call    sio_select_ldn


    ; Get SMI# status
    sio_read_reg SIO_SSMI1_ADD
    replace_ascii_str smi_sts_msg, 2, 26


    ;
    ; Exit super io config
    ;
    call    sio_exit_config


    ; print out information
    print_str   temp1_msg
    print_str   ec_int1_msg
    print_str   ec_int2_msg
    print_str   ec_int3_msg
    print_str   smi_sts_msg


    ; Reset cursor
    get_cursor
    sub     dh, INFO_LINES
    xor     dl, dl
    set_cursor

delay_loop1:
    dec     ecx
    jnz     delay_loop1

    pop     ecx
    pop     eax

    ret

it871x_interval ENDP



_TEXT ENDS




;                                                                              
; Data segment
;
_DATA SEGMENT PARA USE16 'DATA'

new_ioaddr  DB      SIO_IOADDR
new_iodata  DB      SIO_IODATA

PSP         DW      0

version     DB      13, 10, 'it871x version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h

usage       DB      'Usage: it871x [IOPORT]', 13, 10, 13, 10
            DB      '    IOPORT: SuperIO I/O port address [Default: 0x2e]', 13, 10, 13, 10, 24h

argerrmsg   DB      13, 10, 'Invalid arguments format', 13, 10, 13, 10, 24h


it871x_chip_error_msg  DB      13, 10, 'Cannot find ITE871x SuperIO chip', 13, 10, 13, 10, 24h
it871x_find_msg        DB      'Found ITE87?? SuperIO chip', 13, 10, 24h

it871x_ec_ioaddr_msg  DB      'Environment Controller IO port at 0x????h', 13, 10, 24h
it871x_ec_ioaddr      DW      0000h


temp1_msg   DB      'Temperature1 current = 0x??h, max = 0x??h, min = 0x??h', 13, 10
temp2_msg   DB      'Temperature2 current = 0x??h, max = 0x??h, min = 0x??h', 13, 10
temp3_msg   DB      'Temperature3 current = 0x??h, max = 0x??h, min = 0x??h', 13, 10, 24h
ec_int1_msg DB      'EC Interrupt Status Register 1: 0x??h', 13, 10, 24h
ec_int2_msg DB      'EC Interrupt Status Register 2: 0x??h', 13, 10, 24h
ec_int3_msg DB      'EC Interrupt Status Register 3: 0x??h', 13, 10, 24h
smi_sts_msg DB      'SMI# Status Register 1: 0x??h', 13, 10, 24h


_DATA ENDS



;                                                                              
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'

    ;
    ; Stack Size = 100 bytes
    ;
    DW 100 DUP(0)

STACK ENDS

    END main
