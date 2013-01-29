;
; flxios.asm -- x86 FlashROM programmer
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a programmer of x86 FlashROM
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\routine.inc
INCLUDE include\lpc.inc
INCLUDE include\flat.inc
INCLUDE include\flash.inc
INCLUDE include\mdebug.inc
INCLUDE include\file.inc


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


libflash SEGMENT USE16 PUBLIC

    EXTERN flash_read_chipid:FAR
    EXTERN flash_block_erase:FAR
    EXTERN flash_byte_program:FAR
    EXTERN flash_block_unlock:FAR
@CurSeg ENDS


libflat SEGMENT USE16 PUBLIC

    EXTERN __enter_flat_mode:FAR
    EXTERN __exit_flat_mode:FAR
@CurSeg ENDS







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
    

    ; check arguments
    ;call    parse_args
    ;jc      args_error



    ;---------------------------------------------------------
    ; Read image, erase block, and program byte by byte
    ;
    mov     cx, 64          ; 64 * 32k = 1M
    mov     burnaddr, ROM_02


    print_str flxios_scr


IF 0
open_loop:


    ; Save counters
    push    cx


    ; Open image file
    OpenFile    imgname, 0
    jc      openimg_error


    ; Save Handler
    mov     imghldr, ax

    
    ; Seek file
    myseekfile imghldr, 0, imgptr


    ; Read SMI handler binary from file and write to buffer
    ReadFile imghldr, imgbuf, IMGBUF_SIZE, 0


    ; Save Read Size
    and     eax, 0ffffh
    add     imgptr, eax


    ; Close file handler
    CloseFile imghldr


    ; Print message
    mov eax, burnaddr
    print_ascii_str progmsg, 8, 19


;--------------------------------------------------------------------------
; Enter FLAT mode
;--------------------------------------------------------------------------
enter_flat_mode
;--------------------------------------------------------------------------
; FLAT mode code start
;--------------------------------------------------------------------------



    ;
    ; Do erase block
    ;
    test    gs:wrcount, 1
    jnz     skip_erase_block

erase_next_block:


    ;
    ; Do Erase block
    ;
    push    ebx
    mov     ebx, gs:burnaddr
    call    flash_block_unlock
    call    flash_block_erase
    pop     ebx

skip_erase_block:




    ;
    ; Do Program
    ;
    mov     ebx, gs:burnaddr
    mov     esi, IMGBUF_SIZE    ; write 32k
    xor     edx, edx

prog_next_byte:


    ; Prepare data to write
    mov     edi, offset imgbuf
    add     edi, edx
    mov     cl, gs:[edi]

    call    flash_byte_program
    inc     ebx
    inc     edx
    dec     esi
    jnz     prog_next_byte


    ;
    ; Post-perform
    ;
    push    ebx
    mov     ebx, gs:burnaddr
    add     ebx, IMGBUF_SIZE
    mov     gs:burnaddr, ebx
    pop     ebx



;--------------------------------------------------------------------------
; Exit FLAT mode
;--------------------------------------------------------------------------
exit_flat_mode
;--------------------------------------------------------------------------
; REAL mode code
;--------------------------------------------------------------------------


    ; inc write counter
    inc     gs:wrcount

    ; Restore counter
    pop     cx
    dec     cx
    jnz     open_loop

ENDIF


    

    jmp     main_exit


openimg_error:

    print_str oimgerrmsg
    print_str usage
    jmp     main_exit

args_error:

    print_str argerrmsg
    print_str usage
    ;jmp     main_exit

main_exit:

    print_str version
    
    ; Return to DOS
    ret

MAIN ENDP




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
; Mode:
;   REAL mode
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

    
    add     bx, 2
    mov     cx, LENOFNAME
    mov     di, offset IMAGENAME

    ; Get image filename
parse_args_loop:
    mov     al, es:[bx]
    cmp     al, 0
    jz      parse_args_got
    mov     [di], al

    inc     di
    inc     bx
    dec     cx
    jnz     parse_args_loop

parse_args_got:

    cmp     cx, LENOFNAME
    jz      parse_args_error


    ; Normal return
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
_DATA SEGMENT PARA USE16 STACK 'STACK'
align 4


PSP         DW      0

LENOFNAME   EQU     30
IMAGENAME   DB      LENOFNAME DUP(0)

version     DB      13, 10, 'flxios version 0.2 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h

usage       DB      'Usage: flxios IMAGE', 13, 10, 13, 10
            DB      '   IMAGE: Image filename to program FlashROM', 13, 10, 13, 10, 24h

argerrmsg   DB      13, 10, 'Invalid arguments format or missing', 13, 10, 13, 10, 24h
oimgerrmsg  DB      13, 10, 'Cannot Open Image file', 13, 10, 13, 10, 24h

progmsg     DB      'Program at address ????????h', 13, 10, 24h


;
; Image buffer(32k)
;
IMGBLOCK    EQU     32
IMGBUF_SIZE EQU     IMGBLOCK * 1024

imgname     DB      'xios.rom', 0
imghldr     DW      0
wrcount     DW      0
burnaddr    DD      0

imgsize     DW      0
imgptr      DD      0
imgbuf      DB      IMGBUF_SIZE DUP(0)


flxios_scr  db  'X-BIOS Project Flash ROM Programmer                                             '
            db  '                                                                                '
            db  '                                                                                '
flxios_m001 db  '                                                                                '
flxios_m002 db  '                                                                                '
flxios_m003 db  '                                                                                '
flxios_m004 db  '                                                                                '
flxios_m005 db  '                                                                                '
flxios_m006 db  '                                                                                '
flxios_m007 db  '                                                                                '
flxios_m008 db  '                                                                                '
flxios_m009 db  '                                                                                '
flxios_m010 db  '                                                                                '
flxios_m011 db  '                                                                                '
flxios_m012 db  '                                                                                '
flxios_m013 db  '                                                                                '
flxios_m014 db  '                                                                                '
flxios_m015 db  '                                                                                '
flxios_m016 db  '                                                                                '
flxios_m017 db  '                                                                                '
flxios_m018 db  '                                                                                '
flxios_m019 db  '                                                                                '
flxios_m020 db  '                                                                                '
            db  '                                                  Copyright 2007 (C), Merck Hung$'


_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

    DW     256 DUP(0)

STACK ENDS






    END MAIN


