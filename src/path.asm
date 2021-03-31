;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Paths
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

.align 256

path:

path_0:
    ; Use a spread sheet to figure out paths
    ;       x       y       count   next    x1,y1 -> x2,y2  speed   dx  dy  distance
    .byte   14  ,   49  ,   29  ,   4   ;   2   -9  5   2   0.4     3   11  11.40
    .byte   0   ,   0   ,   153 ,   8   ;   5   2   5   2   0.4     0   0   0.00
    .byte   12  ,   24  ,   22  ,   12  ;   5   2   7   6   0.2     2   4   4.47
    .byte   148 ,   16  ,   32  ,   16  ;   7   6   2   10  0.2     -5  4   6.40
    .byte   0   ,   0   ,   204 ,   20  ;   2   10  2   10  0.2     0   0   0.00
    .byte   39  ,   52  ,   10  ,   24  ;   2   10  5   14  0.5     3   4   5.00
    .byte   0   ,   0   ,   25  ,   28  ;   5   14  5   14  0.9     0   0   0.00
    .byte   133 ,   25  ,   72  ,   32  ;   5   14  2   28  0.2     -3  14  14.32
    .byte   0   ,   153 ,   185 ,   36  ;   2   28  2   -9  0.2     0   -37 37.00


; Sequence
;----------------
; Encoding      command     arguments                   - description
;
; 0x00          dly         
; 0x10          dly_int     
; 0x20          dly_act     
; 0x30          jmp         
; 0x40          clr_msg     
; 0x50          clr_shp     
; 0x60          clr_ply     
; 0x70          clr_act     
; 0x80          add_msg     
; 0x90          add_shp     
; 0xa0          add_ply     
; 0xb0          add_act     


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
SEQ_ADD_MSG     =   $80     ; message-index, x, y, time     display a message  
SEQ_ADD_SHP     =   $90     ;                               add a ship
SEQ_ADD_PLY     =   $A0     ;                               display player
SEQ_ADD_ACT     =   $B0     ; shape, x, y, path             add actor
SEQ_SUB_SHP     =   $90     ; index                         remove ship, if none left goto index
SEQ_SET_CKP     =   $C0     ;                               set checkpoint
SEQ_JMP_CKP     =   $D0     ;                               jump to checkpoint
.align 256

seq_start:
    ; clear everything
    .byte   SEQ_CLR_MSG
    .byte   SEQ_CLR_SHP
    .byte   SEQ_CLR_PLY
    .byte   SEQ_CLR_ACT
    ; title sequence
    .byte   SEQ_ADD_MSG,    MESSAGE_TITLE1,  6, 5, 10
    .byte   SEQ_DLY_INT,    2, seq_game_start - seq_start
    .byte   SEQ_ADD_MSG,    MESSAGE_TITLE2,  11, 5, 8
    .byte   SEQ_DLY_INT,    2, seq_game_start - seq_start
    .byte   SEQ_ADD_MSG,    MESSAGE_TITLE3,  16, 5, 14
    .byte   SEQ_DLY_INT,    15, seq_game_start - seq_start
    .byte   SEQ_JMP,        seq_start - seq_start
seq_game_start:
    ; pre-level
    .byte   SEQ_CLR_MSG
    .byte   SEQ_ADD_MSG,    MESSAGE_START,  11, 5, 10
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_SHP
    .byte   SEQ_DLY,        2
    .byte   SEQ_ADD_PLY         ; Give player control
    .byte   SEQ_DLY,        5
    .byte   SEQ_ADD_MSG,    MESSAGE_WAVE1,  11, 5, 10
    .byte   SEQ_DLY,        11
    ; First 4
    .byte   SEQ_SET_CKP
    .byte   SEQ_ADD_ACT,    6, 4, 256-5, 0
    .byte   SEQ_DLY,        3
    .byte   SEQ_ADD_ACT,    6, 12, 256-5, 0
    .byte   SEQ_DLY,        3
    .byte   SEQ_ADD_ACT,    6, 20, 256-5, 0
    .byte   SEQ_DLY,        3
    .byte   SEQ_ADD_ACT,    6, 28, 256-5, 0
    .byte   SEQ_DLY_ACT
    ; Next 3
    .byte   SEQ_SET_CKP
    .byte   SEQ_ADD_ACT,    10, 4, 256-5, 1
    .byte   SEQ_ADD_ACT,    10, 12, 256-5, 1
    .byte   SEQ_ADD_ACT,    10, 20, 256-5, 1
    .byte   SEQ_ADD_ACT,    10, 28, 256-5, 1
    .byte   SEQ_DLY_ACT
    ; Final
    .byte   SEQ_SET_CKP
    .byte   SEQ_ADD_ACT,    8, 17, 256-5, 1
    .byte   SEQ_DLY_ACT
    ;
    ; TODO - more waves
    ;
seq_game_won:
    ;
    ; TODO - winning sequence
    ;
    ; Go back to title
    .byte   SEQ_JMP,        seq_start - seq_start

seq_lost_ship:
    ; clean up
    .byte   SEQ_CLR_ACT
    .byte   SEQ_CLR_MSG
    ; if no more ships, game over
    .byte   SEQ_SUB_SHP,    seq_game_over - seq_start
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
    .byte   SEQ_ADD_MSG,    MESSAGE_DONE,  11, 5, 20
    ; De-bounce
    .byte   SEQ_DLY,        5
    ; Go back to title
    .byte   SEQ_DLY_INT,    20-5, seq_start - seq_start
    .byte   SEQ_JMP,        seq_start - seq_start

