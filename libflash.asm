;
; libflash.asm -- FlashROM library for x86 assembly
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of FlashROM routines for x86 assembly programming.
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\flash.inc


;------------------------------------------------------------------------------
; libflash code segment
;
libflash SEGMENT USE16 PUBLIC



;----------------------------------- PUBLIC -----------------------------------


;##############################################################################
; flash_read_chipid -- Read FlashROM chip ID and Mac
;
; Input:
;   EBX = CHIP linear Base address
;
; Output:
;   AH  = Manufacturer ID
;   AL  = Chip ID
;
; Modified:
;   CX
;
; Mode:
;   FLAT mode
;
flash_read_chipid PROC FAR PUBLIC


    push    cx


    ; Write sequence
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_START1
    mov     byte ptr [ebx+FLASH_ADDR_CMD2], FLASH_CMD_START2
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_QURYID


    ; Delay
    mov     cx, 10000
    loop    $


    ; Manufacturer ID
    mov     ah, [ebx]


    ; CHIP ID
    mov     al, [ebx+1]


    ; Read sector protect
    mov     dl, [ebx+0ffff2h]


    ; Issue exit command
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_START1
    mov     byte ptr [ebx+FLASH_ADDR_CMD2], FLASH_CMD_START2
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_EXIT


    ; Delay
    mov     cx, 10000
    loop    $


    pop     cx

    ret


flash_read_chipid ENDP



;##############################################################################
; flash_byte_program -- Issue byte program
;
; Input:
;   EBX = CHIP linear Base address
;   CL  = Value to write
;
; Output:
;   None
;
; Modified:
;   EBX
;
; Mode:
;   FLAT mode
;
flash_byte_program PROC FAR PUBLIC


    push    ebx


    push    ebx
    and     ebx, 0ffff0000h

    ; Write sequence
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_START1
    mov     byte ptr [ebx+FLASH_ADDR_CMD2], FLASH_CMD_START2
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_PROGB

    pop     ebx


    ; Program one byte
    mov     byte ptr [ebx], cl


    ; Wait for command completed
    call    flash_wait_togglebit


    pop     ebx

    ret

flash_byte_program ENDP



;##############################################################################
; flash_sector_erase -- Issue sector erase
;
; Input:
;   EBX = CHIP linear Base address
;
; Output:
;   None
;
; Modified:
;   ESI
;   EDI
;   EBX
;
; Mode:
;   FLAT mode
;
flash_sector_erase PROC FAR PUBLIC


    push    ebx


    push    ebx
    and     ebx, 0ffff0000h


    ; Erase sequence
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_START1
    mov     byte ptr [ebx+FLASH_ADDR_CMD2], FLASH_CMD_START2
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_ERASE


    ; Erase type sequence
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_START1
    mov     byte ptr [ebx+FLASH_ADDR_CMD2], FLASH_CMD_START2

    pop     ebx


    ; Erase sector
    and     ebx, 0fffff000h
    mov     byte ptr [ebx], FLASH_CMD_SECTOR


    ; Wait for command completed
    call    flash_wait_togglebit


    pop     ebx

    ret

flash_sector_erase ENDP



;##############################################################################
; flash_block_erase -- Issue block erase
;
; Input:
;   EBX = CHIP linear Base address
;
; Output:
;   None
;
; Modified:
;   EBX
;
; Mode:
;   FLAT mode
;
flash_block_erase PROC FAR PUBLIC

    push    ebx


    ; Erase sequence
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_START1
    mov     byte ptr [ebx+FLASH_ADDR_CMD2], FLASH_CMD_START2
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_ERASE


    ; Erase type sequence
    mov     byte ptr [ebx+FLASH_ADDR_CMD1], FLASH_CMD_START1
    mov     byte ptr [ebx+FLASH_ADDR_CMD2], FLASH_CMD_START2


    ; Issue block erase
    and     ebx, 0ffff0000h
    mov     byte ptr [ebx], FLASH_CMD_BLOCK 


    ; Wait for command completed
    call    flash_wait_togglebit


    pop     ebx

    ret


flash_block_erase ENDP


;##############################################################################
; flash_block_unlock -- Issue unlock block
;
; Input:
;   EBX = CHIP linear Base address
;
; Output:
;   None
;
; Modified:
;   EBX
;
; Mode:
;   FLAT mode
;
flash_block_unlock PROC FAR PUBLIC

    push    ebx


    ; Get base address
    sub     ebx, UNLOCK_OFFSET


    ; Unlock block
    mov     byte ptr [ebx+2], 00h


    pop     ebx

    ret

flash_block_unlock ENDP


;##############################################################################
; flash_wait_togglebit -- Wait for command completed
;
; Input:
;   EBX = Address to check DQ6
;
; Output:
;   None
;
; Modified:
;   EAX
;   EBX
;
; Mode:
;   FLAT mode
;
flash_wait_togglebit PROC FAR PUBLIC


    push    ebx


    ; Read DQ6 and mask bit3 (0000_0100)
    mov     al, [ebx]     
    and     al, 40h


    ; Second time read DQ6
lwt_chk_again:
    mov     ah, [ebx]
    and     ah, 40h


    ; if( AH == AL ) ?
    cmp     ah, al
    jz      lwt_chk_exit


    ; ( AH != AL ) check again
    mov     al, ah
    jmp     lwt_chk_again
    

lwt_chk_exit:
    pop     ebx


    ret

flash_wait_togglebit ENDP


@CurSeg ENDS

    END


