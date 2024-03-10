format binary

include 'macros.inc'

org 0x7c00
use16

jmp main
nop

db "MSWIN4.1"
dw 512
db 8
dw 32
db 2
dd 0
db 0xf8
dw 0
dw 0x3f  ; number of sectors on the track
dw 0xff  ; number of heads
dd 0     ; number of hidden sectors
dd (1024 * 1024 / 512) ; number of sectors
dd (1024 * 1024 / 512 * 4) ; size of the first FAT
dw 0 ; flags
dw 0 ; version
dd 4 ; root directory
dw 1 ; fsinfo sector
dw 0
db 12 dup (?)
db 0x80
db 0
db 0x29
dd 0x93751671
db "HEX OS DISK"
db "HXFSRO  "

    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov sp, 0x7c00

    jmp 0:main

main:
    mov ax, 3
    int 0x10

    mov ax, 0
    mov es, ax
    mov ah, 2
    mov al, 11
    mov bx, 4096
    mov cx, 2
    mov dh, 0
    int 0x13
    jc error
    mov eax, dword [4096+0x18]
    push eax
    ret

error:
    mov ah, 0x0e
    mov al, 'e'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'r'
    int 0x10

halt:
    hlt
    jmp halt

times 510-($-$$) db 0
dw 0xaa55
