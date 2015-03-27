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
    
    kld(hl, message)
    ld d, 2
    ld e, 8
    pcall(drawStr)
    
.loop:

    pcall(fastCopy)
    
    pcall(flushKeys)
    
    corelib(appWaitKey)

;------Data-------

corelib_path:

    .db "/lib/core", 0

window_title:

    .db "WizardC8", 0

message:

    .db "WizardC8 for KnightOS is under construction", 0
