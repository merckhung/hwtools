ASSEMBLER			=	wine ml.exe
EXE2ROM				=	wine utils/exe2rom.exe
ASSEMBLE_FLAGS		=	/Fm /Fl
OBJS				=	libflat.asm


all: gloader


gloader:
	$(ASSEMBLER) $(ASSEMBLE_FLAGS) $@.asm $(OBJS)
	$(EXE2ROM) -s0x7c00 GLOADER.EXE gloader.bin

clean:
	rm -rf *.img *.bin *.EXE *.exe *.map *.obj *.lst *.MAP *.STS *.CV4 DELETED

map:
	less GLOADER.MAP

lst:
	vi gloader.lst

img:
	dd if=gloader.bin of=gbbios.img conv=sync ibs=1474560

emu:
	qemu -fda ./gbbios.img -m 32


