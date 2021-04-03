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
    jsr     seq_death

    ; Update actor state
    ;--------------------------------------
kill:
    ; clear bullet
    lda     #INACTIVE_Y
    sta     bulletY 

    ; decrease state
    dec     actors+ACTOR_STATE,x
    beq     :+
    inc     activeCount     ; not dead yet!
:
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

PATH_TITLE      = path_title    - path
PATH_CRAWL_1    = path_crawl_1  - path
PATH_CRAWL_2    = path_crawl_2  - path
PATH_FALL_1     = path_fall_1   - path
PATH_FALL_2     = path_fall_2   - path
PATH_FALL_3     = path_fall_3   - path
PATH_CIRCLE_1   = path_circle_1 - path
PATH_CIRCLE_2   = path_circle_2 - path
PATH_CIRCLE_3   = path_circle_3 - path

path:

path_crawl_1:
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   3   ,   14  ,   116 ,   4   ;   4   -3  6   9   0.105   2   12  12.17   6   9
    .byte   0   ,   0   ,   51  ,   8   ;   6   9   6   9   0.8     0   0   0.00    6   9
    .byte   141 ,   0   ,   38  ,   12  ;   6   9   2   9   0.105   -4  0   4.00    2   9
    .byte   0   ,   0   ,   51  ,   16  ;   2   9   2   9   0.8     0   0   0.00    2   9
    .byte   6   ,   12  ,   192 ,   20  ;   2   9   11  27  0.105   9   18  20.12   11  27
    .byte   0   ,   0   ,   127 ,   0   ;   11  27  11  27  0.5     0   0   0.00    11  27

path_fall_1:
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   0   ,   39  ,   103 ,   0   ;   4   -3  4   28  0.3     0   31  31.00   4   28

path_fall_2:
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   0   ,   64  ,   62  ,   0   ;   4   -3  4   28  0.5     0   31  31.00   4   28

path_fall_3:
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   0   ,   91  ,   44  ,   0   ;   4   -3  4   28  0.7     0   31  31.00   4   28

path_circle_2:
    .byte   158 ,   24  ,   64  ,   40  ;   17  -3  2   9   0.3     -15 12  19.21   2   9
    .byte   32  ,   22  ,   65  ,   44  ;   2   9   18  20  0.3     16  11  19.42   18  20
    .byte   32  ,   149 ,   60  ,   48  ;   18  20  33  10  0.3     15  -10 18.03   33  10
    .byte   164 ,   12  ,   109 ,   52  ;   33  10  2   20  0.3     -31 10  32.57   2   20
    .byte   26  ,   156 ,   80  ,   56  ;   2   20  18  2   0.3     16  -18 24.08   18  2
    .byte   25  ,   30  ,   78  ,   60  ;   18  2   33  20  0.3     15  18  23.43   33  20
    .byte   164 ,   140 ,   110 ,   40  ;   33  20  2   9   0.3     -31 -11 32.89   2   9

path_circle_3:
    .byte   41  ,   31  ,   50  ,   68  ;   17  -3  33  9   0.4     16  12  20.00   33  9
    .byte   168 ,   30  ,   47  ,   72  ;   33  9   18  20  0.4     -15 11  18.60   18  20
    .byte   171 ,   155 ,   47  ,   76  ;   18  20  2   10  0.4     -16 -10 18.87   2   10
    .byte   49  ,   16  ,   81  ,   80  ;   2   10  33  20  0.4     31  10  32.57   33  20
    .byte   160 ,   167 ,   59  ,   84  ;   33  20  18  2   0.4     -15 -18 23.43   18  2
    .byte   162 ,   39  ,   60  ,   88  ;   18  2   2   20  0.4     -16 18  24.08   2   20
    .byte   49  ,   145 ,   82  ,   68  ;   2   20  33  9   0.4     31  -11 32.89   33  9
             
path_circle_1:
    .byte   16  ,   23  ,   130 ,   96  ;   17  -3  33  20  0.215   16  23  28.02   33  20  
    .byte   148 ,   146 ,   92  ,   100 ;   33  20  18  7   0.215   -15 -13 19.85   18  7   
    .byte   0   ,   28  ,   60  ,   104 ;   18  7   18  20  0.215   0   13  13.00   18  20  
    .byte   149 ,   145 ,   96  ,   108 ;   18  20  2   7   0.215   -16 -13 20.62   2   7   
    .byte   0   ,   28  ,   60  ,   112 ;   2   7   2   20  0.215   0   13  13.00   2   20  
    .byte   22  ,   145 ,   96  ,   116 ;   2   20  18  7   0.215   16  -13 20.62   18  7   
    .byte   0   ,   28  ,   60  ,   120 ;   18  7   18  20  0.215   0   13  13.00   18  20  
    .byte   21  ,   146 ,   92  ,   124 ;   18  20  33  7   0.215   15  -13 19.85   33  7   
    .byte   0   ,   28  ,   60  ,   96  ;   33  7   33  20  0.215   0   13  13.00   33  20  

path_crawl_2:
    .byte   130 ,   14  ,   116 ,   132 ;   30  -3  28  9   0.105   -2  12  12.17   28  9   
    .byte   0   ,   0   ,   51  ,   136 ;   28  9   28  9   0.8     0   0   0.00    28  9   
    .byte   14  ,   0   ,   38  ,   140 ;   28  9   32  9   0.105   4   0   4.00    32  9   
    .byte   0   ,   0   ,   51  ,   144 ;   32  9   32  9   0.8     0   0   0.00    32  9   
    .byte   134 ,   12  ,   192 ,   148 ;   32  9   23  27  0.105   -9  18  20.12   23  27  
    .byte   0   ,   0   ,   127 ,   0   ;   23  27  23  27  0.5     0   0   0.00    23  27  

path_title:
    .byte   0   ,   12  ,   111 ,   156 ;   35  -3  35  7   0.09        0   10  10.00   35  7
    .byte   139 ,   0   ,   189 ,   160 ;   35  7   18  7   0.09        -17 0   17.00   18  7
    .byte   139 ,   0   ,   189 ,   164 ;   18  7   1   7   0.09        -17 0   17.00   1   7
    .byte   0   ,   12  ,   233 ,   168 ;   1   7   1   28  0.09        0   21  21.00   1   28
    .byte   0   ,   0   ,   242 ,   168 ;   1   28  1   28  0.05        0   0   0.00    1   28
