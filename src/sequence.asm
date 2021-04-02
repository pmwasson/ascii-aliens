;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Sequence
;
; Byte-code game script
; 

; Command       Encoding      Arguments                     Description
;-------------  --------      ----------------------------- -----------------------------------------------------
SEQ_DLY         =   $00     ; time                          wait time
SEQ_DLY_INT     =   $10     ; time index                    wait time, index to jump to if interrupted by button
SEQ_DLY_ACT     =   $20     ;                               wait until no actors
SEQ_JMP         =   $30     ; index                         jump to index
SEQ_CLR_MSG     =   $40     ;                               clear all messages
SEQ_CLR_SHP     =   $50     ;                               remove all ships
SEQ_CLR_PLY     =   $60     ;                               remove player
SEQ_CLR_ACT     =   $70     ;                               remove all actors
SEQ_ADD_MSG     =   $80     ; time, message-index, x, y     display a message  
SEQ_ADD_SHP     =   $90     ;                               add a ship
SEQ_ADD_PLY     =   $A0     ;                               display player
SEQ_ADD_ACT     =   $B0     ; shape, x, y, path             add actor
SEQ_SUB_SHP     =   $C0     ; index                         remove ship, if none left goto index
SEQ_SET_CKP     =   $D0     ;                               set checkpoint
SEQ_JMP_CKP     =   $E0     ;                               jump to checkpoint
SEQ_BRK         =   $FF     ;                               cause break

.align 256


;-----------------------------------------------------------------------------
; seq_step
;-----------------------------------------------------------------------------

.proc seq_step   

    ; read byte
    ldy     seqIndex
    lda     seq_start,y

delay:
    ;cmp     #SEQ_DLY      -- don't need to compare to zero
    bne     delayInt

    jsr     seq_delay
    bcc     :+

    ; go to next instruction
    iny
    iny
    sty     seqIndex
:
    rts

delayInt:
    cmp     #SEQ_DLY_INT
    bne     delayAct

    ; check for button
    bit     BUTTON0
    bpl     :+

    ; interrupted by button
    lda     #0
    sta     delayTimer
    lda     seq_start+2,y
    sta     seqIndex
    rts
:
    jsr     seq_delay
    bcc     :+

    ; go to next instruction
    iny
    iny
    iny
    sty     seqIndex
:
    rts

delayAct:
    cmp     #SEQ_DLY_ACT
    bne     jump

    lda     activeCount
    bne     :+

    inc     seqIndex        ; go to next instruction
:
    rts

jump:
    cmp     #SEQ_JMP
    bne     clear_message

    lda     seq_start+1,y
    sta     seqIndex
    rts

clear_message:
    cmp     #SEQ_CLR_MSG
    bne     clear_ship

    inc     seqIndex        ; go to next instruction
    jmp     clear_messages  ; link return

clear_ship:
    cmp     #SEQ_CLR_SHP
    bne     clear_player

    lda     #0
    sta     shipCount

    inc     seqIndex        ; go to next instruction
    rts

clear_player:
    cmp     #SEQ_CLR_PLY
    bne     seq_clear_actors

    lda     #$ff
    sta     playerY

    inc     seqIndex        ; go to next instruction
    rts

seq_clear_actors:
    cmp     #SEQ_CLR_ACT
    bne     add_message

    inc     seqIndex        ; go to next instruction
    jmp     clear_actors    ; link return

add_message:
    cmp     #SEQ_ADD_MSG
    bne     add_ship

    lda     seq_start+3,y
    sta     messageX
    lda     seq_start+4,y
    sta     messageY
    ldx     seq_start+1,y
    lda     seq_start+2,y
    jsr     set_message

    ; go to next instruction
    clc
    lda     seqIndex
    adc     #5
    sta     seqIndex

    rts

add_ship:
    cmp     #SEQ_ADD_SHP
    bne     add_player

    inc     shipCount
    inc     seqIndex        ; go to next instruction

    jsr     sound_add_ship

    rts    

add_player:
    cmp     #SEQ_ADD_PLY
    bne     add_actor

    ; set player coordinates
    lda     #PLAYER_ACTIVE_X
    sta     playerX
    lda     #PLAYER_ACTIVE_Y
    sta     playerY

    inc     seqIndex        ; go to next instruction
    rts    

add_actor:
    cmp     #SEQ_ADD_ACT
    bne     sub_ship

    ;FIXME - add to arguments
    lda     #1
    sta     actorState

    lda     seq_start+1,y
    sta     actorShape
    lda     seq_start+2,y
    sta     actorX
    lda     seq_start+3,y
    sta     actorY
    lda     seq_start+4,y
    sta     actorPath
    jsr     set_actor

    ; go to next instruction
    clc
    lda     seqIndex
    adc     #5
    sta     seqIndex
    rts

sub_ship:
    cmp     #SEQ_SUB_SHP
    bne     set_chk

    ; pre-read next index
    lda     seq_start+1,y

    ; go to next instruction
    iny
    iny
    sty     seqIndex        

    dec     shipCount
    bne     :+
    sta     seqIndex     
:
    rts

set_chk:
    cmp     #SEQ_SET_CKP
    bne     jump_chk

    iny
    sty     seqCheckPoint
    sty     seqIndex
    rts  

jump_chk:
    cmp     #SEQ_JMP_CKP
    bne     seq_error

    lda     seqCheckPoint
    sta     seqIndex
    rts

seq_error:
    ; We should never have a bad instruction
    sta     LOWSCR      ; make sure visible
    brk

seqCheckPoint:  .byte   0

.endproc


; Note, preserves Y

.proc seq_delay
    clc

    ; check if first time through
    lda     delayTimer
    bne     :+

    ; Initialize timer
    lda     seq_start+1,y
    sta     delayTimer
    rts                     ; A = timer
:
    lda     gameTick
    beq     :+
    rts
:
    ; decrement timer and check if zero
    dec     delayTimer
    beq     :+
    rts
:
    sec
    rts

.endproc


;-----------------------------------------------------------------------------
; Global
;-----------------------------------------------------------------------------

seqIndex:       .byte   0
delayTimer:     .byte   0

;-----------------------------------------------------------------------------
; Sequence Data
;-----------------------------------------------------------------------------

.align 256

SEQ_DEATH = seq_lost_ship - seq_start

seq_start:
    ; clear everything
    .byte   SEQ_SET_CKP
    .byte   SEQ_CLR_MSG
    .byte   SEQ_CLR_SHP
    .byte   SEQ_CLR_PLY
    .byte   SEQ_CLR_ACT

    ; title sequence
    .byte   SEQ_DLY_INT,    5, seq_game_start - seq_start       ; 5
    .byte   SEQ_ADD_MSG,    100-5, MESSAGE_TITLE1,  14, 5       ;         5.........90
    .byte   SEQ_DLY_INT,    15, seq_game_start - seq_start      ; 5+15
    .byte   SEQ_ADD_MSG,    100-20, MESSAGE_TITLE2,  7, 20     ;           20......90
    .byte   SEQ_DLY_INT,    30, seq_game_start - seq_start      ; 20+30
    .byte   SEQ_ADD_MSG,    90-50, MESSAGE_TITLE3,  5, 12       ;             50...80
    .byte   SEQ_DLY_INT,    40, seq_game_start - seq_start      ; 50 + 40
    .byte   SEQ_JMP,        seq_start - seq_start

seq_game_start:
    ; pre-level
    .byte   SEQ_SET_CKP
    .byte   SEQ_CLR_MSG
    .byte   SEQ_ADD_MSG,    10, MESSAGE_START,  9, 16
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        1
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        1
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        5
    .byte   SEQ_ADD_PLY     ; Give player control
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_MSG,    10, MESSAGE_WAVE1,  3, 5
    .byte   SEQ_DLY,        10

    ; First
    .byte   SEQ_SET_CKP
    .byte   SEQ_ADD_ACT,    6, 4,  256-3, PATH_0_START
    .byte   SEQ_DLY_ACT

    ; Next 3
    .byte   SEQ_SET_CKP
    .byte   SEQ_ADD_ACT,    6, 4,  256-3, PATH_0_START
    .byte   SEQ_ADD_ACT,    6, 12, 256-4, PATH_0_START
    .byte   SEQ_DLY_ACT

    ; Final
    .byte   SEQ_SET_CKP
    .byte   SEQ_ADD_ACT,    6, 4,  256-3, PATH_0_START
    .byte   SEQ_ADD_ACT,    6, 12, 256-4, PATH_0_START
    .byte   SEQ_ADD_ACT,    6, 20, 256-5, PATH_0_START
    .byte   SEQ_ADD_ACT,    6, 28, 256-6, PATH_0_START
    .byte   SEQ_DLY_ACT

    ;
    ; TODO - more waves
    ;
seq_game_won:
    .byte   SEQ_ADD_MSG,    20, MESSAGE_WON,  11, 5    
    .byte   SEQ_DLY,        25

    ; Go back to title
    .byte   SEQ_JMP,        seq_start - seq_start

seq_lost_ship:
    ; let player notice the death
    .byte   SEQ_DLY,    10
    ; if no more ships, game over
    .byte   SEQ_SUB_SHP,    seq_game_over - seq_start
    ; clean up
    .byte   SEQ_CLR_ACT
    .byte   SEQ_CLR_MSG
    ; put player back on the screen
    .byte   SEQ_ADD_PLY
    ; give player a moment to focus
    .byte   SEQ_DLY,    5
    ; go to last checkpoint
    .byte   SEQ_JMP_CKP

seq_game_over:
    ; clear everything
    .byte   SEQ_CLR_MSG
    .byte   SEQ_CLR_SHP
    .byte   SEQ_CLR_PLY
    .byte   SEQ_CLR_ACT
    ; Display message
    .byte   SEQ_ADD_MSG,    20, MESSAGE_DONE,  11, 5
    ; De-bounce
    .byte   SEQ_DLY,        5
    ; Go back to title
    .byte   SEQ_DLY_INT,    20-5, seq_start - seq_start
    .byte   SEQ_JMP,        seq_start - seq_start

