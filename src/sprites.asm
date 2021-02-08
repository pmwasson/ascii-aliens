;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Sprites

.align 256

spriteSheet:

sprite_playerShip0:
    StringHiBG  "./|\." , '.'
    StringHiBG  "</^\>" , '.'
    SpriteInfo  5,2             ; 5 by 2

sprite_kiteM:
    StringHiBG  "O...O" , '.'
    StringHiBG  "|\^/|" , '.'
    StringHiBG  "|>-<|" , '.'
    StringHiBG  "|/^\|" , '.'
    StringHiBG  "O...O" , '.'
    SpriteInfo  5,5             ; 5 by 5

sprite_kiteL:
    StringHiBG  "..O"  , '.'
    StringHiBG  "o/|"  , '.'
    StringHiBG  "|<|"  , '.'
    StringHiBG  "o\|"  , '.'
    StringHiBG  "..O"  , '.'
    SpriteInfo  3,5             ; 3 by 5

sprite_kiteR:
    StringHiBG  "O.."  , '.'
    StringHiBG  "|\o"  , '.'
    StringHiBG  "|>|"  , '.'
    StringHiBG  "|/o"  , '.'
    StringHiBG  "O.."  , '.'
    SpriteInfo  3,5             ; 3 by 5

sprite_playerShip1:
    StringHiBG  "./^\." , '.'
    StringHiBG  "</^\>" , '.'
    SpriteInfo  5,2             ; 5 by 2

; Mock up
sprite_score:
    StringHi    "SCORE:0010"
    SpriteInfo  10,1            ; 10 by 1

; Mock up
sprite_lives3:
    StringHi    "^^^"
    SpriteInfo  3,1             ; 3 by 1

