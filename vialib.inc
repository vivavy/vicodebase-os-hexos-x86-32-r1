matched = 0

match =32, bits {
    matched = 1
    include 'vialib/consts32.inc'
    include 'vialib/macros32.inc'
    include 'vialib/struct32.inc'
}

match =64, bits {
    matched = 1
    include 'vialib/consts64.inc'
    include 'vialib/macros64.inc'
    include 'vialib/struct64.inc'
}

if matched eq 0
    display 'error: invalid bitness.'
    err
end if
