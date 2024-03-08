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

; path to core file
corePath:
    db 0x80  ; disk number
    db "sys" ; folder level 0
    db 0     ; next is file name
    db "hxos.hxe" ; file name
    db 0

; code section
include 'hxfs16.asm'

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
    call [eax]

error:
    ; print error message
    mov ah, 0x0e
    mov al, 'E'
    int 10h
    mov al, 'r'
    int 10h
    mov al, 'r'
    int 10h
