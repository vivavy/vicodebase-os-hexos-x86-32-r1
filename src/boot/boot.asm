define bits 16

format binary

use16
org 0x7c00

_fix_cs:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov sp, 0x7c00

    jmp 0:main

include 'boot.inc'

virtual
__kernel_start:
    file 'kernel.hxe'
__kernel_end:
end virtual

main:
    mov [bootdev], dl

    !print a_HexOSDisk
    !print a_Loading
    
    mov ax, 0
    mov es, ax
    mov bx, 0x1000
    mov ah, 2
    mov al, (__kernel_end - __kernel_start) / 512
    mov cx, 2
    mov dh, 0
    mov dl, [bootdev]
    int 0x13
    jc error
    
    !print a_Running
    mov ebx, 0x1000
    call startup_hxe

error:
    !print a_Error

halt:
    hlt
    jmp halt

a_HexOSDisk str "HEX OS DISK", 13, 10
a_Loading str "LOADING", 13, 10
a_Running str "RUNNING", 13, 10
a_Error str "ERROR", 13, 10
a_x7fHXE str "<x7f>HXE", 13, 10
bootdev db ?

times 510-($-$$) db 0
dw 0xaa55
