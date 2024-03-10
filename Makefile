run: build
	clear
	qemu-system-i386 -drive file=dist/hxos.raw,format=raw 2>/dev/null

build: boot hxldr kernel
	cat dist/boot dist/hxldr dist/kernel.elf dist/fs > dist/hxos.raw
	fasm asm/image.asm image.raw

boot:
	fasm asm/mbr.asm dist/boot

hxldr:
	fasm asm/hxldr.asm dist/hxldr

kernel:
	fasm asm/kernel.asm dist/kernel.o
	g++ -m32 -nostdlib -ffreestanding -Tbuild/kernel.ld -o dist/kernel.elf src/kernel/main.cpp dist/kernel.o

clean:
	rm -rf dist/*
