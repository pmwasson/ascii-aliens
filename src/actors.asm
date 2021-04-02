;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------

; Actors
ACTOR_SIZE      = 12
ACTOR_MAX_COUNT = 8

; Note that ACTOR_SIZE * ACTOR_MAX_COUNT must be <= 256

ACTOR_STATE         = 0     ; 0=inactive
ACTOR_SHAPE         = 1     ; Base sprite
ACTOR_PATH          = 2     ; Path index
ACTOR_X_LO          = 3     ; decimal for X
ACTOR_X_HI          = 4     ; screen X
ACTOR_Y_LO          = 5     ; decimal for Y
ACTOR_Y_HI          = 6     ; screen Y
ACTOR_COUNT         = 7     ; path counter
ACTOR_WIDTH         = 8     ; width for collision detection
ACTOR_PATH_RESET    = 9     ; initial path
ACTOR_X_RESET       = 10    ; initial X
ACTOR_Y_RESET       = 11    ; initial Y

; For collision detection

; only one player sprite
PLAYER_WIDTH    = 5
PLAYER_HEIGHT   = 2

; All aliens have same height
ACTOR_HEIGHT = 3

;-----------------------------------------------------------------------------
; update_actors
;-----------------------------------------------------------------------------

.proc update_actors

    lda     #0              ; point to first actor
    sta     activeCount

actor_loop:
    tax
    lda     actors+ACTOR_STATE,x        ; state
    bne     bullet

actor_next:
    ; skip to next actor
    txa
    clc
    adc     #ACTOR_SIZE
    cmp     #ACTOR_MAX_COUNT*ACTOR_SIZE

    bne     actor_loop

    ; done with list
    rts

    ; Check for bullet collision
    ;--------------------------------------

bullet:
    clc
    lda     bulletY
    bmi     player        ; if no bullet, skip

    ; check Y

    ; actor_top < bullet
    lda     actors+ACTOR_Y_HI,x
    cmp     bulletY
    beq     :+
    bpl     player
:

    ; actor_botom > bullet
    clc 
    adc     #ACTOR_HEIGHT
    sta     messageY
    cmp     bulletY
    bmi     player

    ; check X

    ; actor_left < bullet
    lda     actors+ACTOR_X_HI,x
    cmp     bulletX
    beq     :+
    bpl     player
:
    sta     messageX

    ; actor_right > bullet
    clc 
    adc     actors+ACTOR_WIDTH,x
    cmp     bulletX
    bmi     player

    jmp     kill

    ; Check for player collision
    ;--------------------------------------

    ; check Y
player:
    clc
    lda     playerY
    bmi     update_coord    ; no player

    ; check Y

    ; player_top < actor_bottom
    clc
    lda     actors+ACTOR_Y_HI,x
    sta     messageY
    adc     #ACTOR_HEIGHT
    cmp     playerY
    bmi     update_coord

    ; actor-top < player-bottom
    clc 
    lda     playerY
    adc     #PLAYER_HEIGHT
    cmp     actors+ACTOR_Y_HI,x
    bmi     update_coord

    ; check X

    ; player_left < actor-right
    clc
    lda     actors+ACTOR_X_HI,x
    sta     messageX
    adc     actors+ACTOR_WIDTH,x

    cmp     playerX
    bmi     update_coord

    ; actor-left < player-right
    clc 
    lda     playerX
    adc     #PLAYER_WIDTH
    cmp     actors+ACTOR_X_HI,x
    bmi     update_coord

    ; move player off-screen
    lda     #$ff
    sta     playerY

    ; set dying sequence
    lda     #SEQ_DEATH
    sta     seqIndex

    ; Update actor state
    ;--------------------------------------
kill:
    ; clear bullet
    lda     #$ff
    sta     bulletY 

    ; set actor to inactive
    dec     actors+ACTOR_STATE,x
    stx     temp

    ; display message
    ldx     #6      ; time
    lda     gameClock
    and     #7
    jsr     set_message

    ; sound effect
    jsr     sound_boom

    ldx     temp
    jmp     actor_next

    ; Update Coordinates
    ;--------------------------------------
update_coord:
    inc     activeCount
    ldy     actors+ACTOR_PATH,x
    lda     path+PATH_X,y
    asl
    bcs     x_neg
    clc
    adc     actors+ACTOR_X_LO,x        
    sta     actors+ACTOR_X_LO,x     ; x_lo = path_x + x_lo

    lda     actors+ACTOR_X_HI,x
    adc     #0
    sta     actors+ACTOR_X_HI,x     ; x_hi = x_hi + carry

    jmp     do_y

x_neg:
    ; carry already set
    sta     temp                    ; remember value to subtract
    lda     actors+ACTOR_X_LO,x        
    sbc     temp 
    sta     actors+ACTOR_X_LO,x     ; x_lo = x_lo - path_x

    lda     actors+ACTOR_X_HI,x
    sbc     #0
    sta     actors+ACTOR_X_HI,x     ; x_hi = x_hi - !carry

do_y:

    lda     path+PATH_Y,y           ; path_y
    asl
    bcs     y_neg
    clc
    adc     actors+ACTOR_Y_LO,x        
    sta     actors+ACTOR_Y_LO,x     ; y_lo = path_y + y_lo

    lda     actors+ACTOR_Y_HI,x
    adc     #0
    sta     actors+ACTOR_Y_HI,x     ; y_hi = y_hi + carry
    jmp     do_path

y_neg:
    ; carry already set
    sta     temp                    ; remember value to subtract
    lda     actors+ACTOR_Y_LO,x        
    sbc     temp      
    sta     actors+ACTOR_Y_LO,x     ; y_lo = y_lo - path_y

    lda     actors+ACTOR_Y_HI,x
    sbc     #0
    sta     actors+ACTOR_Y_HI,x     ; y_hi = y_hi - !carry

do_path:
    inc     actors+ACTOR_COUNT,x    ; increment count
    lda     actors+ACTOR_COUNT,x    ; actor_count
    cmp     path+PATH_COUNT,y       ; path_count
    bne     path_good

    lda     #0
    sta     actors+ACTOR_X_LO,x     ; reset x_lo to avoid accumulated error
    sta     actors+ACTOR_Y_LO,x     ; reset y_lo to avoid accumulated error
    sta     actors+ACTOR_COUNT,x    ; reset count
    lda     path+PATH_NEXT,y        ; next_path
    beq     reset_path              ; if next is zero, reset 
    sta     actors+ACTOR_PATH,x     ; path = next_path
    jmp     actor_next

reset_path:
    lda     actors+ACTOR_PATH_RESET,x
    sta     actors+ACTOR_PATH,x
    lda     actors+ACTOR_X_RESET,x
    sta     actors+ACTOR_X_HI,x
    lda     actors+ACTOR_Y_RESET,x
    sta     actors+ACTOR_Y_HI,x
    ; LOs and COUNT reset above

path_good:
    jmp     actor_next


temp:   .byte   0

.endproc

;-----------------------------------------------------------------------------
; set_actor
;-----------------------------------------------------------------------------

.proc set_actor
    ldx     actorPtr

    ; copy inputs
    lda     actorState
    sta     actors+ACTOR_STATE,x

    lda     actorShape
    sta     actors+ACTOR_SHAPE,x

    lda     actorPath
    sta     actors+ACTOR_PATH,x
    sta     actors+ACTOR_PATH_RESET,x

    lda     actorX
    sta     actors+ACTOR_X_HI,x
    sta     actors+ACTOR_X_RESET,x

    lda     actorY
    sta     actors+ACTOR_Y_HI,x
    sta     actors+ACTOR_Y_RESET,x

    ; reset values
    lda     #0
    sta     actors+ACTOR_X_LO,x
    sta     actors+ACTOR_Y_LO,x
    sta     actors+ACTOR_COUNT,x

    ; read width from shape table
    ; calculate sprite pointer
    lda     actorShape
    ror
    ror
    ror                     ; Multiply by 64
    and     #$c0
    clc
    adc     #<spriteSheet
    sta     spritePtr0

    lda     #>spriteSheet
    sta     spritePtr1
    lda     actorShape
    lsr
    lsr                     ; Divide by 4
    clc
    adc     spritePtr1
    sta     spritePtr1

    ; Read header
    ldy     #62
    lda     (spritePtr0),y
    sta     actors+ACTOR_WIDTH,x

    ; increment pointer
    clc
    lda     actorPtr
    adc     #ACTOR_SIZE
    cmp     #ACTOR_MAX_COUNT*ACTOR_SIZE
    bne     :+
    lda     #0
:
    sta     actorPtr
    rts

; Local variables
actorPtr:   .byte   0

.endproc


;-----------------------------------------------------------------------------
; clear_actors
;-----------------------------------------------------------------------------

.proc clear_actors
    ldy     #0
loop:
    lda     #0
    sta     actors+ACTOR_STATE,y
    clc
    tya
    adc     #ACTOR_SIZE
    tay
    cpy     #ACTOR_MAX_COUNT*ACTOR_SIZE
    bne     loop
    rts

.endproc

;-----------------------------------------------------------------------------
; draw_actors
;-----------------------------------------------------------------------------
; actor:
;   state           - 0=inactive
;   shape           -
;   path_index      -
;   x_lo            - decimal
;   x_hi            - screen coordinate
;   y_lo            - decimal
;   y_hi            - screen coordinate
;   count           -

.proc draw_actors

    ; set up animation value
    lda     gameClock
    lsr
    lsr
    lsr
    lsr
    and     #1
    sta     animate

    lda     #0              ; point to first actor

actor_loop:
    sta     actor_index
    tax
    lda     actors+ACTOR_STATE,x   ; state
    beq     :+

    lda     actors+ACTOR_X_HI,x
    sta     spriteX
    lda     actors+ACTOR_Y_HI,x
    sta     spriteY
    lda     actors+ACTOR_SHAPE,x
    eor     animate
    jsr     draw_sprite

:
    ; next actor
    clc
    lda     actor_index
    adc     #ACTOR_SIZE
    cmp     #ACTOR_MAX_COUNT*ACTOR_SIZE
    bne     actor_loop

    ; done with list
    rts

actor_index:    .byte   0
animate:        .byte   0
.endproc

;-----------------------------------------------------------------------------
; Globals
;-----------------------------------------------------------------------------

; Interface

actorState:     .byte   0
actorShape:     .byte   0
actorX:         .byte   0
actorY:         .byte   0
actorPath:      .byte   0

; Data

activeCount:    .byte   0
actors:         .res    ACTOR_SIZE*ACTOR_MAX_COUNT

;-----------------------------------------------------------------------------
; Paths
;-----------------------------------------------------------------------------
;
; Paths are all relative.
; 

; Segment (4-bytes)
;   x_speed         d,0.xxxxxxx     s:0=right,1=left
;   y_speed         d,0.yyyyyyy     s:0=up,1=down
;   count           0 = end (explode?), 1-255 duration count
;   next            nnnnnn00 

PATH_X      = 0     ; bit 7 = sign, bit 6:0 magnitude in the form 0.xxxxxxx
PATH_Y      = 1     ; bit 7 = sign, bit 6:0 magnitude in the form 0.yyyyyyy
PATH_COUNT  = 2     ; 1-255 (0=256)
PATH_NEXT   = 3     ; next path




;-----------------------------------------------------------------------------
; Path data
;-----------------------------------------------------------------------------

.align 256

PATH_0_START = path_0 - path
PATH_1_START = path_1 - path
PATH_2_START = path_2 - path

path:

path_0:
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   3   ,   13  ,   122 ,   4   ;   4   -3  6   9   0.1     2   12  12.17   6   9
    .byte   0   ,   0   ,   51  ,   8   ;   6   9   6   9   0.8     0   0   0.00    6   9
    .byte   140 ,   0   ,   40  ,   12  ;   6   9   2   9   0.1     -4  0   4.00    2   9
    .byte   0   ,   0   ,   51  ,   16  ;   2   9   2   9   0.8     0   0   0.00    2   9
    .byte   6   ,   12  ,   201 ,   20  ;   2   9   11  27  0.1     9   18  20.12   11  27
    .byte   0   ,   0   ,   127 ,   0   ;   11  27  11  27  0.5     0   0   0.00    11  27

path_1:
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   0   ,   39  ,   103 ,   0   ;   4   -3  4   28  0.3     0   31  31.00   4   28

path_2:
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   0   ,   64  ,   62  ,   0   ;   4   -3  4   28  0.5     0   31  31.00   4   28
