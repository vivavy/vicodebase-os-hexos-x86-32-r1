# this OS building via flat assembler

# build bootloader
boot: clean
	fasm src/bootsect.asm dist/bootsect.com

# build hexos loader
hxldr: clean
	fasm src/hxldr.asm dist/hxldr.com

# build kernel
kernel: clean
	fasm src/kernel/main.asm dist/hxos.hxe

# build hexos image
image: clean boot hxldr kernel
	python3 build/hxfs_image.py dist/hxos.raw build/tree.json

# clean
clean:
	rm -f dist/*.com
	rm -f dist/*.raw
	clear
