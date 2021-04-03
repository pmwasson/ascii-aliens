;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; A collection of sounds
;
; Look into improving sounds using:
;  https://www.applefritter.com/appleii-box/H218ArcadeSoundEditor.htm

;-----------------------------------------------------------------------------
; sound_tone
;-----------------------------------------------------------------------------
; A = tone
; X = duration
.proc sound_tone
loop1:
    sta     SPEAKER
    tay
loop2:
    nop
    nop
    nop
    nop             ; add some delay for lower notes
    dey
    bne     loop2
    dex
    bne     loop1
    rts

.endproc

;-----------------------------------------------------------------------------
; sound_shoot
;-----------------------------------------------------------------------------
.proc sound_shoot
    lda     #50         ; tone
    ldx     #25         ; duration
    jsr     sound_tone
    lda     #190        ; tone
    ldx     #3          ; duration
    jmp     sound_tone  ; link returns
.endproc

;-----------------------------------------------------------------------------
; sound_boom
;-----------------------------------------------------------------------------
.proc sound_boom
    lda     #100        ; tone
    ldx     #20         ; duration
    jsr     sound_tone
    lda     #90         ; tone
    ldx     #10         ; duration
    jmp     sound_tone  ; link returns
.endproc

;-----------------------------------------------------------------------------
; sound_add_ship
;-----------------------------------------------------------------------------
.proc sound_add_ship
    lda     #60         ; tone
    ldx     #15         ; duration
    jsr     sound_tone
    lda     #40         ; tone
    ldx     #10         ; duration
    jmp     sound_tone  ; link returns
.endproc

;-----------------------------------------------------------------------------
; sound_start
;-----------------------------------------------------------------------------
.proc sound_start
    lda     #60         ; tone
    ldx     #100        ; duration
    jsr     sound_tone
    lda     #40         ; tone
    ldx     #100        ; duration
    jmp     sound_tone  ; link returns
.endproc

;-----------------------------------------------------------------------------
; sound_alert
;-----------------------------------------------------------------------------
.proc sound_alert
    lda     #175        ; tone
    ldx     #24         ; duration
    jsr     sound_tone
    lda     #190        ; tone
    ldx     #16         ; duration
    jmp     sound_tone  ; link returns
.endproc




