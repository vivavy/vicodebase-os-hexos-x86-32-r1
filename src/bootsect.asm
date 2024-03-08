; boot sector
; Copyright (c) 2024 by Ivan Chetchasov <chetvano@gmail.com>
; MPL 2.0 license

format binary as "com"

org 0x7c00
use16

; jump to real code to make space for metadata
jmp fix_cs
nop

; metadata
magic:
    db 0, "HXFS"

fix_cs:
    ; set up segment registers
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; set up stack
    mov sp, 0x7c00

    ; far jump to define CS value
    jmp 0:main

main:
    ; set up video mode
    mov ax, 3
    int 10h

    ; load HXLDR from next 4 sectors
    mov ah, 2  ; function number
    mov al, 4  ; number of sectors
    mov ch, 0  ; cylinder
    mov cl, 2  ; sector
    mov dh, 0  ; head
    ; mov dl, 0  ; drive  ; you mustn't modify it
    mov bx, 0x7e00  ; buffer address
    int 13h
    jc error  ; if carry flag is set, error

    ; jump to HXLDR
    jmp 0x7e00:0

error:
    ; print error message
    mov ah, 0x0e
    mov al, 'E'
    int 10h
    mov al, 'r'
    int 10h
    mov al, 'r'
    int 10h

halt:
    hlt
    jmp halt

times 510-($-$$) db 0
dw 0xaa55
