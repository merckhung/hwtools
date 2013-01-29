ASSEMBLER			=	wine ml.exe
ASSEMBLE_FLAGS		=	/Fm /Fl
COMMOBJS			=	../routine.asm


all: amdsvm amdnxe edbtest spare


amdsvm:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


amdnxe:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


edbtest:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


spare:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


clean:
	rm -rf *.map *.exe *.EXE *.obj *.lst *.MAP *.STS *.CV4 *.sts *.cv4 DELETED


