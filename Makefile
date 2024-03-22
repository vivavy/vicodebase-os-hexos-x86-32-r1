run: build
	qemu-system-i386 -drive file=dist/image.raw,format=raw 2>/dev/null

build: boot
	fasm src/image.asm dist/image.raw 2>dist/log.txt
	rm -f boot.bin kernel.hxe dist/log.txt

boot: kernel
	fasm src/boot/boot.asm boot.bin 2>dist/log.txt

kernel: clean
	fasm src/kernel/main.asm kernel.hxe 2>dist/log.txt 

clean:
	rm -rf dist/*
