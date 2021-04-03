;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Sequence
;
; Byte-code game script
; 

;------------------------------------------------
; Zero page usage
;------------------------------------------------

seqPtr0         :=  $FC
seqPtr1         :=  $FD

;------------------------------------------------
; Byte-code
;------------------------------------------------

; Command       Encoding      Arguments                     Description
;-------------  --------      ----------------------------- -----------------------------------------------------
SEQ_BRK         =   $00     ;                               cause break
SEQ_DLY         =   $08     ; time                          wait time
SEQ_DLY_INT     =   $10     ; time index*2                  wait time, index to jump to if interrupted by button
SEQ_DLY_ACT     =   $18     ;                               wait until no actors
SEQ_JMP         =   $20     ; index*2                       jump to index
SEQ_CLR_MSG     =   $28     ;                               clear all messages
SEQ_CLR_SHP     =   $30     ;                               remove all ships
SEQ_CLR_PLY     =   $38     ;                               remove player
SEQ_CLR_ACT     =   $40     ;                               remove all actors
SEQ_ADD_MSG     =   $48     ; x, y, time, message-index     display a message  
SEQ_ADD_SHP     =   $50     ;                               add a ship
SEQ_ADD_PLY     =   $58     ;                               display player
SEQ_ADD_ACT     =   $60     ; shape, x, y, path, state      add actor
SEQ_SUB_SHP     =   $68     ; index*2                       remove ship, if none left goto index
SEQ_SET_CKP     =   $70     ;                               set checkpoint
SEQ_JMP_CKP     =   $78     ;                               jump to checkpoint
SEQ_SYN_ACT     =   $80     ;                               synchronize actors
SEQ_ALR         =   $88     ;                               play alert sound

SEQ_BRK_LEN     =   1
SEQ_DLY_LEN     =   2
SEQ_DLY_INT_LEN =   4
SEQ_DLY_ACT_LEN =   1
SEQ_JMP_LEN     =   3
SEQ_CLR_MSG_LEN =   1
SEQ_CLR_SHP_LEN =   1
SEQ_CLR_PLY_LEN =   1
SEQ_CLR_ACT_LEN =   1
SEQ_ADD_MSG_LEN =   5
SEQ_ADD_SHP_LEN =   1
SEQ_ADD_PLY_LEN =   1
SEQ_ADD_ACT_LEN =   6
SEQ_SUB_SHP_LEN =   3
SEQ_SET_CKP_LEN =   1
SEQ_JMP_CKP_LEN =   1
SEQ_SYN_ACT_LEN =   1
SEQ_ALR_LEN     =   1

.align 256


;-----------------------------------------------------------------------------
; seq_init
;-----------------------------------------------------------------------------
; This could be in the main code, but to keep thing separated, make a tiny
; subroutine to set the zero page pointer.

.proc seq_init   
    lda     #<seq_start
    sta     seqPtr0
    lda     #>seq_start
    sta     seqPtr1
    rts
.endproc

;-----------------------------------------------------------------------------
; seq_death
;-----------------------------------------------------------------------------
; This could be in the main code, but to keep thing separated, make a tiny
; subroutine to set the zero page pointer.

.proc seq_death   
    lda     #<seq_lost_ship
    sta     seqPtr0
    lda     #>seq_lost_ship
    sta     seqPtr1
    rts
.endproc

;-----------------------------------------------------------------------------
; seq_step
;-----------------------------------------------------------------------------

.proc seq_step   

    ; read byte
    ldy     #0
    lda     (seqPtr0),y

delay:
    cmp     #SEQ_DLY
    bne     delayInt

    jsr     seq_delay
    bcc     :+

    ; go to next instruction
    lda     #SEQ_DLY_LEN
    jmp     seq_next
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
    iny
    jmp     seq_index
:
    jsr     seq_delay
    bcc     :+

    ; go to next instruction
    lda     #SEQ_DLY_INT_LEN
    jmp     seq_next
:
    rts

delayAct:
    cmp     #SEQ_DLY_ACT
    bne     jump

    lda     activeCount
    bne     :+

    lda     #SEQ_DLY_ACT_LEN
    jmp     seq_next
:
    rts

jump:
    cmp     #SEQ_JMP
    bne     seq_clear_message
    jmp     seq_index


seq_clear_message:
    cmp     #SEQ_CLR_MSG
    bne     clear_ship

    jsr     clear_messages
    lda     #SEQ_CLR_MSG_LEN
    jmp     seq_next

clear_ship:
    cmp     #SEQ_CLR_SHP
    bne     clear_player

    lda     #0
    sta     shipCount

    lda     #SEQ_CLR_SHP_LEN
    jmp     seq_next

clear_player:
    cmp     #SEQ_CLR_PLY
    bne     seq_clear_actors

    lda     #INACTIVE_Y
    sta     playerY
    sta     bulletY

    lda     #SEQ_CLR_PLY_LEN
    jmp     seq_next


seq_clear_actors:
    cmp     #SEQ_CLR_ACT
    bne     add_message

    jsr     clear_actors
    lda     #SEQ_CLR_ACT_LEN
    jmp     seq_next

add_message:
    cmp     #SEQ_ADD_MSG
    bne     add_ship

    iny                 ; 1
    lda     (seqPtr0),y
    sta     messageX
    iny                 ; 2
    lda     (seqPtr0),y
    sta     messageY
    iny                 ; 3
    lda     (seqPtr0),y
    tax
    iny                 ; 4
    lda     (seqPtr0),y
    jsr     set_message

    ; go to next instruction
    lda     #SEQ_ADD_MSG_LEN
    jmp     seq_next

add_ship:
    cmp     #SEQ_ADD_SHP
    bne     add_player

    inc     shipCount
    jsr     sound_add_ship

    lda     #SEQ_ADD_SHP_LEN
    jmp     seq_next 

add_player:
    cmp     #SEQ_ADD_PLY
    bne     add_actor

    jsr     sound_start

    ; set player coordinates
    lda     #PLAYER_ACTIVE_X
    sta     playerX
    lda     #PLAYER_ACTIVE_Y
    sta     playerY

    ; go to next instruction
    lda     #SEQ_ADD_PLY_LEN
    jmp     seq_next   

add_actor:
    cmp     #SEQ_ADD_ACT
    bne     sub_ship

    ;FIXME - add to arguments


    iny                 ; 1
    lda     (seqPtr0),y
    sta     actorShape
    iny                 ; 2
    lda     (seqPtr0),y
    sta     actorX
    iny                 ; 3
    lda     (seqPtr0),y
    sta     actorY
    iny                 ; 4
    lda     (seqPtr0),y
    sta     actorPath
    iny                 ; 5
    lda     (seqPtr0),y
    sta     actorState

    jsr     set_actor

    ; go to next instruction
    lda     #SEQ_ADD_ACT_LEN
    jmp     seq_next

sub_ship:
    cmp     #SEQ_SUB_SHP
    bne     set_chk

    dec     shipCount
    bne     :+

    ; jump to index
    jmp     seq_index
:
    ; go to next instruction
    lda     #SEQ_SUB_SHP_LEN
    jmp     seq_next

set_chk:
    cmp     #SEQ_SET_CKP
    bne     jump_chk

    ; manually update pointer so we can set checkpoint
    inc     seqPtr0
    bne     :+
    inc     seqPtr1
:
    lda     seqPtr0
    sta     seqCheckPoint0
    lda     seqPtr1
    sta     seqCheckPoint1

    rts  

jump_chk:
    cmp     #SEQ_JMP_CKP
    bne     syn_act

    lda     seqCheckPoint0
    sta     seqPtr0
    lda     seqCheckPoint1
    sta     seqPtr1
    rts

syn_act:
    cmp     #SEQ_SYN_ACT
    bne     seq_alert

    jsr     sync_actors

    ; go to next instruction
    lda     #SEQ_SYN_ACT_LEN
    jmp     seq_next

seq_alert:
    cmp     #SEQ_ALR
    bne     seq_error

    jsr     sound_alert

    ; go to next instruction
    lda     #SEQ_ALR_LEN
    jmp     seq_next

seq_error:
    ; We should never have a bad instruction
    sta     LOWSCR      ; make sure visible
    brk

seq_next:
    clc
    adc     seqPtr0
    sta     seqPtr0
    lda     #0
    adc     seqPtr1
    sta     seqPtr1
    rts

seq_index:
    iny
    lda     (seqPtr0),y
    tax
    iny
    lda     (seqPtr0),y
    sta     seqPtr1
    stx     seqPtr0
    rts

seqCheckPoint0: .byte   0
seqCheckPoint1: .byte   0

.endproc


.proc seq_delay
    clc

    ; check if first time through
    lda     delayTimer
    bne     :+

    ; Initialize timer
    iny
    lda     (seqPtr0),y
    sta     delayTimer
    rts
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

delayTimer:     .byte   0

;-----------------------------------------------------------------------------
; Sequence Data
;-----------------------------------------------------------------------------

.align 256

seq_start:
    ; clear everything
    .byte   SEQ_SET_CKP
    .byte   SEQ_CLR_MSG
    .byte   SEQ_CLR_SHP
    .byte   SEQ_CLR_PLY
    .byte   SEQ_CLR_ACT

    ; title sequence
    .byte   SEQ_DLY,        5                                       ; 5
    .byte   SEQ_ADD_MSG,    14, 5, 120-5, MESSAGE_TITLE1            ;         5.........120
    .byte   SEQ_DLY_INT,    15, <seq_game_start, >seq_game_start    ; 5+15
    .byte   SEQ_ADD_MSG,    7, 20, 115-20, MESSAGE_TITLE2           ;          20......115
    .byte   SEQ_DLY_INT,    30, <seq_game_start, >seq_game_start    ; 20+30
    .byte   SEQ_ADD_MSG,    5, 12 , 110-50, MESSAGE_TITLE3           ;             50...110
    .byte   SEQ_DLY_INT,    10, <seq_game_start, >seq_game_start    ; 50 + 70
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 35,  256-3, PATH_TITLE, 1
    .byte   SEQ_DLY_INT,    60, <seq_game_start, >seq_game_start    ; 50 + 70
    .byte   SEQ_JMP,        <seq_start, >seq_start

seq_game_start:
    ; pre-level
    .byte   SEQ_SET_CKP
    .byte   SEQ_CLR_ACT
    .byte   SEQ_CLR_MSG
    .byte   SEQ_ADD_MSG,    9, 16, 10, MESSAGE_START
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        1
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        1
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        5
    .byte   SEQ_ADD_PLY     ; Give player control
    .byte   SEQ_DLY,        10

seq_wave_1:
    .byte   SEQ_ADD_MSG,    3, 5, 10, MESSAGE_WAVE1
    .byte   SEQ_DLY,        10

    ; 1.1
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 4,  256-3, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 16, 256-5, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 28, 256-6, PATH_CRAWL_1, 1
    .byte   SEQ_DLY_ACT

    ; 1.2
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 4,  256-3, PATH_FALL_1, 1
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 17, 256-3, PATH_FALL_1, 1
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 31, 256-3, PATH_FALL_1, 1
    .byte   SEQ_DLY_ACT

    ; 1.3
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD1, 17, 256-3, PATH_CIRCLE_1, 5
    .byte   SEQ_DLY_ACT

seq_wave_2:
    .byte   SEQ_ADD_MSG,    3, 5, 10, MESSAGE_WAVE2
    .byte   SEQ_DLY,        10

    ; 2.1
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 4,  256-1, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 12, 256-1, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 22, 256-1, PATH_CRAWL_2, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 30, 256-1, PATH_CRAWL_2, 1
    .byte   SEQ_DLY,        4
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 8,  256-4, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 21, 256-4, PATH_CRAWL_2, 1
    .byte   SEQ_DLY_ACT

    ; 2.2
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 4,  256-3, PATH_FALL_2, 1
    .byte   SEQ_DLY,        1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 12, 256-3, PATH_FALL_2, 1
    .byte   SEQ_DLY,        1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 20, 256-3, PATH_FALL_2, 1
    .byte   SEQ_DLY,        1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 28, 256-3, PATH_FALL_2, 1
    .byte   SEQ_DLY_ACT

    ; 2.3
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD1, 17, 256-3, PATH_CIRCLE_2, 10
    .byte   SEQ_DLY_ACT


seq_wave_3:
    .byte   SEQ_ADD_MSG,    3, 5, 10, MESSAGE_WAVE3
    .byte   SEQ_DLY,        10

    ; 3.1
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 4,  256-1, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 12, 256-1, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 22, 256-1, PATH_CRAWL_2, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 30, 256-1, PATH_CRAWL_2, 1
    .byte   SEQ_DLY,        5
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 4,  256-4, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 12, 256-4, PATH_CRAWL_1, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 22, 256-4, PATH_CRAWL_2, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD0, 30, 256-4, PATH_CRAWL_2, 1
    .byte   SEQ_DLY_ACT

    ; 3.2
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 2,  256-3, PATH_FALL_3, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 12, 256-3, PATH_FALL_3, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 22, 256-3, PATH_FALL_3, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 32, 256-3, PATH_FALL_3, 1
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 7,  256-4, PATH_FALL_3, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 17, 256-4, PATH_FALL_3, 1
    .byte   SEQ_ADD_ACT,    SPRITE_BAD2, 27, 256-4, PATH_FALL_3, 1
    .byte   SEQ_DLY_ACT

    ; 3.3
    .byte   SEQ_SET_CKP
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_ACT,    SPRITE_BAD1, 17, 256-3, PATH_CIRCLE_2, 20
    .byte   SEQ_DLY_ACT

seq_boss:
    .byte   SEQ_SET_CKP
    .byte   SEQ_ADD_MSG,    5, 5, 10, MESSAGE_BOSS
    .byte   SEQ_ALR
    .byte   SEQ_DLY,        20
    .byte   SEQ_ADD_ACT,    SPRITE_BOSSH,  17,  256-7, PATH_BOSS_1, 10
    .byte   SEQ_ADD_ACT,    SPRITE_BOSSAL, 14,  256-4, PATH_BOSS_3, 10
    .byte   SEQ_ADD_ACT,    SPRITE_BOSSB,  17,  256-4, PATH_BOSS_1, 10
    .byte   SEQ_ADD_ACT,    SPRITE_BOSSAR, 22,  256-4, PATH_BOSS_3, 10
    .byte   SEQ_ADD_ACT,    SPRITE_BOSSL,  17,  256-1, PATH_BOSS_2, 10
    .byte   SEQ_SYN_ACT
    .byte   SEQ_DLY_ACT

seq_game_won:
    .byte   SEQ_ADD_MSG,    11, 5, 20, MESSAGE_WON1
    .byte   SEQ_DLY,        15

    .byte   SEQ_CLR_SHP
    .byte   SEQ_CLR_PLY

    .byte   SEQ_ADD_MSG,    11, 14 , 20, MESSAGE_WON2   
    .byte   SEQ_DLY,        25

    ; Go back to title
    .byte   SEQ_JMP,        <seq_start, >seq_start

seq_lost_ship:
    ; let player notice the death
    .byte   SEQ_DLY,    10
    ; if no more ships, game over
    .byte   SEQ_SUB_SHP,    <seq_game_over, >seq_game_over
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
    .byte   SEQ_ADD_MSG,    11, 5, 40, MESSAGE_DONE1
    .byte   SEQ_DLY,        10
    .byte   SEQ_ADD_MSG,    16, 14, 30, MESSAGE_DONE2
    ; Go back to title
    .byte   SEQ_DLY_INT,    30, <seq_start, >seq_start
    .byte   SEQ_JMP,        <seq_start, >seq_start

