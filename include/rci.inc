;
; rci.inc -- Header file related to RCI routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is the header file of Dell Remote Configuration Interface
;


RCI_ENTRY_VER       EQU     00h
RCI_SIGNATURE       EQU     '_CR_'
RCI_MAJOR_VER       EQU     01h
RCI_MINOR_VER       EQU     02h
RCI_BBS_VER         EQU     0101h

RCI_ENTRY_BOUND     EQU     010h

RCI_TABLE_LEN	    EQU	    80000h

RCI_ENTRY_SIGNATURE EQU     'ICR$'



;
; RCI Entry Structure
;
rciEntryStruc STRUCT

    rci_anchor      DB      4 DUP(0)
    rciep_len       DB      Sizeof_rciEntryStruc
    rciep_chksm     DB      ?
    rciep_ver       DB      RCI_ENTRY_VER
    rci_addr        DD      ?

rciEntryStruc ENDS
Sizeof_rciEntryStruc	EQU	SIZEOF	rciEntryStruc



;
; RCI Common Structre Header
;
rciCommHdrStruc STRUCT

    hdrtype         DW      ?
    reserved        DW      ?
    hdrlen          DW      ?

rciCommHdrStruc ENDS



;
; Structure Type 0: The RCI Table Global Header
;
rciType0Struc STRUCT

    hdrtype         DW      0000h
    reserved0       DW      0
    hdrlen          DW      ?
    
    rci_signature   DD      RCI_SIGNATURE
    reserved1       DW      0000h
    change_flg      DD      ?
    err_code        DD      ?
    rci_maj_rev     DB      RCI_MAJOR_VER
    rci_min_rev     DB      RCI_MINOR_VER
    strucs_num      DW      ?
    rci_len         DD      ?
    rci_chksm       DW      ?

rciType0Struc ENDS
Sizeof_rciType0Struc	EQU	SIZEOF	rciType0Struc



;
; Structure Type 1: Dell Extended BBS Structure
;
rciType1Struc STRUCT

    hdrtype         DW      0001h
    reserved0       DW      0
    hdrlen          DW      ?

    chksm           DW      ?
    reserved1       DD      0
    modified_flgs   DD      ?
    
    bbs_ver         DW      RCI_BBS_VER
    ipl_num         DB      ?
    max_ipl_num     DB      ?
    ipl_entry_size  DB      ?
    bcv_num         DB      ?
    max_bcv_num     DB      ?
    bcv_entry_size  DB	    ?
    ext_entry_size  DB      ?
    oneshot_dev     DW      ?

    ;
    ; Enumerated:
    ; ipl_prioritylist  max_ipl_num
    ; ipl_skiplist      max_ipl_num
    ; ipl_table         max_ipl_num * IPL_ENTRY_SIZE
    ; ipl_dell_ext      max_ipl_num * EXT_ENTRY_SIZE
    ; bcv_prioritylist  max_bcv_num
    ; bcv_table         max_bcv_num * BCV_ENTRY_SIZE
    ; bcv_dell_ext      max_bcv_num * EXT_ENTRY_SIZE
    ;

rciType1Struc ENDS
Sizeof_rciType1Struc	EQU	SIZEOF	rciType1Struc



;
; Structure Type 2: Passwords Structure
;
rciType2Struc STRUCT

    hdrtype         DW      0002h
    reserved0       DW      0
    hdrlen          DW      ?

    chksm           DW      ?
    reserved1       DD      0
    modified_flgs   DD      ?

    usr_pwd_max     DB      ?
    usr_pwd_attr    DW      ?
    usr_pwd_chksm   DB      ?
    admin_pwd_max   DB      ?
    admin_pwd_attr  DW      ?
    admin_pwd_chksm DB      ?

    ;
    ; Enumerated:
    ; old_usr_pwd       usr_pwd_max
    ; new_usr_pwd       usr_pwd_max
    ; old_admin_pwd     admin_pwd_max
    ; new_admin_pwd     admin_pwd_max
    ; usr_pwd_hash      DD
    ; admin_pwd_hash    DD
    ;

rciType2Struc ENDS
Sizeof_rciType2Struc	EQU	SIZEOF	rciType2Struc



;
; Structure Type 3: Front Panel LCD Strings Structure
;
rciType3Struc STRUCT

    hdrtype         DW      0003h
    reserved0       DW      0
    hdrlen          DW      ?

    chksm           DW      ?
    reserved1       DD      0
    modified_flgs   DD      ?

    lcd_str1_max    DB      ?
    lcd_str1_chksm  DB      ?
    lcd_str2_max    DB      ?
    lcd_str2_chksm  DB      ?
    reserved2       DW      0

    ;
    ; Enumerated:
    ; lcd_user_str1     lcd_str1_max
    ; lcd_user_str2     lcd_str2_max
    ;

rciType3Struc ENDS
Sizeof_rciType3Struc	EQU	SIZEOF	rciType3Struc



;
; Structure Type 4: CMOS Default Values Structure
;
rciType4Struc STRUCT

    hdrtype         DW      0004h
    reserved0       DW      0
    hdrlen          DW      ?

    chksm           DW      ?
    reserved1       DD      0
    modified_flgs   DD      ?

    cmos_def_tables_count   DB  ?
    chksm_range_entry_size  DB  ?
    num_chksm_ranges        DB  ?
    cmos_clr_entry_size     DB  ?
    num_clr_ranges          DB  ?

    ;
    ; Enumerated:
    ; chksm_ranges_table    chksm_range_entry_size * num_chksm_ranges
    ; cmos_def_table_1      TABLE_1_SIZE
    ; .
    ; .
    ; .
    ; cmos_def_table_N      TABLE_N_SIZE
    ;

rciType4Struc ENDS
Sizeof_rciType4Struc	EQU	SIZEOF	rciType4Struc



INSTALL_RCI MACRO ???types:VARARG


alignedSegment SEGMENT

	ALIGN		16
	rciEntry    	rciEntryStruc	{ '$RCI', Sizeof_rciEntryStruc, 0, RCI_ENTRY_VER, 0 }
	PUBLIC		rciEntry
    
alignedSegment ENDS


	rciInstalledTypes = 1
	rciInstalledSum = 0
	FOR	arg, <???types>

		IFIDNI <arg>, <TYPE0>

            		rciInstalledTypes = rciInstalledTypes OR 1

        	ELSEIFIDNI <arg>, <TYPE1>

           		rciInstalledTypes = rciInstalledTypes OR 2
           		rciInstalledSum = rciInstalledSum + 1

        	ELSEIFIDNI <arg>, <TYPE2>

			rciInstalledTypes = rciInstalledTypes OR 4
			rciInstalledSum = rciInstalledSum + 1

		ELSEIFIDNI <arg>, <TYPE3>

			rciInstalledTypes = rciInstalledTypes OR 8
			rciInstalledSum = rciInstalledSum + 1

		ELSEIFIDNI <arg>, <TYPE4>

			rciInstalledTypes = rciInstalledTypes OR 16
			rciInstalledSum = rciInstalledSum + 1

		ELSE
			.ERR <INSTALL_RCI: Unknown RCI Table Type specified>
		ENDIF
	ENDM


	PUBLIC	rciInstalledTypes
	PUBLIC	rciInstalledSum

ENDM    ; End INSTALL_RCI


