==============================================================================

 Copyright (C) 2007 - 2009, Merck Hung

 HWTools --
    This is a collection of tools related to BIOS development written by 
    Merck Hung

 Author : Merck Hung <merckhung@gmail.com>

==============================================================================









==============================================================================
libflat -- FLAT mode routines

    Routines related to FLAT enter, exit, console print, and cursor setting.


-<EXTERN Example>-------------------------------------------------------------

libflat SEGMENT USE16 PUBLIC

    EXTERN __enter_flat_mode:FAR
    EXTERN __exit_flat_mode:FAR
    EXTERN sys_cls:FAR
    EXTERN sys_print:FAR
@CurSeg ENDS



-<PUBLIC interface>-----------------------------------------------------------


    enter_flat_mode <MACRO OF __enter_flat_mode>
        Setup GDT, disable interrupt, enable A20, enable protected mode, setup
        segment ds, es and then disable protected mode, then jump to enter
        FLAT mode.


    exit_flat_mode  <MACRO OF __exit_flat_mode>
        Disable A20, Enable

    
    flat_print      <MACRO OF sys_print>
        Print string on console


    sys_cls
        Clear screen and then reset cursor




-<PRIVATE interface>----------------------------------------------------------

    __enter_flat_mode
        See above

    __exit_flat_mode
        See above

    sys_print
        See above












