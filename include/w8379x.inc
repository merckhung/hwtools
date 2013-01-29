;
; w8379x.inc -- Macros related to w8379x.asm
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


;##############################################################################
; w8379x_fan_rpm -- Calculate Fan RPM and push result into buffer
;
; Input :
;   COU     = COUNT register offset
;   DIV     = DIVISOR register offset
;   STRP    = String pointer to push result
;   OFFSET  = Offset in pointer
;   MSB     = MSB or not
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;
w8379x_fan_rpm MACRO COUNTER, DIVISOR, STRP, OFFSET, MSB

    LOCAL   got_divisor, print_rpm

    push    eax
    push    bx
    push    edx


    ; Read Fan Count
    mov     ah, slave_addr
    mov     al, COUNTER
    call    i2c_byte_read
    mov     bl, al

    xor     edx, edx
    xor     eax, eax
    cmp     bl, 0ffh
    jz      print_rpm
    

    ; Read Fan Divisor
    mov     ah, slave_addr
    mov     al, DIVISOR
    call    i2c_byte_read


IFB <MSB>
    and     al, 03h
ELSE
    and     al, 30h
    shr     al, 4
ENDIF



    cmp     al, 0
    jnz     @f

    mov     al, 1
    jmp     got_divisor

@@:
    cmp     al, 1
    jnz     @f

    mov     al, 2
    jmp     got_divisor

@@:
    cmp     al, 2
    jnz     @f

    mov     al, 4
    jmp     got_divisor

@@:
    cmp     al, 3
    jnz     @f

    mov     al, 8
    jmp     got_divisor

@@:
    cmp     al, 4
    jnz     @f

    mov     al, 16
    jmp     got_divisor

@@:
    cmp     al, 5
    jnz     @f

    mov     al, 32
    jmp     got_divisor

@@:
    cmp     al, 6
    jnz     @f

    mov     al, 64
    jmp     got_divisor

@@:
    cmp     al, 7
    jnz     @f

    mov     al, 128
    jmp     got_divisor

@@:
    ; Default 8
    mov     al, 8


got_divisor:

    ; Count * Divisor = AX = BX
    mul     bl
    mov     bx, ax


    ; DX:AX = 1.35 * 10^6
    ; RPM = DX:AX / BX
    ; AX = Fan RPM
    mov     dx, 14h
    mov     ax, 9970h
    div     bx


    ; Convert AX to ASCII of Dec number.
    bin_to_bcd  8


print_rpm:
    ; Push result into buffer
    replace_ascii_str STRP, 6, OFFSET
    

    pop     edx
    pop     bx
    pop     eax

ENDM



;##############################################################################
; w8379x_voltage -- Calculate Voltage and push result into buffer
;
; Input :
;   REGOFF  = voltage register offset
;   MULTI   = multiplicator
;   PG      = Point digit of offset
;   STRP    = String pointer to push result
;   OFFSET  = Offset in String pointer
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;
w8379x_voltage MACRO REGOFF, MULTI, PG, STRP, OFFSET


    push    eax
    push    bx


    ; Read Voltage
    mov     ah, slave_addr
    mov     al, REGOFF
    call    i2c_byte_read


    ; result * MUL (eg. 8, 2688)
    movzx   ax, al
    mov     bx, MULTI
    mul     bx


    ; convert to BCD
    bin_to_bcd  8
    
    
    ;
    ; push result
    ;
    push    eax

    shr     eax, PG * 4
    replace_ascii_str STRP, 1, OFFSET

    pop     eax
    shr     eax, 4
    replace_ascii_str STRP, 2, OFFSET + 2


    pop     bx
    pop     eax

ENDM


;##############################################################################
; w8379x_divisor -- Read divisor value and push into buffer
;
; Input :
;   REGOFF  = Register Offset
;   STRP    = String pointer to push result
;   OFF     = Offset of string pointer to push result
;   MSB     = MSB or not
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;
w8379x_divisor MACRO REGOFF, STRP, OFF, MSB

    LOCAL   got_divisor

    push    ax
    push    bx


    mov     ah, slave_addr
    mov     al, REGOFF
    call    i2c_byte_read

IFB <MSB>
    and     al, 03h
ELSE
    and     al, 30h
    shr     al, 4
ENDIF

    cmp     al, 0
    jnz     @f

    mov     al, 1
    jmp     got_divisor

@@:
    cmp     al, 1
    jnz     @f

    mov     al, 2
    jmp     got_divisor

@@:
    cmp     al, 2
    jnz     @f

    mov     al, 4
    jmp     got_divisor

@@:
    cmp     al, 3
    jnz     @f

    mov     al, 8
    jmp     got_divisor

@@:
    cmp     al, 4
    jnz     @f

    mov     al, 16
    jmp     got_divisor

@@:
    cmp     al, 5
    jnz     @f

    mov     al, 32
    jmp     got_divisor

@@:
    cmp     al, 6
    jnz     @f

    mov     al, 64
    jmp     got_divisor

@@:
    cmp     al, 7
    jnz     @f

    mov     al, 128
    jmp     got_divisor

@@:
    ; Default 8
    mov     al, 8


got_divisor:
    replace_ascii_str   STRP, 1, OFF


    pop     bx
    pop     ax

ENDM


;##############################################################################
; w8379x_sensor_8comp -- Get and convert sensor value to BCD
;
; Input:
;   REGOFF  = Temperature sensor register offset
;   STRP    = String pointer
;   OFF     = Offset in buffer
;   ADJOFF  = Sub adjust temperature value
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;
w8379x_sensor_8comp MACRO REGOFF, STRP, OFF, ADJOFF


    push    ax
    push    bx


    ; Read sensor value
    mov     ah, slave_addr
    mov     al, REGOFF
    call    i2c_byte_read
    mov     bl, al


IFNB <ADJOFF>
    ; Read offset temp
    mov     ah, slave_addr
    mov     al, ADJOFF
    call    i2c_byte_read

    ; Meaured - Offset temp
    xor     bh, bh
    xor     ah, ah
    sub     bx, ax
    mov     ax, bx
ELSE
    and     ax, 0ffh
    mov     al, bl
ENDIF


    bin_to_bcd 2
    replace_ascii_str STRP, 3, OFF


    pop     bx
    pop     ax

ENDM


;##############################################################################
; w8379x_sensor_9comp -- Get and convert sensor value to BCD
;
; Input:
;   REGOFF  = Temperature sensor register offset
;   DEGOFF  = Deg register offset
;   STRP    = String pointer
;   OFF     = Offset in buffer
;   ADJOFF  = Plus adjust temperature value
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;
w8379x_sensor_9comp MACRO REGOFF, DEGOFF, STRP, OFF, ADJOFF


    LOCAL   ws9_not_deg5


    push    ax
    push    bx


    ; Read sensor value
    mov     ah, slave_addr
    mov     al, REGOFF
    call    i2c_byte_read

    ; result / 2
    ;shr     al, 1
    ;and     ax, 0ffh
    mov     bl, al


    ; Read deg
    mov     ah, slave_addr
    mov     al, DEGOFF
    call    i2c_byte_read

    shr     al, 7
    and     al, 1
    cmp     al, 0
    jz      ws9_not_deg5    

    mov     al, 5

ws9_not_deg5:
    replace_ascii_str STRP, 1, OFF + 4

    
IFNB <ADJOFF>
    ; Read offset temp
    mov     ah, slave_addr
    mov     al, ADJOFF
    call    i2c_byte_read

    ; Meaured - Offset temp
    xor     bh, bh
    xor     ah, ah
    sub     bx, ax
    mov     ax, bx
ELSE
    and     ax, 0ffh
    mov     al, bl
ENDIF


    bin_to_bcd 2
    replace_ascii_str STRP, 3, OFF


    pop     bx
    pop     ax

ENDM



;##############################################################################
; w8379x_enable_smartfan -- Initialize W8379x to enable SmartFAN II function
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
w8379x_enable_smartfan MACRO


    ;-----------------------------------
    ; Initialize W8379x HW Monitor Chip
    ;-----------------------------------
    ;
    ; Enable Fan6
    ;
    i2cset 02fh, 04bh, 0c3h
    ;-----------------------------
    ;
    ; Set divisor to 8(Fan1, 2, 3)
    ;
    i2cset 02fh, 047h, 0bbh
    i2cset 02fh, 05bh, 0bbh
    i2cset 02fh, 05ch, 0bbh
    ;-----------------------------
    ;
    ; Set Diode Selection
    ;
    i2cset 02fh, 059h, 030h
    ;-----------------------------
    ; 
    ; Two Time Interrupt mode
    ;
    i2cset 02fh, 04ch, 051h
    ;-----------------------------
    ;
    ; Enable VBAT monitor
    ;
    i2cset 02fh, 05dh, 0c1h
    ;-----------------------------
    ;
    ; Temperature offset
    ;
    i2cset 02fh, 090h, 000h
    i2cset 02fh, 091h, 000h
    i2cset 02fh, 092h, 000h
    ;-----------------------------
    ;
    ; Set Fan Pre-Scale
    ;
    i2cset 02fh, 080h, 081h
    i2cset 02fh, 082h, 081h
    i2cset 02fh, 093h, 081h
    i2cset 02fh, 0a0h, 081h
    i2cset 02fh, 0a1h, 081h
    i2cset 02fh, 0a2h, 081h



    ;-------------------------------------------
    ; Enable Fan1 & Fan2 Smart FAN II functions
    ;-------------------------------------------
    ;
    ; Enable SmartFAN II function
    ;
    i2cset 02fh, 084h, 2ah
    ;-----------------------------
		;
		; Sync FAN1 to Temp1 and FAN2 to Temp2 ...etc.
		;
    i2cset 02fh, 081h, 091h
    i2cset 02fh, 083h, 0a1h
    i2cset 02fh, 094h, 0b1h		
    ;-----------------------------
    ;
    ; Set Fan Target Temperature(30C)
    ;
    i2cset 02fh, 085h, 01eh
    i2cset 02fh, 086h, 01eh
    i2cset 02fh, 096h, 01eh
    ;-----------------------------
    ;
    ; Set Tolerance of Fan Target Temp(+-2C)
    ;
    i2cset 02fh, 087h, 022h
    i2cset 02fh, 097h, 002h
    ;-----------------------------
    ;
    ; Set Fan Stop/Start Duty Cycle level
    ;
    i2cset 02fh, 088h, 031h
    i2cset 02fh, 089h, 031h
    i2cset 02fh, 098h, 031h
    ;-----------------------------
    ;
    ; Set Fan1 temperature points(40, 60, 80C)
    ;
    i2cset 02fh, 0e3h, 028h
    i2cset 02fh, 0e4h, 03ch
    i2cset 02fh, 0e5h, 050h
    ;-----------------------------
    ;
    ; Set Fan2 temperature points(40, 60, 80C)
    ;
    i2cset 02fh, 0e6h, 028h
    i2cset 02fh, 0e7h, 03ch
    i2cset 02fh, 0e8h, 050h
    ;-----------------------------
    ;
    ; Set Fan3 temperature points(40, 60, 80C)
    ;
    i2cset 02fh, 0e9h, 028h
    i2cset 02fh, 0eah, 03ch
    i2cset 02fh, 0ebh, 050h
    ;
    ;-----------------------------
    ;
    ; Set Fan Duty Cycle 2/3
    ;
    i2cset 02fh, 0e0h, 045h
    i2cset 02fh, 0e1h, 045h
    i2cset 02fh, 0e2h, 045h
    ;-----------------------------

ENDM



;##############################################################################
; w8379x_showinfo -- Show W8379x information during testing
;
w8379x_showinfo MACRO


    ;
    ; Get Current temp
    ;
    w8379x_sensor_8comp 27h, temp_msg, 15
    w8379x_sensor_9comp 0c0h, 0c1h, temp_msg, 30
    w8379x_sensor_9comp 0c8h, 0c9h, temp_msg, 45


    ;
    ; Get actual temp
    ; 
    w8379x_sensor_8comp 27h, act_temp_msg, 15, 90h
    w8379x_sensor_9comp 0c0h, 0c1h, act_temp_msg, 30, 91h
    w8379x_sensor_9comp 0c8h, 0c9h, act_temp_msg, 45, 92h


    ;
    ; Get Offset temp
    ;
    w8379x_sensor_8comp 90h, off_temp_msg, 15
    w8379x_sensor_8comp 91h, off_temp_msg, 30
    w8379x_sensor_8comp 92h, off_temp_msg, 45


    ;
    ; Print out temp information
    ;
    print_str   temp_msg



    ; Fan1-3 target temperature information
    w8379x_sensor_8comp 085h, fan1_stept_msg, 12
    w8379x_sensor_8comp 0e3h, fan1_stept_msg, 24
    w8379x_sensor_8comp 0e4h, fan1_stept_msg, 36
    w8379x_sensor_8comp 0e5h, fan1_stept_msg, 48

    w8379x_sensor_8comp 086h, fan2_stept_msg, 12
    w8379x_sensor_8comp 0e6h, fan2_stept_msg, 24
    w8379x_sensor_8comp 0e7h, fan2_stept_msg, 36
    w8379x_sensor_8comp 0e8h, fan2_stept_msg, 48

    w8379x_sensor_8comp 096h, fan3_stept_msg, 12
    w8379x_sensor_8comp 0e9h, fan3_stept_msg, 24
    w8379x_sensor_8comp 0eah, fan3_stept_msg, 36
    w8379x_sensor_8comp 0ebh, fan3_stept_msg, 48


    ;
    ; Print out
    ;
    print_str   fan1_stept_msg


    ;
    ; RPM information
    ;
    w8379x_fan_rpm  28h, 47h, fan_rpm_msg, 6
    w8379x_fan_rpm  29h, 47h, fan_rpm_msg, 24, 1
    w8379x_fan_rpm  2ah, 5bh, fan_rpm_msg, 42
    print_str   fan_rpm_msg

ENDM


;##############################################################################
; w8379x_test_loop -- W8379x test MACRO
;
w8379x_test_loop MACRO PREFIX, STEP

    clear_screen
    set_cursor  0000h
    mov         ax, cx
    dec         ax
    print_ascii_str test_time, 1, 11
    print_str   PREFIX
    mov         dl, STEP

    call        w8379x_interval
ENDM


;##############################################################################
; w8379x_cul_temp_offset -- Calculate temperature offset value
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;
w8379x_cul_temp_offset MACRO TEMPREG, OFFREG, TSTEPREG, NSTEPREG, SAVEVALUE


    push    ax
    push    bx


    ; Get offset
    mov     bh, SAVEVALUE


    ; Get current temp
    i2cget  02fh, TEMPREG


    ; Current - Offset = Actual
    sub     al, bh
    mov     bh, al


    ;
    ; BH = Actual temp
    ;


    ; get Target step
    i2cget  02fh, TSTEPREG
    mov     bl, al


    ; get temp to S2
    sub     al, bh
    mov     bh, al


    ;
    ; BH = actual temp to S2
    ; BL = S2 temp
    ;

    
    ; get Fan1 S3
    i2cget  02fh, NSTEPREG


    ;
    ; AL = S3 temp
    ; BL = S2 temp
    ;


    ; get range
    sub     al, bl

    ;
    ; AL = S3 - S2
    ; AL / 2 = Average
    ;
    ; get average (range / 2)
    shr     al, 1


    ;
    ; BH = Actual temp to S2
    ; AL = Average temp
    ;
    ; Calculate new offset temp
    ;
    add     al, bh
    and     al, 01fh
    mov     SAVEVALUE, al


    pop     bx
    pop     ax

ENDM



