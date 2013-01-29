#ASSEMBLER			=	wine ml.exe
ASSEMBLER			=	ml.exe
ASSEMBLE_FLAGS		=	#/Fm /Fl
COMMOBJS			=	routine.asm


all: showpci i2cget i2cset w8379x flxios it871x dosldr vit871x romdet buslock bzip2 bioscli hdddump int15tsr


it871x:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) libsio.asm


vit871x:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) libsio.asm


showpci:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) libpci.asm


i2cget:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libpci.asm libi2c.asm


i2cset:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libpci.asm libi2c.asm


w8379x:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libpci.asm libi2c.asm


flxios:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libflash.asm libflat.asm


flashlpc:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libflash.asm libflat.asm


dosldr:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) libflat.asm


romdet:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) libflash.asm libflat.asm


hotkey:
	$(ASSEMBLER) $@.asm


scnshot:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libfat.asm


buslock:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libflat.asm


bzip2:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libflat.asm


nmitsr:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libtsr.asm


bioscli:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libdbg.asm


hdddump:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) /DDEBUG $@.asm $(COMMOBJS) libhdd.asm libdbg.asm


int13tsr:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libhdd.asm libtsr.asm libcom.asm


int15tsr:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libtsr.asm


lookpci:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(COMMOBJS) libdbg.asm libpci.asm


clean:
	rm -rf *.map *.exe *.EXE *.obj *.lst *.MAP *.STS *.CV4 *.sts *.cv4 DELETED


