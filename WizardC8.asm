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
    .db "wizardc8", 0
start:
    kld(de, corelib_path)
    pcall(loadLibrary)

    ; Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    ; Allocate and clear a buffer to store the contents of the screen
    pcall(allocScreenBuffer)

    kcall(redrawHomeScreen)

    ; Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ; flushKeys waits for all keys to be released
    pcall(flushKeys)
    corelib(appWaitKey)

    kld(hl, wizardc8Menu)
    ld c, 40
    corelib(showMenu)

    cp 0
    kjp(z, aboutScreen)

    cp 1
    kjp(z, gallionsToDollars)

    cp 2
    kjp(z, dollarsToGallions)

    jp start

aboutScreen:
    ; Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    pcall(freeScreenBuffer)
    pcall(allocScreenBuffer)

    kld(hl, about_window_title)
    res 2, a
    xor a
    corelib(drawWindow)

    kld(hl, aboutScreenText)
    ld d, 2
    ld e, 20
    pcall(drawStr)

aboutScreenLoop:
    ; Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ; flushKeys waits for all keys to be released
    pcall(flushKeys)
    corelib(appWaitKey)

    cp kEnter
    jp z, start

    jr aboutScreenLoop

dollarsToGallions:
    xor a

    kcall(redrawHomeScreen)

    kld(a, (dollarsPlaceField))
    kld(hl, dollarsPlaceFieldLocation_X)

    ld d, 0
    ld e, a

    add hl, de

    kld(a, (valueToHideArrow))

    ld b, 3

    ld d, (hl)
    ld e, 11
    push hl
    kld(hl, upArrow)
    pcall(putSpriteOR)

    cp 9
    kcall(z, hideArrow)

    ld b, 3
    pop hl
    ld d, (hl)
    ld e, 34
    kld(hl, downArrow)
    pcall(putSpriteOR)

    cp 0
    kcall(z, hideArrow)

    kld(a, (tenDollarsPlaceValue))
    ld d, 19
    ld e, 22
    pcall(drawDecA)

    kld(a, (oneDollarsPlaceValue))
    ld d, 23
    ld e, 22
    pcall(drawDecA)

    ld a, '.'
    ld d, 26
    ld e, 22
    pcall(drawChar)

    kld(a, (tenCentsPlaceValue))
    ld d, 29
    ld e, 22
    pcall(drawDecA)

    kld(a, (oneCentsPlaceValue))
    ld d, 33
    ld e, 22
    pcall(drawDecA)

    pcall(fastCopy)
    pcall(flushKeys)

    corelib(appWaitKey)

    cp kUp
    kjp(z, incrementDollarsPlace)

    cp kDown
    kjp(z, decrementDollarsPlace)

    cp kRight
    kjp(z, changeDollarsPlaceRight)

    cp kLeft
    kjp(z, changeDollarsPlaceLeft)

    kld(hl, wizardc8DollarsAndGallionsMenu)
    ld c, 40
    corelib(showMenu)

    cp 0
    kjp(z, dollarsToGallionsResults)

    kjp(dollarsToGallions)

changeDollarsPlaceRight:
    kld(a, (dollarsPlaceField))

    cp 3
    kjp(z, dollarsToGallions)

    inc a
    kld((dollarsPlaceField), a)

    kjp(dollarsToGallions)

changeDollarsPlaceLeft:
    kld(a, (dollarsPlaceField))

    cp 0
    kjp(z, dollarsToGallions)

    dec a
    kld((dollarsPlaceField), a)

    kjp(dollarsToGallions)

incrementDollarsPlace:
    kld(a, (dollarsPlaceField))

    cp 0
    kjp(z, incrementTenDollarsPlace)

    cp 1
    kjp(z, incrementOneDollarsPlace)

    cp 2
    kjp(z, incrementTenCentsPlace)

    cp 3
    kjp(z, incrementOneCentsPlace)

    kjp(incrementDollarsPlace)

decrementDollarsPlace:
    kld(a, (dollarsPlaceField))

    cp 0
    kjp(z, decrementTenDollarsPlace)

    cp 1
    kjp(z, decrementOneDollarsPlace)

    cp 2
    kjp(z, decrementTenCentsPlace)

    cp 3
    kjp(z, decrementOneCentsPlace)

    kjp(decrementDollarsPlace)

incrementTenDollarsPlace:
    kld(a, (tenDollarsPlaceValue))

    cp 9
    kjp(z, dollarsToGallions)

    inc a
    kld((tenDollarsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

decrementTenDollarsPlace:
    kld(a, (tenDollarsPlaceValue))

    cp 0
    kjp(z, dollarsToGallions)

    dec a
    kld((tenDollarsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

incrementOneDollarsPlace:
    kld(a, (oneDollarsPlaceValue))

    cp 9
    kjp(z, dollarsToGallions)

    inc a
    kld((oneDollarsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

decrementOneDollarsPlace:
    kld(a, (oneDollarsPlaceValue))

    cp 0
    kjp(z, dollarsToGallions)

    dec a
    kld((oneDollarsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

incrementTenCentsPlace:
    kld(a, (tenCentsPlaceValue))

    cp 9
    kjp(z, dollarsToGallions)

    inc a
    kld((tenCentsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

decrementTenCentsPlace:
    kld(a, (tenCentsPlaceValue))

    cp 0
    kjp(z, dollarsToGallions)

    dec a
    kld((tenCentsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

incrementOneCentsPlace:
    kld(a, (oneCentsPlaceValue))

    cp 9
    kjp(z, dollarsToGallions)

    inc a
    kld((oneCentsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

decrementOneCentsPlace:
    kld(a, (oneCentsPlaceValue))

    cp 0
    kjp(z, dollarsToGallions)

    dec a
    kld((oneCentsPlaceValue), a)

    kld((valueToHideArrow), a)

    kjp(dollarsToGallions)

dollarsToGallionsResults:
    xor a

    kcall(redrawHomeScreen)

    kld(a, (tenCentsPlaceValue))

    ld h, a

    ld e, 10
    pcall(mul8By8)

    kld(a, (oneCentsPlaceValue))

    ld d, 0
    ld e, a

    add hl, de

    kld((totalDollarsValue), hl)

    kld(a, (oneDollarsPlaceValue))

    ld h, a

    ld e, 100
    pcall(mul8By8)

    kld(a, (totalDollarsValue))

    ld d, 0
    ld e, a

    add hl, de

    kld((totalDollarsValue), hl)

    kld(a, (tenDollarsPlaceValue))

    ld de, 1000
    pcall(mul16By8)

    kld(de, (totalDollarsValue))

    add hl, de

    kld((totalDollarsValue), hl)

    kld(a, (tenDollarsPlaceValue))
    ld d, 19
    ld e, 22
    pcall(drawDecA)

    kld(a, (oneDollarsPlaceValue))
    ld d, 23
    ld e, 22
    pcall(drawDecA)

    ld a, '.'
    ld d, 26
    ld e, 22
    pcall(drawChar)

    kld(a, (tenCentsPlaceValue))
    ld d, 29
    ld e, 22
    pcall(drawDecA)

    kld(a, (oneCentsPlaceValue))
    ld d, 33
    ld e, 22
    pcall(drawDecA)

    kld(hl, (totalDollarsValue))
    kld(de, (gallionsRateInDollars))

    ld a, h
    ld c, l

    pcall(divACByDE)

    ; Result is in ac

    ld h, a
    ld l, c

    ; Now the Result is in hl

    kld((gallionsValue), hl)
    ld d, 70
    ld e, 10
    pcall(drawDecHL)

    ; Todo: Convert the (Remainder of Gallions) to Sickles
    ; I'll probably have to wait until a pcall() with
    ; a decimal Remainder is integrated since Least Common
    ; Denominator Remainder doesn't work

    pcall(fastCopy)
    pcall(flushKeys)

    corelib(appWaitKey)

    kld(hl, convertedResultsMenu)
    ld c, 40
    corelib(showMenu)

    cp 0
    kjp(z, Start)

    kjp(dollarsToGallionsResults)

gallionsToDollars:
    xor a

    kcall(redrawHomeScreen)

    kld(a, (wizardCurrencyPlaceField))
    kld(hl, wizardCurrencyPlaceFieldLocation_Y)

    ld d, 0
    ld e, a

    add hl, de

    kld(a, (valueToHideArrow))

    ld b, 3

    ld d, 48
    ld e, (hl)
    push hl
    kld(hl, upArrow)
    pcall(putSpriteOR)

    cp 9
    kcall(z, hideArrow)

    ; Todo: Don't make the up Arrow hide
    ;       when the Sickles and Knuts
    ;       are at 9.

    ;       Also, the down Arrow shows when
    ;       the Gallions are greater than or
    ;       equaled to 1. The down Arrow needs
    ;       to be hidden when the Sickles and
    ;       Knuts are 0.

    ld d, 0
    ld e, a

    add hl, de

    kld(a, (valueToHideArrow))

    ld b, 3

    ld d, 87
    pop hl
    ld e, (hl)
    kld(hl, downArrow)
    pcall(putSpriteOR)

    cp 0
    kcall(z, hideArrow)

    kld(hl, (gallionsValue))
    ld d, 70
    ld e, 10
    pcall(drawDecHL)

    kld(a, (sicklesValue))
    ld d, 70
    ld e, 21
    pcall(drawDecA)

    kld(a, (knutsValue))
    ld d, 70
    ld e, 32
    pcall(drawDecA)

    pcall(fastCopy)
    pcall(flushKeys)

    corelib(appWaitKey)

    cp kUp
    kjp(z, chooseFieldIncrement)

    cp kDown
    kjp(z, chooseFieldDecrement)

    cp kEnter
    kjp(z, nextField)

    kld(hl, wizardc8DollarsAndGallionsMenu)
    ld c, 40
    corelib(showMenu)

    cp 0
    kjp(z, gallionsToDollarsResults)

    kjp(gallionsToDollars)

chooseFieldIncrement:
    kld(a, (wizardCurrencyPlaceField))

    cp 0
    kjp(z, gallionsIncrement)

    cp 1
    kjp(z, sicklesIncrement)

    cp 2
    kjp(z, knutsIncrement)

    jr chooseFieldIncrement

chooseFieldDecrement:
    kld(a, (wizardCurrencyPlaceField))

    cp 0
    kjp(z, gallionsDecrement)

    cp 1
    kjp(z, sicklesDecrement)

    cp 2
    kjp(z, knutsDecrement)

    jr chooseFieldDecrement

gallionsIncrement:
    kld(hl, (gallionsValue))

    ld de, 9
    pcall(cpHLDE)
    kjp(z, gallionsToDollars)

    inc hl
    kld((gallionsValue), hl)

    kld((valueToHideArrow), hl)

    kjp(gallionsToDollars)

gallionsDecrement:
    kld(hl, (gallionsValue))

    ld de, 0
    pcall(cpHLDE)
    kjp(z, gallionsToDollars)

    dec hl
    kld((gallionsValue), hl)

    kld((valueToHideArrow), hl)

    kjp(gallionsToDollars)

sicklesIncrement:
    kld(a, (sicklesValue))

    cp 16
    kjp(z, gallionsToDollars)

    inc a
    kld((sicklesValue), a)

    kld((valueToHideArrow), a)

    kjp(gallionsToDollars)

sicklesDecrement:
    kld(a, (sicklesValue))

    cp 0
    kjp(z, gallionsToDollars)

    dec a
    kld((sicklesValue), a)

    kld((valueToHideArrow), a)

    kjp(gallionsToDollars)

knutsIncrement:
    kld(a, (knutsValue))

    cp 28
    kjp(z, gallionsToDollars)

    inc a
    kld((knutsValue), a)

    kld((valueToHideArrow), a)

    kjp(gallionsToDollars)

knutsDecrement:
    kld(a, (knutsValue))

    cp 0
    kjp(z, gallionsToDollars)

    dec a
    kld((knutsValue), a)

    kld((valueToHideArrow), a)

    kjp(gallionsToDollars)

nextField:
    kld(a, (wizardCurrencyPlaceField))
    inc a
    kld((wizardCurrencyPlaceField), a)

    cp 3
    kcall(z, loopField)

    kjp(gallionsToDollars)

gallionsToDollarsResults:
    xor a

    kcall(redrawHomeScreen)

    kld(hl, (gallionsValue))
    ld d, 70
    ld e, 10
    pcall(drawDecHL)

    kld(a, (sicklesValue))
    ld d, 70
    ld e, 21
    pcall(drawDecA)

    kld(a, (knutsValue))
    ld d, 70
    ld e, 32
    pcall(drawDecA)

    kld(hl, (gallionsValue))

    ld b, h
    ld c, l

    kld(de, (gallionsRateInDollars))

    pcall(mul16By16)

    push hl

    kld(a, (sicklesRateInDollars))
    ld h, a
    kld(a, (sicklesValue))
    ld e, a
    pcall(mul8By8)

    pop de

    add hl, de

    push hl

    kld(a, (knutsRateInDollars))
    ld h, a
    kld(a, (knutsValue))
    ld e, a
    pcall(mul8By8)

    pop de

    add hl, de

    kld((totalDollarsValue), hl)

    ld a, h
    ld c, l

    ld de, 1000

    pcall(divACByDE)

    ld h, a
    ld l, c

    kld((tenDollarsPlaceValue), hl)
    kld(a, (tenDollarsPlaceValue))

    ld d, 19
    ld e, 22
    pcall(drawDecA)

    ld de, 1000
    pcall(mul16By8)

    kld(de, (totalDollarsValue))

    ex hl, de

    xor a
    sbc hl, de

    push hl

    ld c, 100
    pcall(divHLByC)

    kld((oneDollarsPlaceValue), hl)
    kld(a, (oneDollarsPlaceValue))

    push af

    ld d, 23
    ld e, 22
    pcall(drawDecA)

    ld a, '.'
    ld d, 26
    ld e, 22
    pcall(drawChar)

    pop hl

    ld e, 100
    pcall(mul8By8)

    pop de

    ex hl, de

    xor a
    sbc hl, de

    push hl

    ld c, 10
    pcall(divHLByC)

    kld((tenCentsPlaceValue), hl)
    kld(a, (tenCentsPlaceValue))

    ld d, 29
    ld e, 22
    pcall(drawDecA)

    ld h, a
    ld e, 10
    pcall(mul8By8)

    pop de

    ex hl, de

    xor a
    sbc hl, de

    kld((oneCentsPlaceValue), hl)
    kld(a, (oneCentsPlaceValue))

    ld d, 33
    ld e, 22
    pcall(drawDecA)

    pcall(fastCopy)
    pcall(flushKeys)

    corelib(appWaitKey)

    kld(hl, convertedResultsMenu)
    ld c, 40
    corelib(showMenu)

    cp 0
    kjp(z, Start)

    kjp(dollarsToGallionsResults)

redrawHomeScreen:
    pcall(clearBuffer)

    kld(hl, home_window_title)

    set 2, a

    corelib(drawWindow)

    ld c, 41
    ld a, 47
    ld l, 1
    pcall(drawVLine)

    ld d, 1
    ld e, 41
    ld h, 94
    ld l, 41
    pcall(drawLine)

    ld d, 10
    ld e, 15
    ld h, 37
    ld l, 15
    pcall(drawLine)

    ld d, 10
    ld e, 32
    ld h, 37
    ld l, 32
    pcall(drawLine)

    ld c, 17
    ld a, 10
    ld l, 15
    pcall(drawVLine)

    ld c, 17
    ld a, 37
    ld l, 15
    pcall(drawVLine)

    ld a, '$'
    ld d, 12
    ld e, 22
    pcall(drawChar)

    ld c, 17
    ld a, 16
    ld l, 15
    pcall(drawVLine)

    ld d, 55
    ld e, 8
    ld h, 85
    ld l, 8
    pcall(drawLine)

    ld d, 55
    ld e, 16
    ld h, 85
    ld l, 16
    pcall(drawLine)

    ld c, 8
    ld a, 55
    ld l, 8
    pcall(drawVLine)

    ld c, 8
    ld a, 85
    ld l, 8
    pcall(drawVLine)

    kld(hl, gallionSymbol)
    ld b, 7
    ld d, 55
    ld e, 9
    pcall(putSpriteOR)

    ld c, 8
    ld a, 63
    ld l, 8
    pcall(drawVLine)

    ld d, 55
    ld e, 19
    ld h, 85
    ld l, 19
    pcall(drawLine)

    ld d, 55
    ld e, 27
    ld h, 85
    ld l, 27
    pcall(drawLine)

    ld c, 8
    ld a, 55
    ld l, 19
    pcall(drawVLine)

    ld c, 8
    ld a, 85
    ld l, 19
    pcall(drawVLine)

    kld(hl, sickleSymbol)
    ld b, 7
    ld d, 55
    ld e, 19
    pcall(putSpriteOR)

    ld c, 8
    ld a, 63
    ld l, 19
    pcall(drawVLine)

    ld d, 55
    ld e, 30
    ld h, 85
    ld l, 30
    pcall(drawLine)

    ld d, 55
    ld e, 38
    ld h, 85
    ld l, 38
    pcall(drawLine)

    ld c, 8
    ld a, 55
    ld l, 30
    pcall(drawVLine)

    ld c, 8
    ld a, 85
    ld l, 30
    pcall(drawVLine)

    kld(hl, knutsSymbol)
    ld b, 7
    ld d, 55
    ld e, 30
    pcall(putSpriteOR)

    ld c, 8
    ld a, 63
    ld l, 30
    pcall(drawVLine)

    ret

hideArrow:
    pcall(putSpriteAND)

    ret

loopField:
    ld a, 0
    kld((wizardCurrencyPlaceField), a)

    ret

corelib_path:
    .db "/lib/core", 0

home_window_title:
    .db "WizardC8", 0

about_window_title:
    .db "About", 0

gallionSymbol:  ; 8x7
    .db 0b00011000
    .db 0b00100100
    .db 0b01011010
    .db 0b10111101
    .db 0b01011010  ; Needs improvement
    .db 0b00100100
    .db 0b00011000

sickleSymbol:  ; 8x7
    .db 0b00011000
    .db 0b00100100
    .db 0b01011010
    .db 0b10100001
    .db 0b01011010  ; Needs improvement
    .db 0b00111100
    .db 0b00011000

knutsSymbol:  ; 8x7
    .db 0b00011000
    .db 0b00110100
    .db 0b01011010
    .db 0b10010001
    .db 0b01011010  ; Needs improvement
    .db 0b00110100
    .db 0b00011000

convertSymbol:  ;8x5
    .db 0b00100100
    .db 0b01000010
    .db 0b11111111
    .db 0b01000010
    .db 0b00100100

upArrow:
    .db 0b00010000
    .db 0b00111000
    .db 0b01111100

downArrow:
    .db 0b01111100
    .db 0b00111000
    .db 0b00010000

wizardc8Menu:
    .db 3
    .db "About", 0
    .db "G->$", 0
    .db "$->G", 0

wizardc8DollarsAndGallionsMenu:
    .db 1
    .db "Convert", 0

convertedResultsMenu:
    .db 1
    .db "Home", 0

aboutScreenText:
    .db "Wizard Currency Converter\nVersion 8.0 Alpha\nReleased:\nApril 12th, 2015", 0

tenDollarsPlaceValue:
    .db 0

oneDollarsPlaceValue:
    .db 0

tenCentsPlaceValue:
    .db 0

oneCentsPlaceValue:
    .db 0

valueToHideArrow:
    .db 0

dollarsPlaceField:
    .db 0

dollarsPlaceFieldLocation_X:
    .db 17, 21, 27, 31

wizardCurrencyPlaceFieldLocation_Y:
    .db 11, 22, 33

wizardCurrencyPlaceField:
    .db 0

totalDollarsValue:
    .dw 0

gallionsRateInDollars:
    .dw 1007

sicklesRateInDollars:
    .db 59

knutsRateInDollars:
    .db 2

gallionsValue:
    .db 0, 0

sicklesValue:
    .db 0

knutsValue:
    .db 0
