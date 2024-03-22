print:
    mov ah, 0x0e
.1:
    lodsb
    test al, al
    jz .2
    int 0x10
    loop .1
.2:
    ret

HXE_MAGIC = 0
HXE_VERSION = HXE_MAGIC + 4
HXE_ENVIRONMENT = HXE_VERSION + 1
HXE_ARCHITECTURE = HXE_ENVIRONMENT + 1
HXE_BITS = HXE_ARCHITECTURE + 1
HXE_TYPE = HXE_BITS + 1
HXE_HEADER_SIZE = HXE_TYPE + 1
HXE_ENTRY = HXE_HEADER_SIZE + 4
HXE_STACKTOP = HXE_ENTRY + 4
HXE_CHECKSUM = HXE_STACKTOP + 4
HXE_FOOTER = HXE_CHECKSUM + 4

startup_hxe:
    ; check magic number
    mov eax, dword [ebx]
    cmp eax, 1163413631
    jne .error

    ; load entry point
    mov eax, dword [ebx+HXE_ENTRY]
    ; load stack top
    mov esp, dword [ebx+HXE_STACKTOP]

    ; fix segments
    xor cx, cx
    mov ds, cx
    mov es, cx
    mov ss, cx
    mov fs, cx
    mov gs, cx

    ; jump to entry point
    push word ax
    ret

.error:
    jmp error

macro !print message {
    mov si, message
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov ax, 0
    mov es, ax
    call print
}

struc str value& {
    if ~value eq
        db value
    end if
    db 0
}
