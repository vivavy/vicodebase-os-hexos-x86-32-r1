format binary as "raw"

file 'dist/hxos.raw'

times 512 - ($ MOD 512) db 0
