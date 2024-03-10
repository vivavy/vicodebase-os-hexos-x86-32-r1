macro !c fname, [args] {
    local argscount
common
    argscount = 0
forward
    argscount = argscount + 1
reverse
    push dword args
common
    call fname
    add esp, argscount * 4
}

macro !f fname, [args] {
    local i
common
fname:
    push ebp
    mov ebp, esp
    i = 8
forward
    args equ [ebp+i]
    i = i + 4
}


