format ELF

extrn main
public _start

section ".text" executable

db "ENTRY POINT", 0
_start:
    jmp halt  ; TODO: remove this line
    ; set up environment
    mov esp, 4096

    mov byte [4096], dl
    mov eax, 0
    mov ebx, 0
    mov ecx, 0
    mov edx, 0
    mov esi, 0
    mov edi, 0
    mov ss, ax
    mov ds, ax
    mov gs, ax
    mov es, ax
    mov fs, ax

    movzx edx, byte [4096]
    push dword edx
    mov edx, 0
    ; call main function
    call main
    add esp, 4

halt:
    hlt
    jmp halt