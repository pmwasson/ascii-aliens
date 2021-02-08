;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Ascii Aliens -- an ascii shooter
;

;------------------------------------------------
; Constants
;------------------------------------------------

.include "defines.asm"
.include "macros.asm"

;------------------------------------------------
; Zero page usage
;------------------------------------------------

; Safe zero page locations from Inside the Apple IIe:
;
;                         $06 $07 
; $08 $09
;     $19 $1A $1B $1C $1D $1E
;                         $CE $CF
;                             $D7
;             $E3
; $E8 
;                 $EC $ED $EE $EF
;         $FA $FB $FC $FD $FE $FF 
;

spritePtr0      :=  $06     ; Sprite pointer
spritePtr1      :=  $07
screenPtr0      :=  $08     ; Screen pointer
screenPtr1      :=  $09

; Key bindings
KEY_RIGHT       = $08
KEY_LEFT        = $15
KEY_WAIT        = ' '
KEY_QUIT        = $1b
KEY_NONE        = $ff

.segment "CODE"
.org    $C00


.proc main

    ; make sure we are in 40-column mode
    lda     #$15
    jsr     COUT


gameLoop:
    inc     gameClock

    jsr     draw_screen

    jsr     get_input

    cmp     #KEY_QUIT
    bne     :+
    jmp     quit_game
:


    ; Bullet
    bit     bulletY
    bpl     update_bullet

    bit     BUTTON0
    bpl     :+
    clc
    lda     playerX
    adc     #2
    sta     bulletX
    lda     playerY
    sta     bulletY
    jsr     sound_shoot

update_bullet:
    lda     gameClock
    and     #1
    bne     :+
    dec     bulletY
:


    ; Movement
    lda     paddlePosition
    bmi     paddle_left
    beq     paddle_middle

    ; must be right
    ;lda     #0; 2
    ;sta     playerSprite

    lda     playerX
    cmp     #39-4
    bpl     gameLoop
    inc     playerX
    jmp     gameLoop

paddle_left:
    ;lda     #0; 1
    ;sta     playerSprite

    lda     playerX
    beq     gameLoop
    dec     playerX
    jmp     gameLoop

paddle_middle:
    ;lda     #0
    ;sta     playerSprite
    jmp     gameLoop

.endproc

;-----------------------------------------------------------------------------
; quit_game
;-----------------------------------------------------------------------------

.proc quit_game   

    sta     LOWSCR      ; Make sure exit onto screen 1
    jmp     MONZ

.endproc

;-----------------------------------------------------------------------------
; reset
;-----------------------------------------------------------------------------
; Reset game state
; Note, this is a good place to debug/cheat since you can modify to start
; in whatever state you wish.

.proc reset

    ; TODO - reset state

    rts

.endproc

;-----------------------------------------------------------------------------
; get_input
;-----------------------------------------------------------------------------
; Return key with bit 7 clear, or -1
; Also read paddle 0

.proc get_input

    ; assume middle to start with
    lda     #0
    sta     paddlePosition

    ; read paddle
    ldx     #0
    jsr     PREAD
    tya
    bmi     check_right

    ; LEFT
    cmp     #64
    bpl     keyboard
    lda     #$FF
    sta     paddlePosition
    jmp     keyboard

    ; RIGHT
check_right:
    cmp     #192
    bmi     keyboard
    lda     #1
    sta     paddlePosition

keyboard:
    lda     KBD
    bmi     gotKey

    ; exit with no key
    lda     #$ff
    rts

gotKey: 
    sta     KBDSTRB
    and     #$7f
    rts

.endproc


;-----------------------------------------------------------------------------
; draw_screen
;-----------------------------------------------------------------------------

.proc draw_screen

    ; Alternate page to draw
    ;-------------------------------------------------------------------------
    lda     #4      ; if showing page 2, draw on page 1
    ldx     PAGE2
    bmi     pageSelect
    lda     #8      ; displaying page 1, draw on page 2
pageSelect:
    sta     drawPage
    clc
    adc     #4
    sta     drawNextPage


    ; screen screen and draw stars
    jsr     star_screen


    ; draw ship
    lda     playerX
    sta     spriteX
    lda     playerY
    sta     spriteY  
    lda     #0
    bit     BUTTON0
    bpl     :+
    lda     #4
:
    jsr     draw_sprite


    ; draw aliens

    lda     #2
    sta     spriteY  

    lda     #17
    sta     spriteX
    lda     #1
    jsr     draw_sprite

    lda     #12
    sta     spriteX
    lda     #2
    jsr     draw_sprite

    lda     #24
    sta     spriteX
    lda     #3
    jsr     draw_sprite


    ; draw bullet
    lda     bulletX
    ldy     bulletY
    ldx     #'*' | $80
    jsr     draw_char


    ; draw score
    lda     #0
    sta     spriteX
    lda     #0
    sta     spriteY
    lda     #5
    jsr     draw_sprite

    ; draw lives
    lda     #0
    sta     spriteX
    lda     #23
    sta     spriteY
    lda     #6
    jsr     draw_sprite



    ; Set display page
    ;-------------------------------------------------------------------------

flipPage:
    ; flip page
    ldx     PAGE2
    bmi     flipToPage1
    sta     HISCR           ; display page 2
    rts

flipToPage1:
    sta     LOWSCR          ; diaplay page 1
    rts

.endproc

;-----------------------------------------------------------------------------
; fill_screen (screen1)
;-----------------------------------------------------------------------------

.proc fill_screen1
    ldx     #0
    lda     #$a0        ; blank
loop:
    ; 8 starting points, 3 rows each = 24 rows
    sta     $400,x
    sta     $480,x
    sta     $500,x
    sta     $580,x
    sta     $600,x
    sta     $680,x
    sta     $700,x
    sta     $780,x
    inx 
    cpx     #40*3
    bne     loop
    rts
.endproc

;-----------------------------------------------------------------------------
; fill_screen (screen2)
;-----------------------------------------------------------------------------

.proc fill_screen2
    ldx     #0
    lda     #$a0        ; blank
loop:
    ; 8 starting points, 3 rows each = 24 rows
    sta     $800,x
    sta     $880,x
    sta     $900,x
    sta     $980,x
    sta     $a00,x
    sta     $a80,x
    sta     $b00,x
    sta     $b80,x
    inx 
    cpx     #40*3
    bne     loop
    rts
.endproc

;-----------------------------------------------------------------------------
; star_screen
;-----------------------------------------------------------------------------

.proc star_screen

    ; set up pointer to first line
    clc
    lda     #0
    sta     screenPtr0
    lda     drawPage
    sta     screenPtr1

    ; load position in star field
    ldx     starOffset

rowLoop:
    ; erase line
    lda     #$a0
    ldy     #39
:
    sta     (screenPtr0),y
    dey
    bpl     :-

    ; draw 1 star per line

    ldy     starTable,x
    lda     #'.' | $80
    sta     (screenPtr0),y

    ; increment to the next line

    inx     ; next star

    lda     screenPtr0
    adc     #$80
    sta     screenPtr0
    lda     screenPtr1
    adc     #0
    sta     screenPtr1
    cmp     drawNextPage
    bne     rowLoop

    ; next 1/3 of screen
    lda     drawPage
    sta     screenPtr1
    clc
    lda     screenPtr0
    adc     #40
    sta     screenPtr0
    cmp     #40*3
    bne     rowLoop

    dec     starOffset
    rts

.endproc

;-----------------------------------------------------------------------------
; draw_char
; y = row
; a = col
; x = character
;-----------------------------------------------------------------------------
.proc draw_char
    clc
    adc     lineOffset,y    ; + lineOffset
    sta     screenPtr0    
    lda     linePage,y
    adc     drawPage        ; previous carry should be clear
    sta     screenPtr1
    ldy     #0
    txa
    sta     (screenPtr0),y
    rts
.endproc

;-----------------------------------------------------------------------------
; draw_sprite
;-----------------------------------------------------------------------------
; Sprite format
;   row0 bytes      - width bytes of data
;   ...
;   rowN bytes      - width bytes of data, where N is height-1
;   padding         - (64*2) - w*h
;   width, height   - 2 bytes (always byte 62 and 63)

;
; Sprites must fit within 64 bytes, including the 2-byte coda.  So width*height + 2 =< 64
; So an 8x8 sprite is not allowed, but 7x8, 8x7 or 6x10 are fine.

.proc draw_sprite

    ; calculate sprite pointer
    sta     temp            ; Save a copy of A

    ror
    ror
    ror                     ; Multiply by 64
    and     #$c0
    clc
    adc     #<spriteSheet
    sta     spritePtr0

    lda     spritePage      ; page offset used to animate
    adc     #>spriteSheet
    sta     spritePtr1
    lda     temp 
    lsr
    lsr                     ; Divide by 4
    clc
    adc     spritePtr1
    sta     spritePtr1

    ; Read header
    ldy     #62
    lda     (spritePtr0),y
    sta     width
    sta     width_m1        ; width-1
    dec     width_m1

    ldy     #63
    lda     (spritePtr0),y
    tax                     ; x == height

    ; copy spriteY so as to not modify
    lda     spriteY
    sta     drawY

loopy:
    ; calculate screen pointer
    ldy     drawY
    lda     spriteX
    clc
    adc     lineOffset,y    ; + lineOffset
    sta     screenPtr0    
    lda     linePage,y
    adc     drawPage        ; previous carry should be clear
    sta     screenPtr1

    ; display row
    ldy     width_m1
loopx:
    lda     (spritePtr0),y
    beq     skip            ; if data is zero, don't draw
    sta     (screenPtr0),y
skip:
    dey
    bpl     loopx

    ; assumes aligned such that there are no page crossing
    lda     spritePtr0
    adc     width           ; carry should still be clear
    sta     spritePtr0

    inc     drawY           ; next line

    dex
    bne     loopy

    rts    

; locals
temp:       .byte   0
width:      .byte   0
width_m1:   .byte   0
drawY:      .byte   0

.endproc


; Libraries
;-----------------------------------------------------------------------------

; add utilies
.include "inline_print.asm"
.include "sounds.asm"

; Globals
;-----------------------------------------------------------------------------

gameClock:      .byte   0

drawPage:       .byte   4   ; 4 or 8
drawNextPage:   .byte   8   ; 8 or C

spriteX:        .byte   0
spriteY:        .byte   0
spritePage:     .byte   0

starOffset:     .byte   0

playerX:        .byte   (40-5)/2
playerY:        .byte   23-3
playerSprite:   .byte   0

paddlePosition: .byte   0

bulletX:        .byte   0
bulletY:        .byte   $ff

; Lookup tables
;-----------------------------------------------------------------------------

lineOffset:
    .byte   <$0000
    .byte   <$0080
    .byte   <$0100
    .byte   <$0180
    .byte   <$0200
    .byte   <$0280
    .byte   <$0300
    .byte   <$0380
    .byte   <$0028
    .byte   <$00A8
    .byte   <$0128
    .byte   <$01A8
    .byte   <$0228
    .byte   <$02A8
    .byte   <$0328
    .byte   <$03A8
    .byte   <$0050
    .byte   <$00D0
    .byte   <$0150
    .byte   <$01D0
    .byte   <$0250
    .byte   <$02D0
    .byte   <$0350
    .byte   <$03D0

linePage:
    .byte   >$0000
    .byte   >$0080
    .byte   >$0100
    .byte   >$0180
    .byte   >$0200
    .byte   >$0280
    .byte   >$0300
    .byte   >$0380
    .byte   >$0028
    .byte   >$00A8
    .byte   >$0128
    .byte   >$01A8
    .byte   >$0228
    .byte   >$02A8
    .byte   >$0328
    .byte   >$03A8
    .byte   >$0050
    .byte   >$00D0
    .byte   >$0150
    .byte   >$01D0
    .byte   >$0250
    .byte   >$02D0
    .byte   >$0350
    .byte   >$03D0

    ; 256 random number from 0-39 from random.org
starTable:
    .byte   34, 29, 14, 21, 24, 8 , 11, 21, 11, 21, 30, 10, 11, 35, 37, 16
    .byte   31, 5 , 19, 35, 27, 8 , 17, 35, 36, 24, 21, 28, 20, 18, 20, 27
    .byte   11, 35, 19, 12, 38, 8 , 0 , 3 , 34, 20, 15, 19, 7 , 33, 2 , 26
    .byte   12, 29, 27, 32, 8 , 32, 10, 21, 8 , 37, 27, 5 , 25, 8 , 3 , 11
    .byte   17, 39, 15, 13, 38, 21, 35, 27, 26, 14, 25, 11, 19, 20, 39, 7
    .byte   22, 38, 1 , 16, 25, 12, 3 , 7 , 4 , 18, 21, 34, 33, 21, 5 , 7
    .byte   22, 2 , 7 , 20, 4 , 27, 38, 4 , 21, 31, 18, 31, 32, 15, 27, 26
    .byte   22, 9 , 10, 11, 29, 32, 32, 6 , 6 , 28, 18, 1 , 5 , 31, 38, 1
    .byte   29, 32, 23, 2 , 10, 8 , 19, 33, 35, 33, 8 , 13, 27, 21, 29, 24
    .byte   26, 7 , 28, 13, 24, 14, 35, 4 , 16, 12, 1 , 2 , 1 , 31, 25, 36
    .byte   28, 8 , 33, 22, 14, 22, 12, 20, 11, 0 , 33, 16, 10, 25, 1 , 26
    .byte   9 , 26, 38, 2 , 39, 2 , 27, 2 , 9 , 31, 0 , 29, 33, 5 , 15, 3
    .byte   23, 26, 23, 29, 6 , 17, 28, 13, 6 , 21, 4 , 14, 19, 26, 12, 30
    .byte   22, 19, 10, 1 , 26, 37, 31, 31, 14, 35, 37, 39, 4 , 28, 7 , 31
    .byte   5 , 31, 30, 18, 21, 12, 34, 35, 36, 21, 20, 18, 13, 23, 18, 22
    .byte   37, 31, 3 , 6 , 16, 37, 20, 33, 37, 29, 17, 8 , 32, 2 , 29, 2
;-----------------------------------------------------------------------------
; Game Sprites
;-----------------------------------------------------------------------------

.include "sprites.asm"

