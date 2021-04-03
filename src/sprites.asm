;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Sprites

.align 256

SPRITE_BAD0     = 2
SPRITE_BAD1     = 4
SPRITE_BAD2     = 6
SPRITE_BOSSH    = 8
SPRITE_BOSSB    = 10
SPRITE_BOSSAL   = 12
SPRITE_BOSSAR   = 14
SPRITE_BOSSL    = 16


spriteSheet:

;----

sprite_playerShip_0:
    StringHiBG  "./|\." , '.'
    StringHiBG  "</^\>" , '.'
    SpriteInfo  5,2             ; 5 by 2


sprite_playerShip_1:
    StringHiBG  "./^\." , '.'
    StringHiBG  "</^\>" , '.'
    SpriteInfo  5,2             ; 5 by 2

;----

sprite_bad0_0:
    StringHiBG  "<[]>" , '.'
    StringHiBG  "/><\" , '.'
    StringHiBG  "\../" , '.'
    SpriteInfo  4,3             ; 4 by 3

sprite_bad0_1:
    StringHiBG  ">[]<" , '.'
    StringHiBG  "\></" , '.'
    StringHiBG  "/..\" , '.'
    SpriteInfo  4,3             ; 4 by 3

;----

sprite_bad1_0:
    StringHiBG  "/{}{}\" , '.'
    StringHiBG  "\(())/" , '.'
    StringHiBG  ".))((." , '.'
    SpriteInfo  6,3             ; 6 by 3

sprite_bad1_1:
    StringHiBG  "/{}{}\" , '.'
    StringHiBG  "\))((/" , '.'
    StringHiBG  ".(())." , '.'
    SpriteInfo  6,3             ; 6 by 3

;----

sprite_bad2_0:
    StringHiBG  "./|\." , '.'
    StringHiBG  "<- ->" , '.'
    StringHiBG  ".\|/." , '.'
    SpriteInfo  5,3             ; 5 by 3

sprite_bad2_1:
    StringHiBG  "./|\." , '.'
    StringHiBG  "<-+->" , '.'
    StringHiBG  ".\|/." , '.'
    SpriteInfo  5,3             ; 5 by 3

;----

sprite_bossH_0:
    StringHiBG  "\\-//" , '.'
    StringHiBG  "(0 0)" , '.'
    StringHiBG  "[:::]" , '.'
    SpriteInfo  5,3             ; 5 by 3

sprite_bossH_1:
    StringHiBG  "\\-//" , '.'
    StringHiBG  "(0 0)" , '.'
    StringHiBG  "[---]" , '.'
    SpriteInfo  5,3             ; 5 by 3

sprite_bossB_0:
    StringHiBG  "<>-<>" , '.'
    StringHiBG  ">< ><" , '.'
    StringHiBG  "\/-\/" , '.'
    SpriteInfo  5,3             ; 5 by 3

sprite_bossB_1:
    StringHiBG  "<>-<>" , '.'
    StringHiBG  "><+><" , '.'
    StringHiBG  "\/-\/" , '.'
    SpriteInfo  5,3             ; 5 by 3

sprite_bossAL_0:
    StringHiBG  "../" , '.'
    StringHiBG  "/X." , '.'
    StringHiBG  "/|." , '.'
    SpriteInfo  3,3             ; 3 by 3

sprite_bossAL_1:
    StringHiBG  "../" , '.'
    StringHiBG  "/X." , '.'
    StringHiBG  "||." , '.'
    SpriteInfo  3,3             ; 3 by 3

sprite_bossAR_0:
    StringHiBG  "\.." , '.'
    StringHiBG  ".X\" , '.'
    StringHiBG  ".|\" , '.'
    SpriteInfo  3,3             ; 3 by 3

sprite_bossAR_1:
    StringHiBG  "\.." , '.'
    StringHiBG  ".X\" , '.'
    StringHiBG  ".||" , '.'
    SpriteInfo  3,3             ; 3 by 3

sprite_bossL_0:
    StringHiBG  "||.||" , '.'
    StringHiBG  "|V.V|" , '.'
    StringHiBG  "V...V" , '.'
    SpriteInfo  5,3             ; 5 by 3

sprite_bossL_1:
    StringHiBG  "||.||" , '.'
    StringHiBG  "V|.|V" , '.'
    StringHiBG  ".V.V." , '.'
    SpriteInfo  5,3             ; 5 by 3
