; HXLDR
; Copyright (c) 2024 by Ivan Chetchasov <chetvano@gmail.com>
; MPL 2.0 license

format binary as "com"

org 0x7e00
use16

_start:
    ; set up stack
    mov esp, 0x7e00

    ; call main function
    call main

halt:
    hlt
    jmp halt

; data section

; compiled path to core file
corePath:
    db 0x80  ; disk number
    db "sys" ; folder level 0
    db 0     ; next is file name
    db "hxos.hxe" ; file name
    db 0

; code section
__hexe_find_entry:
    push dword ebp
    mov ebp, esp

    ; first we must check magic number
    mov eax, [ebp+8]  ; file content pointer
    cmp dword [eax], "HEXB"
    jne error

    ; next, we must get entry point
    mov eax, [eax+4]  ; entry point

    mov esp, ebp
    pop ebp
    ret

__hxfs_load_file:
    push dword ebp
    mov ebp, esp

    ; first we must get metadata from correct disk
    ; get first element of the path
    mov ebx, [ebp+8]  ; path
    mov eax, [ebx]    ; first element

    ; fisrt element is a BIOS disk number
    ; we must put it in correct register
    mov dl, al
    
    ; next, fill all registers and raise interrupt
    mov ah, 2  ; function number
    mov al, 1  ; number of sectors
    mov ch, 0  ; cylinder
    mov cl, 2  ; sector
    mov dh, 0  ; head
    ; mov dl, 0  ; drive  ; you mustn't modify it
    mov bx, __disk_buffer  ; buffer address
    int 13h
    jc error  ; if carry flag is set, error

    ; next, we must check if it is HXFS disk
    ; we need to check 4 bytes b offset 4
    mov eax, __disk_buffer
    add eax, 4
    cmp dword [eax], "HXFS"
    jne error

    ; next, we need to load root directory information
    ; ...

    mov esp, ebp
    pop ebp
    ret

_hxfs_error:
    ; print error message
    mov ah, 0x0e
    mov al, 'E'
    int 10h
    mov al, 'r'
    int 10h
    mov al, 'r'
    int 10h

.halt:
    hlt
    jmp .halt

; char __disk_buffer[512];
__disk_buffer:
    rb 512

main:
    ; load core file
    push dword 0x1000
    push dword corePath
    call __hxfs_load_file
    sub esp, 8

    ; check if core file is loaded
    jc error

    ; jump to core file
    push dword 0x1000
    call __hexe_find_entry
    sub esp, 4
    jc error
    mov ebx, eax
    call word [eax]

error:
    ; print error message
    mov ah, 0x0e
    mov al, 'E'
    int 10h
    mov al, 'r'
    int 10h
    mov al, 'r'
    int 10h

times 1024-($-$$) db 0
