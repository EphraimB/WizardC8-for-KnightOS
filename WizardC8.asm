#include "kernel.inc"
#include "corelib.inc"

    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END

name:
    .db "WizardC8", 0

start:

    kld(de, corelib_path)
    pcall(loadLibrary)
    
    pcall(getLCDLock)
    pcall(getKeypadLock)
    
    pcall(allocScreenBuffer)
    pcall(clearBuffer)
    
    kld(hl, window_title)
    xor a
    corelib(drawWindow)

;------Data-------

corelib_path:

    .db "/lib/core", 0

window_title:

    .db "WizardC8", 0
