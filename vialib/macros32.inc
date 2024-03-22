
macro source.align chunksize {
    times chunksize-($-$$) MOD chunksize nop
}
