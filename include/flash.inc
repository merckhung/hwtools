;
; flash.inc -- Header file related to flashrom tool
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


;
; SST 49LF008A 8Mbit Firmware Hub information
;
MANID           EQU     0bfh
CHIPID          EQU     05ah
BLK_NUM         EQU     16


;
; 8Mb_ROM base address
;
ROM_00          EQU     0fff00000h
ROM_01          EQU     0ffe00000h
ROM_02          EQU     0ffd00000h
ROM_03          EQU     0ffc00000h
ROM_04          EQU     0ffb00000h
ROM_05          EQU     0ffa00000h
ROM_06          EQU     0ff900000h
ROM_07          EQU     0ff800000h
ROM_08          EQU     0ff700000h
ROM_09          EQU     0ff600000h

ROM_SIZE        EQU     000100000h
BLK_SIZE        EQU     10000h
UNLOCK_OFFSET   EQU     000400000h


;
; FlashROM commands
;
FLASH_ADDR_CMD1     EQU     5555h
FLASH_ADDR_CMD2     EQU     2aaah
FLASH_ADDR_DATA     EQU     0000h

FLASH_CMD_START1    EQU     0aah
FLASH_CMD_START2    EQU     055h

FLASH_CMD_QURYID    EQU     090h
FLASH_CMD_ERASE     EQU     080h
FLASH_CMD_PROGB     EQU     0a0h
FLASH_CMD_EXIT      EQU     0f0h

FLASH_CMD_SECTOR    EQU     030h
FLASH_CMD_BLOCK     EQU     050h


