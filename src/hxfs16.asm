include 'macros.inc'

; void __hxfs_load_file(const char *path, void *buffer);
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