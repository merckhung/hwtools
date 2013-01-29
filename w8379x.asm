;
; w8379x.asm -- Winbond W8979x HW monitor
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; w8379x is a Winbond W8379x HW monitor IC I2C software tool
;
.586P


INCLUDE include\routine.inc
INCLUDE include\mroutine.inc
INCLUDE include\i2c.inc
INCLUDE include\w8379x.inc


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
    ;                             
    call    i2c_pci_disable
    call    i2c_pci_enable
    call    i2c_init_iobase
    jc      chip_error
    ;                             


    call    w8379x_win







    jmp     main_exit

args_error:

    print_str argerrmsg
    print_str usage
    jmp     main_exit


chip_error:

    print_str chiperrmsg


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
; w8379x_win -- Display W83792 Main window
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   EBX
;   CX
;   DX
;   DI
;   SI
;
w8379x_win PROC NEAR PRIVATE

    
    push    eax
    push    ebx
    push    cx
    push    dx
    push    di
    push    si


w8379x_win_redraw:

    ; Clear Screen
    clear_screen    070h


    ; Menu
    set_screen      70h, 1, 0, 1, 79
    set_screen      74h, 1, 1, 1, 2
    set_screen      74h, 1, 15, 1, 16
    set_screen      74h, 1, 31, 1, 32


    ; Set color     chip info.
    set_screen      1eh, 0, 0, 0 ,79
    set_screen      1eh, 0, 0, 0, 38


    ; set color     foot
    set_screen      78h, 23, 0, 23, 79
    set_screen      00h, 24, 0, 24, 79


	; Reset cursor
	set_cursor      0000h







    ;-------------------------------------------------------------------------- 





    ; VCoreA
    w8379x_voltage  20h, 8, 3, w8379x_m001, 15
    ; VCoreA MIN
    w8379x_voltage  2ch, 8, 3, w8379x_m001, 34
    ; VCoreA MAX
    w8379x_voltage  2bh, 8, 3, w8379x_m001, 52


    ; VCoreB
    w8379x_voltage  21h, 8, 3, w8379x_m002, 15
    ; VCoreB MIN
    w8379x_voltage  2eh, 8, 3, w8379x_m002, 34
    ; VCoreB MAX
    w8379x_voltage  2dh, 8, 3, w8379x_m002, 52


    ; VIN0
    w8379x_voltage  22h, 16, 3, w8379x_m003, 15
    ; VIN0 MIN
    w8379x_voltage  30h, 16, 3, w8379x_m003, 34
    ; VIN0 MAX
    w8379x_voltage  2fh, 16, 3, w8379x_m003, 52


    ; VIN1
    w8379x_voltage  23h, 16, 3, w8379x_m004, 15
    ; VIN1 MIN
    w8379x_voltage  32h, 16, 3, w8379x_m004, 34
    ; VIN1 MAX
    w8379x_voltage  31h, 16, 3, w8379x_m004, 52



    ; VIN2
    w8379x_voltage  24h, 16, 3, w8379x_m005, 15
    ; VIN2 MIN
    w8379x_voltage  34h, 16, 3, w8379x_m005, 34
    ; VIN2 MAX
    w8379x_voltage  33h, 16, 3, w8379x_m005, 52



    ; VIN3
    w8379x_voltage  25h, 16, 3, w8379x_m006, 15
    ; VIN3 MIN
    w8379x_voltage  36h, 16, 3, w8379x_m006, 34
    ; VIN3 MAX
    w8379x_voltage  35h, 16, 3, w8379x_m006, 52





    ; 5VCC
    i2c_read_push   26h, w8379x_m007, 2, 17


    ; 5VSB
    i2c_read_push   0b0h, w8379x_m008, 2, 17


    ; VBAT
    i2c_read_push   0b1h, w8379x_m009, 2, 17




    ;
    ; Calculate RPM of all fans
    ;
    ; Fan1
    w8379x_fan_rpm  28h, 47h, w8379x_m010, 11
    ; Fan1 MIN
    w8379x_fan_rpm  3bh, 47h, w8379x_m010, 30
    ; Fan1 DIV
    w8379x_divisor  47h, w8379x_m010, 55



    ; Fan2
    w8379x_fan_rpm  29h, 47h, w8379x_m011, 11, 1
    ; Fan2 MIN
    w8379x_fan_rpm  3ch, 47h, w8379x_m011, 30, 1
    ; Fan2 DIV
    w8379x_divisor  47h, w8379x_m011, 55, 1


    ; Fan3
    w8379x_fan_rpm  2ah, 5bh, w8379x_m012, 11
    ; Fan3 MIN
    w8379x_fan_rpm  3dh, 5bh, w8379x_m012, 30
    ; Fan3 DIV
    w8379x_divisor  5bh, w8379x_m012, 55


    ; Fan4
    w8379x_fan_rpm  0b8h, 5bh, w8379x_m013, 11, 1
    ; Fan4 MIN
    w8379x_fan_rpm  0bbh, 5bh, w8379x_m013, 30, 1
    ; Fan4 DIV
    w8379x_divisor  5bh, w8379x_m013, 55, 1


    ; Fan5
    w8379x_fan_rpm  0b9h, 5ch, w8379x_m014, 11
    ; Fan5 MIN
    w8379x_fan_rpm  0bch, 5ch, w8379x_m014, 30
    ; Fan5 DIV
    w8379x_divisor  5ch, w8379x_m014, 55


    ; Fan6
    w8379x_fan_rpm  0bah, 5ch, w8379x_m015, 11, 1
    ; Fan6 MIN
    w8379x_fan_rpm  0bdh, 5ch, w8379x_m015, 30, 1
    ; Fan6 DIV
    w8379x_divisor  5ch, w8379x_m015, 55, 1



    ; Temp1
    w8379x_sensor_8comp 27h, w8379x_m016, 14
    w8379x_sensor_8comp 39h, w8379x_m016, 33
    w8379x_sensor_8comp 3ah, w8379x_m016, 50
    w8379x_sensor_8comp 90h, w8379x_m016, 69
                                                                                                                             

    ; Temp2
    w8379x_sensor_9comp 0c0h, 0c1h, w8379x_m017, 14
    w8379x_sensor_8comp 0c3h, w8379x_m017, 33
    w8379x_sensor_8comp 0c5h, w8379x_m017, 50
    w8379x_sensor_8comp 91h, w8379x_m017, 69


    ; Temp3
    w8379x_sensor_9comp 0c8h, 0c9h, w8379x_m018, 14
    w8379x_sensor_8comp 0cbh, w8379x_m018, 33
    w8379x_sensor_8comp 0cdh, w8379x_m018, 50
    w8379x_sensor_8comp 92h, w8379x_m018, 69





    ;--------------------------------------------------------------------------


    ; Print 8379x window
    print_str   w8379x_scr


    set_cursor      0325h



    ;
    ; Handle user key inout
    ;
pci_sh_next_input:
    wait_input

    cmp     ax, PGUP
    jz      w8379x_win_redraw

    cmp     ax, PGDN
    jz      w8379x_win_redraw

    cmp     ax, UP
    jz      w8379x_win_redraw

    cmp     ax, DOWN
    jz      w8379x_win_redraw

    cmp     ax, RIGHT
    jz      w8379x_win_redraw

    cmp     ax, LEFT
    jz      w8379x_win_redraw

    ;                                       


    clear_screen    07h


    pop     si
    pop     di
    pop     dx
    pop     cx
    pop     ebx
    pop     eax


    ret

w8379x_win ENDP


w8379x_interval PROC NEAR PRIVATE

    push    ecx

    mov     ecx, 03fffffh
wi_loop:
    nop
    nop
    nop
    nop
    dec     ecx    
    jnz     wi_loop

    pop     ecx

    ret

w8379x_interval ENDP


_TEXT ENDS




;                                                                              
; Data segment
;
_DATA SEGMENT PARA USE16 'DATA'

slave_addr  db      0ffh

PSP         dw      0

version     db      13, 10, 'w8379x version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h

usage       db      'Usage: w8379x SLAVE_ADDR', 13, 10, 13, 10
            db      '   SLAVE_ADDR: 7bit Slave address of I2C device (0x00 - 0x7f)', 13, 10, 13, 10, 24h

argerrmsg   db      13, 10, 'Invalid arguments format or missing', 13, 10, 13, 10, 24h

chiperrmsg  db      'Your chipset is not Intel ICH x family, please contact with author, Merck Hung <merck.hung@mic.com.tw> Ext.1790', 13, 10, 24h



w8379x_scr  db  'Winbond W8379x Hardware Monitor (Rev.D)                                         '
            db  '(F1)Registers (F2)Temp offset (F3)SmartFan                                      '
            db  '                                                                                '
w8379x_m001 db  '   VCoreA:    +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m002 db  '   VCoreB:    +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m003 db  '   VIN0:      +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m004 db  '   VIN1:      +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m005 db  '   VIN2:      +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m006 db  '   VIN3:      +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m007 db  '   5VCC:      +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m008 db  '   5VSB:      +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m009 db  '   VBAT:      +?.?? V  (min =    +?.?? V, max =    +?.?? V)                     '
w8379x_m010 db  '   Fan1:   ?????? RPM  (min = ?????? RPM, div =        ?  )                     '
w8379x_m011 db  '   Fan2:   ?????? RPM  (min = ?????? RPM, div =        ?  )                     '
w8379x_m012 db  '   Fan3:   ?????? RPM  (min = ?????? RPM, div =        ?  )                     '
w8379x_m013 db  '   Fan4:   ?????? RPM  (min = ?????? RPM, div =        ?  )                     '
w8379x_m014 db  '   Fan5:   ?????? RPM  (min = ?????? RPM, div =        ?  )                     '
w8379x_m015 db  '   Fan6:   ?????? RPM  (min = ?????? RPM, div =        ?  )                     '
w8379x_m016 db  '   Temp1:    +???.0 C  (high =  +???.0 C, low =  +???.0 C, offset = +???.0 C)   '
w8379x_m017 db  '   Temp2:    +???.? C  (high =  +???.0 C, low =  +???.0 C, offset = +???.0 C)   '
w8379x_m018 db  '   Temp3:    +???.? C  (high =  +???.0 C, low =  +???.0 C, offset = +???.0 C)   '
w8379x_m019 db  '                                                                                '
w8379x_m020 db  '                                                                                '
            db  '                                 Merck Hung 2006 - 2009 (C) all rights reserved$'
 


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
