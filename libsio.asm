;
; libsio.asm -- SuperIO routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of SuperIO routines for x86 assembly programming.
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\sio.inc


;
; extern sun-routines
;


;------------------------------------------------------------------------------
; libsio code segment
;
libsio SEGMENT USE16 PUBLIC



;----------------------------------- PUBLIC -----------------------------------


;##############################################################################
; sio_enter_config -- Issue SuperIO configure enter sequence
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;
sio_enter_config PROC FAR PUBLIC


    push    ax
    push    dx


    mov     dx, SIO_IOADDR
    mov     al, 87h
    out     dx, al

    mov     al, 01h
    out     dx, al

    mov     al, 55h
    out     dx, al
    out     dx, al


    pop     dx
    pop     ax

    ret

sio_enter_config ENDP


;##############################################################################
; sio_exit_config -- Issue SuperIO configure exit sequence
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;
sio_exit_config PROC FAR PUBLIC


    push    ax
    push    dx


    mov     dx, SIO_IOADDR
    mov     al, 02h
    out     dx, al

    mov     dx, SIO_IODATA
    mov     al, 02h
    out     dx, al


    pop     dx
    pop     ax

    ret

sio_exit_config ENDP


;##############################################################################
; sio_select_ldn -- SuperIO select LDN
;
; Input:
;   AH      = Logical Device Number
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;
sio_select_ldn PROC FAR PUBLIC


    push    ax
    push    dx


    mov     dx, SIO_IOADDR
    mov     al, SIO_LDN_REG
    out     dx, al

    mov     dx, SIO_IODATA
    mov     al, ah
    out     dx, al


    pop     dx
    pop     ax

    ret

sio_select_ldn ENDP


;##############################################################################
; sio_read_byte -- SuperIO read byte
;
; Input :
;   AL      = Register offset to read
;
; Output:
;   AL      = Result value
;
; Modified:
;   DX
;
sio_read_byte PROC FAR PUBLIC


    push    dx

    mov     dx, SIO_IOADDR
    out     dx, al

    mov     dx, SIO_IODATA
    in      al, dx

    pop     dx

    ret

sio_read_byte ENDP


;##############################################################################
; sio_read_word -- SuperIO read word
;
; Input:
;   AL      = Register offset to read
;
; Output:
;   AX      = Result value
;
; Modified:
;   DX
;
sio_read_word PROC FAR PUBLIC

    push    bx
    push    dx

    ; Save offset in bl
    mov     bl, al
    mov     dx, SIO_IOADDR
    out     dx, al

    ; First byte in bh
    mov     dx, SIO_IODATA
    in      al, dx
    mov     bh, al

    ; Read next byte
    inc     bl
    mov     al, bl
    mov     dx, SIO_IOADDR
    out     dx, al

    ; Second byte in al
    mov     dx, SIO_IODATA
    in      al, dx
    
    ; AH = Second, AL = First
    mov     ah, bh


    pop     dx
    pop     bx

    ret

sio_read_word ENDP


;##############################################################################
; sio_write_byte -- SuperIO write byte
;
; Input:
;   AL      = Register offset to read
;   AH      = Value to write in byte
;
; Output:
;   None
;
; Modified:
;   DX
;
sio_write_byte PROC FAR PUBLIC

    push    dx

    mov     dx, SIO_IOADDR
    out     dx, al

    mov     dx, SIO_IODATA
    mov     al, ah
    out     dx, al

    pop     dx

    ret

sio_write_byte ENDP


;##############################################################################
; sio_io_read_byte -- SuperIO IO read byte
;
; Input:
;   DX      = IO port base address
;   AL      = Register offset
;
; Output:
;   AL      = Result value
;
; Modified:
;   DX
;
sio_io_read_byte PROC FAR PUBLIC


    push    dx
    
    ; Write reg addr
    add     dx, SIO_DEVIO_ADD
    out     dx, al

    ; Read reg value
    inc     dx
    in      al, dx


    pop     dx

    ret

sio_io_read_byte ENDP


;##############################################################################
; sio_io_write_byte -- SuperIO IO write byte
;
; Input:
;   DX      = IO port base address
;   AL      = Register offset
;   BL      = value to write
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;
sio_io_write_byte PROC FAR PUBLIC


    push    ax
    push    dx


    ; Write reg addr
    add     dx, SIO_DEVIO_ADD
    out     dx, al

    ; Write reg value
    inc     dx
    mov     al, bl
    out     dx, al


    pop     dx
    pop     ax

    ret

sio_io_write_byte ENDP


@CurSeg ENDS

    END


