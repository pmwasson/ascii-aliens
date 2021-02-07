;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Sprites

.align 256

spriteSheet:

ship0M:
    .byte       5,5             ; 5 wide x 5 high
    StringHiBG  "O...O" , '.'
    StringHiBG  "|\^/|" , '.'
    StringHiBG  "|>-<|" , '.'
    StringHiBG  "|/^\|" , '.'
    StringHiBG  "O...O" , '.'
    .res        62-5*5

ship0L:
    .byte       4,5             ; 4 wide x 5 high
    StringHiBG  "...O"  , '.'
    StringHiBG  ".o/|"  , '.'
    StringHiBG  ".|<|"  , '.'
    StringHiBG  ".o\|"  , '.'
    StringHiBG  "...O"  , '.'
    .res        62-4*5

ship0R:
    .byte       4,5             ; 4 wide x 5 high
    StringHiBG  ".O  "  , '.'
    StringHiBG  ".|\o"  , '.'
    StringHiBG  ".|>|"  , '.'
    StringHiBG  ".|/o"  , '.'
    StringHiBG  ".O  "  , '.'
    .res        62-4*5

; padding
    .res        64


ship1M:
    .byte       5,5             ; 5 wide x 5 high
    StringHiBG  "O...O" , '.'
    StringHiBG  "|\^/|" , '.'
    StringHiBG  "|>=<|" , '.'
    StringHiBG  "|/^\|" , '.'
    StringHiBG  "O...O" , '.'
    .res        62-5*5

ship1L:
    .byte       4,5             ; 4 wide x 5 high
    StringHiBG  "...O"  , '.'
    StringHiBG  ".o/|"  , '.'
    StringHiBG  ".|<|"  , '.'
    StringHiBG  ".o\|"  , '.'
    StringHiBG  "...O"  , '.'
    .res        62-4*5

ship1R:
    .byte       4,5             ; 4 wide x 5 high
    StringHiBG  ".O  "  , '.'
    StringHiBG  ".|\o"  , '.'
    StringHiBG  ".|>|"  , '.'
    StringHiBG  ".|/o"  , '.'
    StringHiBG  ".O  "  , '.'
    .res        62-4*5


; padding
    .res        64
