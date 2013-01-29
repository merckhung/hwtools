;
; libpci.asm -- routines releated to PCI interface for x86 assembly
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of pci routines for x86 assembly programming.
;
.586P


INCLUDE include\pci.inc
INCLUDE include\routine.inc
INCLUDE include\mroutine.inc


;
; extern sun-routines
;
routine SEGMENT USE16 PUBLIC

    EXTERN conv_push_ascii:FAR
    EXTERN paste_string:FAR
@CurSeg ENDS



;------------------------------------------------------------------------------
; libpci_data data segment
;
libpci_data SEGMENT USE16 'DATA'


;
; last_idx = Last entry offset
; bott_idx = bottom start entry offset
; curr_lin = Current Line Number
;
last_idx        dw      0
bott_idx        dw      0
curr_lin        db      linetitle


;
; Allocate empty pci information structure array for later use
;
p_pci_info      pci_info_t      50 DUP ({})


; information title and string
info_title  db      'Bus Dev Fun VenID DevID                 Type                  ', 13, 10
            db      '--- --- --- ----- ----- --------------------------------------', 13, 10, 24h
info        db      ' ??  ??  ??  ????  ????                                       ', 13, 10, 24h
;                     00  00  00  0000  0000 <-            38 bytes              ->
;                     1   5   9  13    19    24


;
; PCI base class code record (String Length = 38)
;
BaseClass_tbl   db  'Very old PCI device                   '; 0x00
                db  'Mass storage controller               '; 0x01
                db  'Network controller                    '; 0x02
                db  'Display controller                    '; 0x03
                db  'Multimedia device                     '; 0x04
                db  'Memory controller                     '; 0x05
                db  'Bridge device                         '; 0x06
                db  'Simple communication controllers      '; 0x07
                db  'Base system peripherals               '; 0x08
                db  'Input devices                         '; 0x09
                db  'Docking stations                      '; 0x0A
                db  'Processors                            '; 0x0B
                db  'Serial Bus controllers                '; 0x0C
                db  'Wireless controller                   '; 0x0D
                db  'Intelligent I/O controllers           '; 0x0E
                db  'Satellite communication controllers   '; 0x0F
                db  'Encryption/Decryption controllers     '; 0x10
                db  'Signal Data Processing controllers    '; 0x11
ReservedClass   db  'Reserved                              '; 0x12 <-> 0xFE
OutofClass      db  'Out of pre-defined classes            '; 0xFF



FirstSubClass_idx   db  0, 2, 11, 19, 23, 27, 30, 42, 49, 56, 62, 64, 71, 81, 89, 90, 94, 97

;
; PCI sub class code record (String length = 38)
;
                ; 0x00
SubClass_tbl    db  'Very old PCI device except VGA        '; 0
                db  'VGA-compatible device                 '

                ; 0x01
                db  'SCSI bus controller                   '; 2
                db  'IDE controller                        '
                db  'Floppy disk controller                '
                db  'IPI bus controller                    '
                db  'RAID controller                       '
                db  'ATA controller with ADMA interface    '
                db  'Serial ATA controller                 '
                db  'Serial Attached SCSI(SAS) controller  '
                db  'Other mass storage controller         '

                ; 0x02
                db  'Ethernet controller                   '; 11
                db  'Token Ring controller                 '
                db  'FDDI controller                       '
                db  'ATM controller                        '
                db  'ISDN controller                       '
                db  'WorldFip controller                   '
                db  'PICMG 2.14 Multi Computing            '
                db  'Other network controller              '

                ; 0x03
                db  'VGA-compatible controller             '; 19
                db  'XGA controller                        '
                db  '3D controller                         '
                db  'Other display controller              '

                ; 0x04
                db  'Video device                          '; 23
                db  'Audio device                          '
                db  'Computer telephony device             '
                db  'Other multimedia device               '

                ; 0x05
                db  'RAM                                   '; 27
                db  'Flash                                 '
                db  'Other memory controller               '

                ; 0x06
                db  'Host bridge                           '; 30
                db  'ISA bridge                            '
                db  'EISA bridge                           '
                db  'MCA bridge                            '
                db  'PCI-to-PCI bridge                     '
                db  'PCMCIA bridge                         '
                db  'NuBus bridge                          '
                db  'CardBus bridge                        '
                db  'RACEway bridge                        '
                db  'Semi-transparent PCI-to-PCI bridge    '
                db  'InfiniBand-to-PCI host bridge         '
                db  'Other bridge device                   '

                ; 0x07
                db  'Serial controller                     '; 42
                db  'Parallel port                         '
                db  'Multiport serial controller           '
                db  'Modem                                 '
                db  'GPIB                                  '
                db  'Smart Card                            '
                db  'Other communications device           '

                ; 0x08
                db  'Programmable interrupt controller     '; 49
                db  'DMA controller                        '
                db  'System timer                          '
                db  'RTC controller                        '
                db  'Generic PCI Hot-Plug controller       '
                db  'SD Host controller                    '
                db  'Other system peripheral               '

                ; 0x09
                db  'Keyboard controller                   '; 56
                db  'Digitizer                             '
                db  'Mouse controller                      '
                db  'Scanner controller                    '
                db  'Gameport controller                   '
                db  'Other input controller                '

                ; 0x0A
                db  'Generic docking station               '; 62
                db  'Other type of docking station         '

                ; 0x0B
                db  '386                                   '; 64
                db  '486                                   '
                db  'Pentium                               '
                db  'Alpha                                 '
                db  'PowerPC                               '
                db  'MIPS                                  '
                db  'Co-processor                          '

                ; 0x0C
                db  'IEEE 1394 (FireWire)                  '; 71
                db  'ACCESS.bus                            '
                db  'SSA                                   '
                db  'Universal Serial Bus (USB) host/device'
                db  'Fibre Channel                         '
                db  'SMBus                                 '
                db  'InfiniBand                            '
                db  'IPMI interface                        '
                db  'SERCOS Interface Standard             '
                db  'CANbus                                '

                ; 0x0D
                db  'iRDA compatible controller            '; 81
                db  'Consumer IR controller                '
                db  'RF controller                         '
                db  'Bluetooth                             '
                db  'Broadband                             '
                db  'Ethernet (802.11a - 5GHz)             '
                db  'Ethernet (802.11b - 2.4GHz)           '
                db  'Other type of wireless controller     '

                ; 0x0E
                db  'Intelligent I/O (I2O) Arch. Spec. 1.0 '; 89
                
                ; 0x0F
                db  'TV                                    '; 90
                db  'Audio                                 '
                db  'Voice                                 '
                db  'Data                                  '

                ; 0x10
                db  'Network and computing en/decryption   '; 94
                db  'Entertainment en/decryption           '
                db  'Other en/decryption                   '

                ; 0x11
                db  'DPIO modules                          '; 97
                db  'Performance counters                  '
                db  'Comm. sync. plus time and freq. test  '
                db  'Management card                       '
                db  'Other data acquistion/signal processer'


pci_hdr_scr db  '                                                                                '
pci_hdr_dev db  '   ??????????????????????????????????????                                       '
            db  '                                                                     Merck Hung '
            db  '                                                                                '
            db  '                                                                                '
            db  '   00 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F                           '
pci_hdr     db  '   00 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   10 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   20 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   30 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   40 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   50 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   60 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   70 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   80 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   90 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   A0 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   B0 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   C0 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   D0 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   E0 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '   F0 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ??                           '
            db  '                                                                                '
            db  '                                                                               $'
            


;
; Local definition
;
; offsets of information string
info_bus    equ     1
info_dev    equ     5
info_fun    equ     9
info_vendor equ     13
info_device equ     19
info_type   equ     24

; Lines per page
linetitle   equ     2
linepages   equ     21
lpp         equ     linepages * sizeof_pci_info_t

; Size of PCI database record
sizeof_pcidb_record equ     38


@CurSeg ENDS



;------------------------------------------------------------------------------
; libpci code segment
;
libpci SEGMENT USE16 PUBLIC





;------------------------------------- PUBLIC -------------------------------------


;##############################################################################
; pci_read_config_byte -- read PCI configuration byte
;
; Input :
;   EAX = PCI Base Address
;   BL  = Register offset
;
; Output:
;   BL  = PCI Host Configuration Register
;    
; Modified:
;   EAX
;   EDX
;
pci_read_config_byte PROC FAR PUBLIC


    push    eax
    push    edx
    
    ;
    ; Set Host Configuration Register address
    ;
    movzx   edx, bl
    or      eax, edx
    mov     dx, pci_ioaddr
    out     dx, eax

    ;
    ; Read value of Host Configuration Register
    ;
    mov     dx, pci_iodata
    in      al, dx
    mov     bl, al

    pop     edx
    pop     eax

    ret

pci_read_config_byte ENDP


;##############################################################################
; pci_write_config_byte -- write PCI configuration byte
;
; Input :
;   EAX = PCI Base Address
;   BH  = Register offset
;   BL  = Value
;
; Output:
;   None
;
; Modified:
;   EAX
;   EDX
;
pci_write_config_byte PROC FAR PUBLIC


    push    eax
    push    edx


    ;
    ; Set Host Configuration Register address
    ;
    movzx   edx, bh
    or      eax, edx
    mov     dx, pci_ioaddr
    out     dx, eax

    ;
    ; Read value of Host Configuration Register
    ;
    mov     dx, pci_iodata
    mov     al, bl
    out     dx, al


    pop     edx
    pop     eax

    ret

pci_write_config_byte ENDP



;##############################################################################
; pci_read_config_dword -- read PCI configuration dword
;
; Input :
;   EAX = PCI Base Address
;   BL  = Register offset
;
; Output:
;   EAX = PCI Host Configuration Register
;    
; Modified:
;   EDX
;
pci_read_config_dword PROC FAR PUBLIC


    push    edx
    
    ;
    ; Set Host Configuration Register address
    ;
    movzx   edx, bl
    or      eax, edx
    mov     dx, pci_ioaddr
    out     dx, eax

    ;
    ; Read value of Host Configuration Register
    ;
    mov     dx, pci_iodata
    in      eax, dx

    pop     edx

    ret

pci_read_config_dword ENDP


;##############################################################################
; pci_write_config_dword -- write PCI configuration dword
;
; Input :
;   EAX = PCI Base Address
;   BH  = Register offset
;   ECX = Value to write
;
; Output:
;   None
;
; Modified:
;   EAX
;   EDX
;
pci_write_config_dword PROC FAR PUBLIC


    push    eax
    push    edx


    ;
    ; Set Host Configuration Register address
    ;
    movzx   edx, bh
    or      eax, edx
    mov     dx, pci_ioaddr
    out     dx, eax

    ;
    ; Read value of Host Configuration Register
    ;
    mov     dx, pci_iodata
    mov     eax, ecx
    out     dx, eax


    pop     edx
    pop     eax

    ret

pci_write_config_dword ENDP



;##############################################################################
; scan_pci -- Scan all PCI devices
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   BX
;   CX
;   DX
;   DI
;
scan_pci PROC FAR PUBLIC


    push    eax
    push    bx
    push    cx
    push    dx
    push    di


    ;
    ; Save and then switch to local data segment
    ; Because we will use ES:DI as destination buffer later,
    ; therefore it should be done here
    ;
    ; Note:
    ;   conv_push_ascii will use ES:DI
    ;
    push    ds
    push    es

    ASSUME  DS:libpci_data, ES:libpci_data
    mov     ax, libpci_data
    mov     ds, ax
    mov     es, ax


    ;
    ; di = index
    ; bh = Bus number
    ; bl = Device number
    ; cl = Function number
    ;
    xor     di, di
    xor     bx, bx
    xor     cl, cl


scan_pci_next_loop:

    
    ;
    ; Get PCI device base address
    ; EAX = PCI base address
    ;
    call    cal_pci_baseaddr
    mov     p_pci_info[di].BaseAddr, eax


    ;
    ; Read VendorID and DeviceID from register
    ;
    mov     dx, pci_ioaddr
    out     dx, eax

    xor     eax, eax
    mov     dx, pci_iodata
    in      eax, dx

   
    ;
    ; Save VendorID and DeviceID to variable
    ;
    mov     p_pci_info[di].VendorID, ax

    shr     eax, 16
    mov     p_pci_info[di].DeviceID, ax





    ;
    ; Check valid or invalid?
    ;
    ; if( VendorID == 0 ) {
    ;
    ;   goto scan_pci_prepare_next_scan;
    ; }
    ;
    ; if( DeviceID == 0 ) {
    ;
    ;   goto scan_pci_prepare_next_scan;
    ; }
    ;
    cmp     p_pci_info[di].VendorID, 0ffffh
    jz      scan_pci_prepare_next_scan

    cmp     p_pci_info[di].DeviceID, 0ffffh
    jz      scan_pci_prepare_next_scan





    ;
    ; Store PCI information in structure array
    ;
    mov     p_pci_info[di].BusNo, bh
    mov     p_pci_info[di].DeviceNo, bl
    mov     p_pci_info[di].FunctionNo, cl
    

    ;
    ; Read and Store PCI Class code
    ;
    mov     eax, p_pci_info[di].BaseAddr
    or      eax, 08h                    ; Register 0x8

    mov     dx, pci_ioaddr
    out     dx, eax

    xor     eax, eax
    mov     dx, pci_iodata
    in      eax, dx


    ;
    ; Store values
    ;
    shr     eax, 16 
    mov     p_pci_info[di].BaseClass, ah
    mov     p_pci_info[di].SubClass, al


    ;
    ; Move to next entry
    ;
    add     di, sizeof_pci_info_t


    
scan_pci_prepare_next_scan:

    
    ; function + 1
    inc     cl


scan_pci_prepare_function:
    ;
    ; if( function <= 0x07 ) {
    ;
    ;   goto scan_pci_prepare_device;
    ; }
    ;
    cmp     cl, MAX_FUNNO
    jbe     scan_pci_next_loop

    ; goto next device
    xor     cl, cl              ; cl = 0
    inc     bl                  ; device++


scan_pci_prepare_device:
    ;
    ; if( device <= 0x1F ) {
    ;
    ;   goto scan_pci_prepare_bus;
    ; }
    ;
    cmp     bl, MAX_DEVNO
    jbe     scan_pci_next_loop

    ; goto next bus
    xor     bl, bl              ; bl = 0
    inc     bh                  ; bus++


scan_pci_prepare_bus:
    ;
    ; if( bus < 0xFF ) {
    ;
    ;   goto scan_pci_prepare_completed;
    ; }
    ; else {
    ;
    ;   goto scan_pci_next_loop
    ; }
    ;
    cmp     bh, MAX_BUSNO
    jb      scan_pci_next_loop
    
    
scan_pci_completed:


    ;
    ; Rollback to last entry
    ; Save last_idx
    ;
    sub     di, sizeof_pci_info_t
    mov     word ptr last_idx, di


	;
	; Calculate bottom entry
	;
	; if( last_idx > lpp ) {
	;
	;		bott_idx = last_idx - lpp;
	; }
	; else {
	;
	;		bott_idx = 0;
	; }
	;
	cmp		di, lpp
	ja 		scan_pci_lastidx_above
	
	mov		word ptr bott_idx, 0
	jmp		scan_pci_exit
		
		
scan_pci_lastidx_above:


	; bott_idx = last_idx - lpp
	sub		di, lpp
	mov		word ptr bott_idx, di


scan_pci_exit:


    ; Restore caller's data segment
    pop     es
    pop     ds

    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     eax

    ret


scan_pci ENDP



;##############################################################################
; pci_list_menu -- Display PCI device list menu
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;   CX
;
pci_list_menu PROC FAR PUBLIC


    ; Save registers we will modify later
    push    ax
    push    bx
    push    cx


    ; Switch to local data segment
    push    ds
    push    es

    ASSUME  DS:libpci_data, ES:libpci_data
    mov     ax, libpci_data
    mov     ds, ax
    mov     es, ax


    ; Set text mode 80x25
    mov     ax, 03h
    int     10h


    ; Set default current index = 0
    xor     si, si
    
    
;--------------------------------------------------
pci_list_next_redraw:


    ; Clear Screen
    clear_screen


	; Prepare Index variable
    mov		di, si
    

    ; Get number of Line per Page
    mov     cx, lpp


    ;
    ; Highlight
    ;
    line_highlight2  curr_lin


	; Reset cursor
	set_cursor  0000h


    ; Print PCI information title
 	print_str info_title

    
pci_list_next_record:


    ;
    ; Put PCI information to buffer
    ; DI = index
    ;
    call    combinfo


    ; Print one line
    print_str info


    ;
    ; if( curr_idx == last_idx ) {
    ;
    ;	goto pci_list_page_done;
    ; }
    ;
    cmp		di, last_idx
    jz		pci_list_page_done
    
    
    cmp		cx, 0
    jz		pci_list_page_done
    
       
    ; go to next structure entry
    ; index += sizeof_pci_info_t
    add 	di, sizeof_pci_info_t
    

    ; CX -= sizeof_pci_info_t
    sub     cx, sizeof_pci_info_t


	jmp		pci_list_next_record



pci_list_page_done:

		
    ; Wait for keyboard
    wait_input
    
    cmp     ax, UP
    jz      pci_list_dec_idx

    cmp     ax, DOWN
    jz      pci_list_inc_idx

    cmp     ax, KENTER
    jnz     pci_list_exit

    call    pci_show_header
    jmp     pci_list_next_redraw

    jmp     pci_list_exit


pci_list_inc_idx:

    cmp     curr_lin, linepages + linetitle
    jz      pci_list_inc_idx1

	line_normal2 curr_lin
    inc     curr_lin
    line_highlight2		curr_lin
    jmp     pci_list_page_done

pci_list_inc_idx1:
    cmp     si, bott_idx
    jz      pci_list_page_done

	scrollup_one_line 3, 24
    add     si, sizeof_pci_info_t
    
    ; Only redraw last line
	mov			di, si
    mov			al, sizeof_pci_info_t
    mov			ah, linepages
    mul			ah
    add			di, ax
    set_cursor	1700h
    call    combinfo
    print_str info
		set_cursor	1800h
    
    jmp     pci_list_page_done


pci_list_dec_idx:

    cmp     curr_lin, linetitle
    jz      pci_list_dec_idx1

	line_normal2 curr_lin		
    dec     curr_lin
    line_highlight2		curr_lin
    jmp     pci_list_page_done

pci_list_dec_idx1:
    cmp     si, 0
    jz      pci_list_page_done

	scrolldown_one_line 2, 23
    sub     si, sizeof_pci_info_t
    ; Only redraw first line
	mov			di, si
    set_cursor	0200h
    call    combinfo
    print_str info
    set_cursor	1800h
    
    jmp     pci_list_page_done
    

pci_list_exit:


    ; Caller's data segment
    pop     es
    pop     ds

    pop     cx
    pop     bx
    pop     ax


    ret

pci_list_menu ENDP


;##############################################################################
; cal_pci_baseaddr -- Calculate base address of specify pci configuration
;
; Input :
;   BH  = Bus number
;   BL  = Device number
;   CL  = Function number
;
; Output:
;   EAX  = 32bit PCI Base Address
;
; Modified:
;   EBX
;   ECX
;
cal_pci_baseaddr PROC FAR PUBLIC

    
    push    ebx
    push    ecx


    ; Mask unnecessary bits
    and     ebx, 0000ffffh
    and     ecx, 000000ffh
    
    
    ; Stick Device bits follow the bus one
    shl     bl, 3


    ; Shift to correct bit position
    shl     ebx, (11 - 3)
    shl     ecx, 8


    ; Set Enable bit
    mov     eax, 80000000h


    ; Assemble address
    or      eax, ebx
    or      eax, ecx


    pop     ecx
    pop     ebx

    ret

cal_pci_baseaddr ENDP


;##############################################################################
; pci_show_header -- Display PCI Configuration Header in Hex
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
pci_show_header PROC FAR PUBLIC

    
    push    eax
    push    ebx
    push    cx
    push    dx
    push    di
    push    si


    ; Switch to local data segment
    push    ds
    push    es

    ASSUME  DS:libpci_data, ES:libpci_data
    mov     ax, libpci_data
    mov     ds, ax
    mov     es, ax


    ; Get PCI struct index
    mov     bl, curr_lin
    sub     bl, linetitle
    mov     al, sizeof_pci_info_t
    mul     bl
    add			ax, si
    mov     di, ax


pci_show_header_nxdev:
    ; Read PCI header
    xor     ebx, ebx
    mov     cx, 256 / 4
    mov     si, 6


pci_show_header_loop:
    mov     eax, p_pci_info[di].BaseAddr
    add     eax, ebx
    mov     dx, pci_ioaddr
    out     dx, eax

    mov     dx, pci_iodata
    in      eax, dx

    replace_ascii_str   pci_hdr, 2, si

    add     si, 3
    mov     al, ah
    replace_ascii_str   pci_hdr, 2, si

    add     si, 3
    shr     eax, 16
    replace_ascii_str   pci_hdr, 2, si

    add     si, 3
    mov     al, ah
    replace_ascii_str   pci_hdr, 2, si

    add     si, 3
    add     bx, 4


    ;
    ; Check new line
    ;
    cmp     bx, 0
    jz      pci_show_header_nl

    push    bx
    mov     ax, bx
    mov     bl, 16
    div     bl
    pop     bx

    cmp     ah, 0
    jnz     pci_show_header_nl

    ; go to next line
    add     si, 32
    

pci_show_header_nl:
    dec     cx
    jnz     pci_show_header_loop


    ;
    ; Place Subclass Text
    ;
    place_sctext    pci_hdr_dev, 3, sizeof_pci_nametext
    

    mov     ch, 6
    mov     cl, 6

pci_show_header_redraw:


    ; Clear Screen
    clear_screen    1fh


    ;
    ; Set color -- number field
    ;
    set_screen      1eh, 5, 3, 5, 52
    set_screen      1eh, 6, 3, 21, 4


    ;
    ; Set color -- value field
    ;
    set_screen      17h, 6, 6, 21, 52


    ;
    ; Set color -- gigabyte
    ;
    set_screen      1ch, 2, 50, 2, 78


    ;
    ; Set field highlight
    ;
    set_field2       1fh


	; Reset cursor
	set_cursor      0000h


    ; Print PCI information title
    print_str   pci_hdr_scr






    ;
    ; Handle user key inout
    ;
pci_sh_next_input:
    wait_input


    cmp     ax, PGUP
    jz      pci_sh_dec_idx

    cmp     ax, PGDN
    jz      pci_sh_inc_idx

    cmp     ax, UP
    jz      pci_sh_dec_line

    cmp     ax, DOWN
    jz      pci_sh_inc_line

    cmp     ax, RIGHT
    jz      pci_sh_inc_col

    cmp     ax, LEFT
    jz      pci_sh_dec_col

    jmp     pci_show_header_exit
    ;---------------------------------------


pci_sh_dec_idx:
    cmp     di, 0
    jz      pci_sh_next_input

    sub     di, sizeof_pci_info_t
    jmp     pci_show_header_nxdev

pci_sh_inc_idx:
    cmp     di, last_idx
    jz      pci_sh_next_input

    add     di, sizeof_pci_info_t
    jmp     pci_show_header_nxdev


pci_sh_dec_line:
    cmp     ch, 6
    jz      pci_sh_next_input

		set_field2       17h
    dec     ch
    set_field2       1fh
    jmp     pci_sh_next_input

pci_sh_inc_line:
    cmp     ch, 21
    jz      pci_sh_next_input

	set_field2       17h
    inc     ch
    set_field2       1fh
    jmp     pci_sh_next_input


pci_sh_dec_col:
    cmp     cl, 6
    jz      pci_sh_next_input

	set_field2       17h
    sub     cl, 3
    set_field2       1fh
    jmp     pci_sh_next_input

pci_sh_inc_col:
    cmp     cl, 51
    jz      pci_sh_next_input

	set_field2       17h
    add     cl, 3
    set_field2       1fh
    jmp     pci_sh_next_input



pci_show_header_exit:

    ; Restore caller's env.
    pop     es
    pop     ds

    pop     si
    pop     di
    pop     dx
    pop     cx
    pop     ebx
    pop     eax

    ret

pci_show_header ENDP



;------------------------------------- PRIVATE -------------------------------------



;##############################################################################
; combinfo -- Combine Information string into buffer
;
; Input :
;   DI   = Index of PCI information structure array
;
; Output:
;   None
;
; Modified:
;   EAX
;   BX
;   CX
;   DI
;   SI
;
combinfo PROC NEAR PRIVATE


    push    eax
    push    bx
    push    cx
    push    di
    push    si

    
    ;
    ; Because DI will be used by conv_push_ascii,
    ; so we use bx here
    ;
    mov     bx, di


    xor     eax, eax
    ;
    ; Handle Bus number
    ;
    mov     al, p_pci_info[bx].BusNo
    replace_ascii_str info, 2, info_bus
		

    ;
    ; Handle Device number
    ;
    mov     al, p_pci_info[bx].DeviceNo
    replace_ascii_str info, 2, info_dev


    ;
    ; Handle Function number
    ;
    mov     al, p_pci_info[bx].FunctionNo
    replace_ascii_str info, 2, info_fun


    xor     eax, eax
    ;
    ; Handle VendorID
    ;
    mov     ax, p_pci_info[bx].VendorID
    replace_ascii_str info, 4, info_vendor



    ;
    ; Handle DeviceID
    ;
    mov     ax, p_pci_info[bx].DeviceID
    replace_ascii_str info, 4, info_device


    ;
    ; Handle Base & Sub Class Code
    ;
    mov     di, bx
    place_sctext    info, info_type, sizeof_pci_nametext


    pop     si
    pop     di
    pop     cx
    pop     bx
    pop     eax

	ret

combinfo ENDP


;##############################################################################
; get_classtext -- Return pointer of class string by Class value
;
; Input :
;   AH  = Subclass binary value
;   AL  = Baseclass binary value
;   BL  = 0: Baseclass string, 1: Subclass string
;
; Output:
;   BX  = Source string pointer(Not offset)
;
; Modified:
;   None
;
get_classtext PROC NEAR PRIVATE


    ASSUME  DS:libpci_data


    ;
    ; Check range of baseclass code
    ;
    cmp     al, 0ffh
    jz      get_classtext_ffh


    cmp     al, 011h
    ja      get_classtext_reserved


    test    bl, 1
    jnz     get_classtext_subclass


get_classtext_baseclass:

    ;
    ; Calculate offset of base class
    ; AL = Base Class
    ;
    mov     bl, sizeof_pcidb_record
    mul     bl                          ; AX = AL * BL
    mov     bx, offset BaseClass_tbl
    add     bx, ax                      ; get offset of baseclass string

    jmp     get_classtext_exit



get_classtext_subclass:


    ;
    ; Search offset vector from index table
    ;
    movzx   bx, al
    add     bx, offset FirstSubClass_idx


    ;
    ; if( subclass == 0x80 ) {
    ;
    ;   index++;
    ;   vector = tbl[ index ];
    ;   vector--;
    ;   offset = vector * size;
    ; }
    ;
    cmp     ah, 080h
    jnz     get_classtext_generic

    inc     bx                          ; index++
    mov     al, [bx]                    ; vector = tbl[ index ];
    dec     al                          ; vector--

    jmp     get_classtext_getsub
    xor     ah, ah
    

get_classtext_generic:

    mov     al, [bx]                    ; get offset vector
    add     al, ah
    

get_classtext_getsub:


    ;
    ; Calculate offset of subclass
    ; and then point to first element of subclass text
    ;
    ; AL = offset vector
    ; AH = subclass offset
    ;
    mov     bl, sizeof_pcidb_record
    mul     bl                          ; offset = vector * size


    ;
    ; get subclass entry
    ;
    mov     bx, offset SubClass_tbl
    add     bx, ax                      ; subclass code in AH


    jmp     get_classtext_exit


get_classtext_reserved:

    mov     bx, offset ReservedClass
    jmp     get_classtext_exit


get_classtext_ffh:

    mov     bx, offset OutofClass
    

get_classtext_exit:

    ret


get_classtext ENDP


@CurSeg ENDS
    END
