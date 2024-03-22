; kernel source file. 16-bit, goes to 32-bit mode and initializes itself

define bits 32 ; but main code is 32-bit <-----------------------------------;
;                                                                            ;
format binary as "hxe";                                                      ;
;                                                                            ;
use16 ; HXE header value of bits field signifies the bitness of the entry point 

org 0x1000  ; HXE always starts at 0, but kernel is exception.

include 'vialib.inc'

SEG_Z equ 0
SEG_C equ SEG_Z + 8
SEG_D equ SEG_C + 8
SEG_G equ SEG_D + 8

; HXE 1 uses only 1 section (.flat) - RWX mode, so section table is not needed

hxe.header.begin:
    .magic db 0x7F, "HXE"                                                     ; magic number
    .version db 0x01                                                          ; format version
    .enviroment db 0x00                                                       ; environment (platform / OS)
    .architechture db 0x00                                                    ; architecture (x86 / arm)
    .bits db 0x00                                                             ; bits (16 / 32 / 64)
    .type db 0x03                                                             ; type (err / dummy / shared / executable)
    .size dd hxe.header.end - hxe.header.begin                                ; size of the header
    .entry dd _start                                                          ; entry point
    .stacktop dd @end                                                         ; stack top (equal to program size)
    .checksum dd @end - hxe.header.end + hxe.header.begin + _start / 3 + 0x7F ; checksum
    .footer db 0x7f, "EXH"                                                    ; footer
hxe.header.end:


;;;;;;;;;;;;;;;;;
;; 16-bit mode ;;
;;;;;;;;;;;;;;;;;
_start:
    mov [bootdev], dl
    mov ah, 0x0e
    mov al, 'X'
    int 0x10
    mov al, 'Y'
    int 0x10
    mov al, 'Z'
    int 0x10
    jmp $

include 'kernel.inc'

_go_to_32bit_mode:
    cli
    cld
    clc
    sidt [idt16]
    sgdt [gdt16]
    lidt [idt32]
    lgdt [gdt32]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp SEG_C:_fix_32bit_segments

idt16:
    dw 0
    dd 0
idt32:
    dw 0
    dd 0
gdt16:
    dw 0
    dd 0
gdt32:
.seg_z:
    dd 0
.seg_c:
    seg 0, 0xffffffff, ACC_PRESENT OR ACC_RING0 OR ACC_CODETYPE OR ACC_CODEREAD, FLAG_BITS32
.seg_d:
    seg 0, 0xffffffff, ACC_PRESENT OR ACC_RING0 OR ACC_DATATYPE OR ACC_WRITEBLE, FLAG_BITS32
.seg_g:
    seg 0xb8000, 80*25*2, ACC_PRESENT OR ACC_RING0 OR ACC_DATATYPE OR ACC_WRITEBLE, FLAG_BITS32

use32
;;;;;;;;;;;;;;;;;
;; 32-bit mode ;;
;;;;;;;;;;;;;;;;;

_fix_32bit_segments:
    mov ax, SEG_D
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov ax, SEG_G
    mov gs, ax
    mov esp, 0x1000
    jmp main

main:
    mov byte [gs:0], 'O'
    jmp $

;;;;;;;;;;
;; data ;;
;;;;;;;;;;
bootdev:
    dd 0

source.align 512
@end:
