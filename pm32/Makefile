ASSEMBLER			=	ml.exe
ASSEMBLE_FLAGS		=	/Fm /Fl
COMMOBJS			=	../routine.asm


all: above4g


above4g:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DPSE_SUPPORT $@.asm $(COMMOBJS) libpm.asm


clean:
	rm -rf *.map *.exe *.EXE *.obj *.lst *.MAP *.STS *.CV4 *.sts *.cv4 DELETED


