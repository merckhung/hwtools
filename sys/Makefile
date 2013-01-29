#ASSEMBLER			=	wine ml.exe
ASSEMBLER			=	ml.exe
ASSEMBLE_FLAGS		=	/Fm /Fl
COMMOBJS			=	../routine.asm


all: rcitool pnpbios smbios comt


rcitool:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) ../libflat.asm


smbios:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) ../libflat.asm


pnpbios:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


comt:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


vesa:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


e820:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS)


clean:
	rm -rf *.map *.exe *.EXE *.obj *.lst *.MAP *.STS *.CV4 *.sts *.cv4 DELETED


