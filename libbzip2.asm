;
; libbzip2.asm -- Bzip2 Routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P



INCLUDE include\mroutine.inc
INCLUDE include\bzip2.inc



;------------------------------------------------------------------------------
; libbzip2 code segment
;
libbzip2 SEGMENT USE16 PUBLIC



;----------------------------------- PUBLIC -----------------------------------



IF BZIP2_COMP EQ 1



;##############################################################################
; Bzip2Compress -- Compress a range of memory become bzip2 image
;
; Input:
;   ESI -- Start address of memory to be compress
;   ECX -- Length of memory to be compress
;   EDI -- Start address of compressed bzip2 image
;
; Output:
;   ECX -- Length of compressed bzip2 image
;
; Modified:
;   AX
;   DX
;
Bzip2Compress PROC FAR PUBLIC

    ret

Bzip2Compress ENDP



;##############################################################################
; Bzip2HuffmanMakeCodeLength -- Huffman's encode, make code length
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
Bzip2HuffmanMakeCodeLength PROC NEAR PUBLIC

    ret

Bzip2HuffmanMakeCodeLength ENDP



;##############################################################################
; Bzip2HuffmanAssignCodes -- Huffman's encode, assign codes
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
Bzip2HuffmanAssignCodes PROC NEAR PUBLIC

    ret

Bzip2HuffmanAssignCodes ENDP



ENDIF   ; IF BZIP2_COMP EQ 1



IF BZIP2_DECOMP EQ 1



;##############################################################################
; Bzip2Decompress -- Decompress a compressed bzip2 image to a destination
;
; Input:
;   ESI -- Start address of bzip2 image
;   ECX -- Length of bzip2 image
;   EDI -- Start address of decompressed plain memory
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;
Bzip2Decompress PROC FAR PUBLIC

    ret

Bzip2Decompress ENDP



;##############################################################################
; Bzip2HuffmanCreateDecodeTables -- Huffman's encode, create decode table
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
Bzip2HuffmanCreateDecodeTables PROC NEAR PUBLIC

    ret

Bzip2HuffmanCreateDecodeTables ENDP



ENDIF   ; IF BZIP2_DECOMP EQ 1



libbzip2 ENDS

    END



