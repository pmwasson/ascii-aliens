;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; message - display timed messages on screen
;-----------------------------------------------------------------------------

MESSAGE_ENTRY_MAX   = 16

MESSAGE_ENTRY_SIZE  = 5
MESSAGE_ENTRY_TIME  = 0
MESSAGE_ENTRY_PTR0  = 1
MESSAGE_ENTRY_PTR1  = 2
MESSAGE_ENTRY_X     = 3
MESSAGE_ENTRY_Y     = 4

MESSAGE_LIST_SIZE   = 2
MESSAGE_LIST_PTR0   = 0
MESSAGE_LIST_PTR1   = 1

;-----------------------------------------------------------------------------
; set_message
; a = message #
; x = time
; messageX - col
; messageY = row
;-----------------------------------------------------------------------------

.proc set_message
    sta     message_index
    ldy     message_write_ptr
    txa     ; time
    sta     message_array+MESSAGE_ENTRY_TIME,y  ; set time
    lda     messageX
    sta     message_array+MESSAGE_ENTRY_X,y     ; set col
    lda     messageY
    sta     message_array+MESSAGE_ENTRY_Y,y     ; set row

    asl     message_index       ; * 2 since words
    ldx     message_index       
    lda     message_list+MESSAGE_LIST_PTR0,x
    sta     message_array+MESSAGE_ENTRY_PTR0,y
    lda     message_list+MESSAGE_LIST_PTR1,x
    sta     message_array+MESSAGE_ENTRY_PTR1,y

    lda     message_write_ptr
    clc
    adc     #MESSAGE_ENTRY_SIZE
    sta     message_write_ptr
    cmp     #MESSAGE_ENTRY_SIZE*MESSAGE_ENTRY_MAX
    bne     :+
    lda     #0
    sta     message_write_ptr     ; Reset pointer
:

    rts

message_index:   .byte   0

message_write_ptr:
    .byte   0               ; next entry to write

.endproc

;-----------------------------------------------------------------------------
; draw_messages
;
; Loop through all messages and display the active ones.
; Also update counters.
;-----------------------------------------------------------------------------

.proc draw_messages
    lda     #0
    sta     message_read_ptr

message_loop:
    ldy     message_read_ptr

    lda     message_array+MESSAGE_ENTRY_TIME,y
    ; if time is zero, skip
    beq     next_entry

    lda     message_array+MESSAGE_ENTRY_PTR0,y
    sta     stringPtr0
    lda     message_array+MESSAGE_ENTRY_PTR1,y
    sta     stringPtr1

    lda     message_array+MESSAGE_ENTRY_X,y
    ldx     message_array+MESSAGE_ENTRY_Y,y
    clc
    adc     lineOffset,x    ; + lineOffset
    sta     screenPtr0    
    lda     linePage,x
    adc     drawPage        ; previous carry should be clear
    sta     screenPtr1

    ldy     #0
string_loop:
    lda     (stringPtr0),y
    beq     update_time
    sta     (screenPtr0),y
    iny
    cpy     #40             ; don't go off the edge
    bne     string_loop

update_time:
    lda     gameTick
    bne     next_entry

    ldx     message_read_ptr
    dec     message_array+MESSAGE_ENTRY_TIME,x


next_entry:
    lda     message_read_ptr
    clc
    adc     #MESSAGE_ENTRY_SIZE
    sta     message_read_ptr
    cmp     #MESSAGE_ENTRY_SIZE*MESSAGE_ENTRY_MAX
    bne     message_loop 

    rts

message_read_ptr:
    .byte   0               ; next entry to read

.endproc


;-----------------------------------------------------------------------------
; clear_messages
; 
; Note: doesn't bother to reset write pointer
;-----------------------------------------------------------------------------

.proc clear_messages
    ldy     #0
loop:
    lda     #0
    sta     message_array+MESSAGE_ENTRY_TIME,y
    clc
    tya
    adc     #MESSAGE_ENTRY_SIZE
    tay
    cpy     #MESSAGE_ENTRY_SIZE*MESSAGE_ENTRY_MAX
    bne     loop
    rts

.endproc

;-----------------------------------------------------------------------------
; Interface
;-----------------------------------------------------------------------------

messageX:
    .byte   0

messageY:
    .byte   0


;-----------------------------------------------------------------------------
; Message table
;-----------------------------------------------------------------------------

MESSAGE_PEW     = 8
MESSAGE_WAVE1   = 11
MESSAGE_WAVE2   = 12
MESSAGE_WAVE3   = 13
MESSAGE_BOSS    = 14
MESSAGE_TITLE1  = 15
MESSAGE_TITLE2  = 16
MESSAGE_TITLE3  = 17
MESSAGE_START   = 18
MESSAGE_DONE1   = 19
MESSAGE_DONE2   = 20
MESSAGE_WON1    = 21
MESSAGE_WON2    = 22
MESSAGE_BONUS   = 23

message_list:
    .word   message_bad0        ;0
    .word   message_bad1
    .word   message_bad2
    .word   message_bad3
    .word   message_bad4        ; 4
    .word   message_bad5
    .word   message_bad6
    .word   message_bad7
    .word   message_pew         ; 8
    .word   message_life
    .word   message_clear
    .word   message_wave1
    .word   message_wave2       ; 12
    .word   message_wave3
    .word   message_boss
    .word   message_title1
    .word   message_title2      ; 16
    .word   message_title3      
    .word   message_start
    .word   message_done1
    .word   message_done2       ; 20
    .word   message_won1
    .word   message_won2
    .word   message_bonus

;-----------------------------------------------------------------------------
; Message Strings
;-----------------------------------------------------------------------------

message_bad0:
    StringHi0   "OUCH!!"

message_bad1:
    StringHi0   "ARGGG!"

message_bad2:
    StringHi0   "BOOOOM"

message_bad3:
    StringHi0   "@#$%*!"

message_bad4:
    StringHi0   "KA-POW"

message_bad5:
    StringHi0   "BIFF!!"

message_bad6:
    StringHi0   "OOOOF!"

message_bad7:
    StringHi0   "BLAMO!"

message_pew:
    StringHi0   "PEW!"

message_life:
    StringInv0  " --- NEXT LIFE --- "

message_clear:
    StringInv0  " --- WAVE CLEARED --- "

message_wave1:
    StringInv0  " --- WAVE ONE - THE BEGINNING --- "

message_wave2:
    StringInv0  " --- WAVE TWO - ESCALATION --- "

message_wave3:
    StringInv0  " --- WAVE THREE - CONCLUSION --- "

message_boss:
    StringInv0  " --- LARGE ALIEN DETECTED --- "

message_title1:
    StringHi0   "ASCII ALIENS"

message_title2:
    StringHi0   "BY PAUL WASSON, APRIL 2021"

message_title3:
    StringHi0   "PRESS JOYSTICK BUTTON TO BEGIN"

message_start:
    StringInv0  " --- PLAYER START --- "

message_done1:
    StringInv0  " --- GAME OVER --- "

message_done2:
    StringHi0  "TRY AGAIN?"

message_won1:
    StringInv0  " --- YOU WON! --- "

message_won2:
    StringHi0  "THANKS FOR PLAYING"

message_bonus:
    StringInv0  " --- BONUS SHIP AWARDED --- "
    StringInv0  " --- LARGE ALIEN DETECTED --- "


;-----------------------------------------------------------------------------
; Message Data
;-----------------------------------------------------------------------------


message_array:
    ; 5 bytes: time, string-ptr (word), x, y
    .res    MESSAGE_ENTRY_MAX*MESSAGE_ENTRY_SIZE
