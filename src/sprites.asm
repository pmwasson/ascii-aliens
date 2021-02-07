;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Sprites

.align 256

spriteSheet:

playerShip0:
    StringHiBG  "./|\." , '.'
    StringHiBG  "<_^_>" , '.'
    SpriteInfo  5,2             ; 5 by 2

KiteM:
    StringHiBG  "O...O" , '.'
    StringHiBG  "|\^/|" , '.'
    StringHiBG  "|>-<|" , '.'
    StringHiBG  "|/^\|" , '.'
    StringHiBG  "O...O" , '.'
    SpriteInfo  5,5             ; 5 by 5

KiteL:
    StringHiBG  "...O"  , '.'
    StringHiBG  ".o/|"  , '.'
    StringHiBG  ".|<|"  , '.'
    StringHiBG  ".o\|"  , '.'
    StringHiBG  "...O"  , '.'
    SpriteInfo  4,5             ; 4 by 5

KiteR:
    StringHiBG  ".O  "  , '.'
    StringHiBG  ".|\o"  , '.'
    StringHiBG  ".|>|"  , '.'
    StringHiBG  ".|/o"  , '.'
    StringHiBG  ".O  "  , '.'
    SpriteInfo  4,5             ; 4 by 5

playerShip1:
    StringHiBG  "./*\." , '.'
    StringHiBG  "<_^_>" , '.'
    SpriteInfo  5,2             ; 5 by 2