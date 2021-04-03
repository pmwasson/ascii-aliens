;-----------------------------------------------------------------------------
; Paul Wasson - 2021
;-----------------------------------------------------------------------------
; Sprites

.align 256

SPRITE_BAD0 = 2
SPRITE_BAD1 = 4
SPRITE_BAD2 = 6

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

 ;                                       
 ;                \\-//                  
 ;                (0 0)                  
 ;                [:::]                  
 ;               /<>-<>\                 
 ;             /X >< >< X\               
 ;             /| \/-\/ |\               
 ;                | | |           
 ;                | | |                
 ;                V V V                  
 ;         
